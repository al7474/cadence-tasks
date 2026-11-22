import 'dart:convert';

import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_record_mappers.dart';
import 'package:cadence_tasks/features/synchronization/domain/conflict_resolver.dart';
import 'package:cadence_tasks/features/synchronization/domain/sync_version.dart';
import 'package:drift/drift.dart';

final class DriftSyncRepository {
  const DriftSyncRepository(this._database);

  static const guestUserId = 'local';

  final AppDatabase _database;

  Future<List<SyncOutboxEntryRow>> pendingMutations(String userId) {
    return (_database.select(_database.syncOutboxEntries)
          ..where((entry) => entry.userId.equals(userId))
          ..orderBy([
            (entry) => OrderingTerm.asc(entry.updatedAtUtcMillis),
            (entry) => OrderingTerm.asc(entry.mutationId),
          ]))
        .get();
  }

  Future<SyncVersion?> cursorFor(String userId, String collectionName) async {
    final cursor =
        await (_database.select(_database.syncCursors)..where(
              (row) =>
                  row.userId.equals(userId) &
                  row.collectionName.equals(collectionName),
            ))
            .getSingleOrNull();
    return cursor == null
        ? null
        : _version(cursor.lastUpdatedAtUtcMillis, cursor.lastMutationId);
  }

  Future<void> saveCursor(
    String userId,
    String collectionName,
    SyncVersion version,
  ) {
    return _database
        .into(_database.syncCursors)
        .insertOnConflictUpdate(
          SyncCursorsCompanion.insert(
            userId: userId,
            collectionName: collectionName,
            lastUpdatedAtUtcMillis: Value<int>(
              version.updatedAtUtc.millisecondsSinceEpoch,
            ),
            lastMutationId: Value<String>(version.mutationId),
          ),
        );
  }

  Future<SyncVersion?> versionFor({
    required String userId,
    required String collectionName,
    required String recordId,
  }) async {
    final millis = switch (collectionName) {
      'routineTemplates' => await _routineVersion(userId, recordId),
      'routineOccurrenceLogs' => await _occurrenceVersion(userId, recordId),
      'oneOffTasks' => await _oneOffVersion(userId, recordId),
      _ => throw ArgumentError.value(
        collectionName,
        'collectionName',
        'Unknown sync collection.',
      ),
    };

    return millis;
  }

  Future<void> removeMutation(String mutationId) async {
    await (_database.delete(
      _database.syncOutboxEntries,
    )..where((entry) => entry.id.equals(mutationId))).go();
  }

  Future<void> deleteUserData(String userId) async {
    if (userId.trim().isEmpty || userId == guestUserId) {
      throw ArgumentError.value(userId, 'userId', 'Must be a signed-in user.');
    }

    await _deleteUserRecords(userId);
  }

  Future<void> deleteAllLocalData() async {
    await _database.transaction(() async {
      await _database.delete(_database.routineOccurrenceLogs).go();
      await _database.delete(_database.routineTemplates).go();
      await _database.delete(_database.oneOffTasks).go();
      await _database.delete(_database.syncOutboxEntries).go();
      await _database.delete(_database.syncCursors).go();
    });
  }

  Future<void> _deleteUserRecords(String userId) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.routineOccurrenceLogs,
      )..where((row) => row.userId.equals(userId))).go();
      await (_database.delete(
        _database.routineTemplates,
      )..where((row) => row.userId.equals(userId))).go();
      await (_database.delete(
        _database.oneOffTasks,
      )..where((row) => row.userId.equals(userId))).go();
      await (_database.delete(
        _database.syncOutboxEntries,
      )..where((row) => row.userId.equals(userId))).go();
      await (_database.delete(
        _database.syncCursors,
      )..where((row) => row.userId.equals(userId))).go();
    });
  }

  Future<void> deleteRemoteRecord({
    required String userId,
    required String collectionName,
    required String recordId,
  }) async {
    await _database.transaction(() async {
      switch (collectionName) {
        case 'routineTemplates':
          await (_database.delete(_database.routineTemplates)..where(
                (row) => row.userId.equals(userId) & row.id.equals(recordId),
              ))
              .go();
        case 'routineOccurrenceLogs':
          final separator = recordId.lastIndexOf(':');
          if (separator <= 0 || separator == recordId.length - 1) {
            throw const FormatException('The occurrence record ID is invalid.');
          }
          await (_database.delete(_database.routineOccurrenceLogs)..where(
                (row) =>
                    row.userId.equals(userId) &
                    row.routineId.equals(recordId.substring(0, separator)) &
                    row.occurrenceDate.equals(
                      recordId.substring(separator + 1),
                    ),
              ))
              .go();
        case 'oneOffTasks':
          await (_database.delete(_database.oneOffTasks)..where(
                (row) => row.userId.equals(userId) & row.id.equals(recordId),
              ))
              .go();
        default:
          throw FormatException('Unknown sync collection: $collectionName.');
      }

      await _discardOutboxForRecord(userId, collectionName, recordId);
    });
  }

  Future<void> applyRemoteRecord({
    required String userId,
    required String collectionName,
    required String recordId,
    required Map<String, dynamic> payload,
  }) async {
    if (payload['userId'] != userId) {
      throw const FormatException(
        'The remote record does not belong to the authenticated user.',
      );
    }

    final updatedAtUtc = DateTime.fromMillisecondsSinceEpoch(
      _requiredInt(payload, 'updatedAtUtcMillis'),
      isUtc: true,
    );
    final deletedAtMillis = _optionalInt(payload, 'deletedAtUtcMillis');
    final deletedAtUtc = deletedAtMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(deletedAtMillis, isUtc: true);
    final mutationId = _requiredString(payload, 'mutationId');

    await _database.transaction(() async {
      switch (collectionName) {
        case 'routineTemplates':
          final routine = DriftRecordMappers.routineFromPayload(payload);
          if (routine.id != recordId) {
            throw const FormatException(
              'The remote routine ID does not match its document ID.',
            );
          }
          await _database
              .into(_database.routineTemplates)
              .insertOnConflictUpdate(
                DriftRecordMappers.routineToCompanion(
                  routine: routine,
                  userId: userId,
                  updatedAtUtc: updatedAtUtc,
                  mutationId: mutationId,
                  deletedAtUtc: deletedAtUtc,
                ),
              );
        case 'routineOccurrenceLogs':
          final state = DriftRecordMappers.occurrenceFromPayload(payload);
          final expectedId =
              '${state.routineId}:${state.occurrenceDate.iso8601}';
          if (expectedId != recordId) {
            throw const FormatException(
              'The remote occurrence ID does not match its document ID.',
            );
          }
          await _database
              .into(_database.routineOccurrenceLogs)
              .insertOnConflictUpdate(
                DriftRecordMappers.occurrenceToCompanion(
                  state: state,
                  userId: userId,
                  updatedAtUtc: updatedAtUtc,
                  mutationId: mutationId,
                  deletedAtUtc: deletedAtUtc,
                ),
              );
        case 'oneOffTasks':
          final task = DriftRecordMappers.oneOffTaskFromPayload(payload);
          if (task.id != recordId) {
            throw const FormatException(
              'The remote task ID does not match its document ID.',
            );
          }
          await _database
              .into(_database.oneOffTasks)
              .insertOnConflictUpdate(
                DriftRecordMappers.oneOffTaskToCompanion(
                  task: task,
                  userId: userId,
                  updatedAtUtc: updatedAtUtc,
                  mutationId: mutationId,
                  deletedAtUtc: deletedAtUtc,
                ),
              );
        default:
          throw FormatException('Unknown sync collection: $collectionName.');
      }

      await _discardOutboxForRecord(userId, collectionName, recordId);
    });
  }

  Future<void> claimGuestData(String userId) async {
    if (userId.trim().isEmpty || userId == guestUserId) {
      throw ArgumentError.value(userId, 'userId', 'Must be a signed-in user.');
    }

    await _database.transaction(() async {
      await _claimRoutines(userId);
      await _claimOccurrences(userId);
      await _claimOneOffTasks(userId);
      await _claimOutbox(userId);
      await (_database.delete(
        _database.syncCursors,
      )..where((cursor) => cursor.userId.equals(guestUserId))).go();
    });
  }

  Future<SyncVersion?> _routineVersion(String userId, String recordId) async {
    final row =
        await (_database.select(_database.routineTemplates)..where(
              (routine) =>
                  routine.userId.equals(userId) & routine.id.equals(recordId),
            ))
            .getSingleOrNull();
    return row == null
        ? null
        : _version(row.updatedAtUtcMillis, row.mutationId);
  }

  Future<SyncVersion?> _occurrenceVersion(
    String userId,
    String recordId,
  ) async {
    final separator = recordId.lastIndexOf(':');
    if (separator <= 0 || separator == recordId.length - 1) {
      throw const FormatException('The occurrence record ID is invalid.');
    }

    final routineId = recordId.substring(0, separator);
    final occurrenceDate = recordId.substring(separator + 1);
    final row =
        await (_database.select(_database.routineOccurrenceLogs)..where(
              (state) =>
                  state.userId.equals(userId) &
                  state.routineId.equals(routineId) &
                  state.occurrenceDate.equals(occurrenceDate),
            ))
            .getSingleOrNull();
    return row == null
        ? null
        : _version(row.updatedAtUtcMillis, row.mutationId);
  }

  Future<SyncVersion?> _oneOffVersion(String userId, String recordId) async {
    final row =
        await (_database.select(_database.oneOffTasks)..where(
              (task) => task.userId.equals(userId) & task.id.equals(recordId),
            ))
            .getSingleOrNull();
    return row == null
        ? null
        : _version(row.updatedAtUtcMillis, row.mutationId);
  }

  Future<void> _discardOutboxForRecord(
    String userId,
    String collectionName,
    String recordId,
  ) async {
    await (_database.delete(_database.syncOutboxEntries)..where(
          (entry) =>
              entry.userId.equals(userId) &
              entry.collectionName.equals(collectionName) &
              entry.recordId.equals(recordId),
        ))
        .go();
  }

  Future<void> _claimRoutines(String userId) async {
    final rows = await (_database.select(
      _database.routineTemplates,
    )..where((routine) => routine.userId.equals(guestUserId))).get();

    for (final row in rows) {
      final existing =
          await (_database.select(_database.routineTemplates)..where(
                (routine) =>
                    routine.userId.equals(userId) & routine.id.equals(row.id),
              ))
              .getSingleOrNull();
      if (existing == null ||
          _isLocalVersionNewer(
            localUpdatedAtUtcMillis: row.updatedAtUtcMillis,
            localMutationId: row.mutationId,
            existingUpdatedAtUtcMillis: existing.updatedAtUtcMillis,
            existingMutationId: existing.mutationId,
          )) {
        await _database
            .into(_database.routineTemplates)
            .insertOnConflictUpdate(
              row.toCompanion(true).copyWith(userId: Value<String>(userId)),
            );
      }
      await (_database.delete(_database.routineTemplates)..where(
            (routine) =>
                routine.userId.equals(guestUserId) & routine.id.equals(row.id),
          ))
          .go();
    }
  }

  Future<void> _claimOccurrences(String userId) async {
    final rows = await (_database.select(
      _database.routineOccurrenceLogs,
    )..where((state) => state.userId.equals(guestUserId))).get();

    for (final row in rows) {
      final existing =
          await (_database.select(_database.routineOccurrenceLogs)..where(
                (state) =>
                    state.userId.equals(userId) &
                    state.routineId.equals(row.routineId) &
                    state.occurrenceDate.equals(row.occurrenceDate),
              ))
              .getSingleOrNull();
      if (existing == null ||
          _isLocalVersionNewer(
            localUpdatedAtUtcMillis: row.updatedAtUtcMillis,
            localMutationId: row.mutationId,
            existingUpdatedAtUtcMillis: existing.updatedAtUtcMillis,
            existingMutationId: existing.mutationId,
          )) {
        await _database
            .into(_database.routineOccurrenceLogs)
            .insertOnConflictUpdate(
              row.toCompanion(true).copyWith(userId: Value<String>(userId)),
            );
      }
      await (_database.delete(_database.routineOccurrenceLogs)..where(
            (state) =>
                state.userId.equals(guestUserId) &
                state.routineId.equals(row.routineId) &
                state.occurrenceDate.equals(row.occurrenceDate),
          ))
          .go();
    }
  }

  Future<void> _claimOneOffTasks(String userId) async {
    final rows = await (_database.select(
      _database.oneOffTasks,
    )..where((task) => task.userId.equals(guestUserId))).get();

    for (final row in rows) {
      final existing =
          await (_database.select(_database.oneOffTasks)..where(
                (task) => task.userId.equals(userId) & task.id.equals(row.id),
              ))
              .getSingleOrNull();
      if (existing == null ||
          _isLocalVersionNewer(
            localUpdatedAtUtcMillis: row.updatedAtUtcMillis,
            localMutationId: row.mutationId,
            existingUpdatedAtUtcMillis: existing.updatedAtUtcMillis,
            existingMutationId: existing.mutationId,
          )) {
        await _database
            .into(_database.oneOffTasks)
            .insertOnConflictUpdate(
              row.toCompanion(true).copyWith(userId: Value<String>(userId)),
            );
      }
      await (_database.delete(_database.oneOffTasks)..where(
            (task) => task.userId.equals(guestUserId) & task.id.equals(row.id),
          ))
          .go();
    }
  }

  Future<void> _claimOutbox(String userId) async {
    final rows = await (_database.select(
      _database.syncOutboxEntries,
    )..where((entry) => entry.userId.equals(guestUserId))).get();

    for (final row in rows) {
      final decoded = jsonDecode(row.payload);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('A queued sync mutation is invalid.');
      }
      final payload = Map<String, dynamic>.from(decoded)..['userId'] = userId;
      await (_database.update(
        _database.syncOutboxEntries,
      )..where((entry) => entry.id.equals(row.id))).write(
        SyncOutboxEntriesCompanion(
          userId: Value<String>(userId),
          payload: Value<String>(jsonEncode(payload)),
        ),
      );
    }
  }

  static bool _isLocalVersionNewer({
    required int localUpdatedAtUtcMillis,
    required String localMutationId,
    required int existingUpdatedAtUtcMillis,
    required String existingMutationId,
  }) {
    final localVersion = _version(localUpdatedAtUtcMillis, localMutationId);
    final existingVersion = _version(
      existingUpdatedAtUtcMillis,
      existingMutationId,
    );
    return ConflictResolver.resolve(
          local: localVersion,
          remote: existingVersion,
        ) ==
        ConflictWinner.local;
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

  static String _requiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is String) {
      return value;
    }
    throw FormatException('The remote record has no valid $key.');
  }

  static int _requiredInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is int) {
      return value;
    }
    throw FormatException('The remote record has no valid $key.');
  }

  static int? _optionalInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value == null || value is int) {
      return value as int?;
    }
    throw FormatException('The remote record has an invalid $key.');
  }
}
