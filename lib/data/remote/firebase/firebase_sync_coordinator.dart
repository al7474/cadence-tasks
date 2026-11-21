import 'dart:convert';

import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_sync_repository.dart';
import 'package:cadence_tasks/features/synchronization/domain/conflict_resolver.dart';
import 'package:cadence_tasks/features/synchronization/domain/sync_coordinator.dart';
import 'package:cadence_tasks/features/synchronization/domain/sync_version.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final class FirebaseSyncCoordinator implements SyncCoordinator {
  FirebaseSyncCoordinator({
    required FirebaseFirestore firestore,
    required AppDatabase database,
    required String userId,
  }) : _firestore = firestore,
       _local = DriftSyncRepository(database),
       _userId = userId {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'Must not be empty.');
    }
  }

  static const _collections = [
    'routineTemplates',
    'routineOccurrenceLogs',
    'oneOffTasks',
  ];
  static const _pullPageSize = 200;

  final FirebaseFirestore _firestore;
  final DriftSyncRepository _local;
  final String _userId;

  @override
  Future<Result<SyncSummary>> synchronize() async {
    var uploaded = 0;
    var downloaded = 0;
    var conflictsResolved = 0;

    try {
      final pending = await _local.pendingMutations(_userId);
      for (final mutation in pending) {
        final payload = _decodePayload(mutation.payload);
        if (payload['userId'] != _userId) {
          throw const FormatException(
            'A queued mutation belongs to a different user.',
          );
        }

        final document = _collection(
          mutation.collectionName,
        ).doc(mutation.recordId);
        final localVersion = _version(
          mutation.updatedAtUtcMillis,
          mutation.mutationId,
        );
        final resolution = await _firestore.runTransaction<_OutboxResolution>((
          transaction,
        ) async {
          final remoteSnapshot = await transaction.get(document);
          final remoteData = remoteSnapshot.data();
          if (remoteData == null) {
            transaction.set(document, payload);
            return const _LocalWrite(conflictResolved: false);
          }

          final remoteVersion = _versionFromPayload(remoteData);
          final winner = ConflictResolver.resolve(
            local: localVersion,
            remote: remoteVersion,
          );
          return switch (winner) {
            ConflictWinner.local => _writeLocal(transaction, document, payload),
            ConflictWinner.remote => _RemoteWrite(remoteData),
            ConflictWinner.sameVersion => const _AlreadySynchronized(),
          };
        });

        switch (resolution) {
          case _LocalWrite(:final conflictResolved):
            await _local.removeMutation(mutation.id);
            uploaded++;
            if (conflictResolved) {
              conflictsResolved++;
            }
          case _RemoteWrite(:final payload):
            await _local.applyRemoteRecord(
              userId: _userId,
              collectionName: mutation.collectionName,
              recordId: mutation.recordId,
              payload: payload,
            );
            conflictsResolved++;
          case _AlreadySynchronized():
            await _local.removeMutation(mutation.id);
        }
      }

      for (final collectionName in _collections) {
        final cursor = await _local.cursorFor(_userId, collectionName);
        Query<Map<String, dynamic>> query = _collection(collectionName)
            .orderBy('updatedAtUtcMillis')
            .orderBy('mutationId')
            .limit(_pullPageSize);
        if (cursor != null) {
          query = query.startAt([
            cursor.updatedAtUtc.millisecondsSinceEpoch,
            '',
          ]);
        }

        while (true) {
          final snapshots = await query.get(
            const GetOptions(source: Source.server),
          );
          if (snapshots.docs.isEmpty) {
            break;
          }

          SyncVersion? lastVersion;
          for (final document in snapshots.docs) {
            final payload = document.data();
            if (payload['userId'] != _userId) {
              throw const FormatException(
                'A remote record belongs to a different user.',
              );
            }

            final remoteVersion = _versionFromPayload(payload);
            final localVersion = await _local.versionFor(
              userId: _userId,
              collectionName: collectionName,
              recordId: document.id,
            );
            if (localVersion == null ||
                remoteVersion.compareTo(localVersion) > 0) {
              await _local.applyRemoteRecord(
                userId: _userId,
                collectionName: collectionName,
                recordId: document.id,
                payload: payload,
              );
              downloaded++;
            }
            lastVersion = remoteVersion;
          }

          if (lastVersion != null) {
            await _local.saveCursor(_userId, collectionName, lastVersion);
          }
          if (snapshots.docs.length < _pullPageSize) {
            break;
          }
          query = query.startAfterDocument(snapshots.docs.last);
        }
      }

      return Success<SyncSummary>(
        SyncSummary(
          uploaded: uploaded,
          downloaded: downloaded,
          conflictsResolved: conflictsResolved,
        ),
      );
    } on FirebaseException catch (error) {
      return FailureResult<SyncSummary>(
        UnavailableFailure(
          error.message ?? 'Cloud synchronization failed (${error.code}).',
        ),
      );
    } on FormatException catch (error) {
      return FailureResult<SyncSummary>(
        ConflictFailure('Cloud data could not be synchronized: $error'),
      );
    }
  }

  CollectionReference<Map<String, dynamic>> _collection(String name) {
    if (!_collections.contains(name)) {
      throw FormatException('Unknown Firestore collection: $name.');
    }
    return _firestore.collection('users').doc(_userId).collection(name);
  }

  static Map<String, dynamic> _decodePayload(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('A queued sync payload is not an object.');
  }

  static SyncVersion _versionFromPayload(Map<String, dynamic> payload) {
    final updatedAtUtcMillis = payload['updatedAtUtcMillis'];
    final mutationId = payload['mutationId'];
    if (updatedAtUtcMillis is! int || mutationId is! String) {
      throw const FormatException(
        'A cloud record has invalid conflict-resolution metadata.',
      );
    }
    return _version(updatedAtUtcMillis, mutationId);
  }

  static SyncVersion _version(int updatedAtUtcMillis, String mutationId) {
    final result = SyncVersion.create(
      updatedAtUtc: DateTime.fromMillisecondsSinceEpoch(
        updatedAtUtcMillis,
        isUtc: true,
      ),
      mutationId: mutationId,
    );
    return switch (result) {
      Success<SyncVersion>(:final value) => value,
      FailureResult<SyncVersion>(:final failure) => throw FormatException(
        failure.message,
      ),
    };
  }

  static _OutboxResolution _writeLocal(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> document,
    Map<String, dynamic> payload,
  ) {
    transaction.set(document, payload);
    return const _LocalWrite(conflictResolved: true);
  }
}

sealed class _OutboxResolution {
  const _OutboxResolution();
}

final class _LocalWrite extends _OutboxResolution {
  const _LocalWrite({required this.conflictResolved});

  final bool conflictResolved;
}

final class _RemoteWrite extends _OutboxResolution {
  const _RemoteWrite(this.payload);

  final Map<String, dynamic> payload;
}

final class _AlreadySynchronized extends _OutboxResolution {
  const _AlreadySynchronized();
}
