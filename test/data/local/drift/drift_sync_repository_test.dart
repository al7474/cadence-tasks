import 'dart:convert';

import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_record_mappers.dart';
import 'package:cadence_tasks/data/local/drift/drift_routine_repository.dart';
import 'package:cadence_tasks/data/local/drift/drift_sync_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/domain_test_factories.dart';

void main() {
  late AppDatabase database;
  late DriftSyncRepository syncRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncRepository = DriftSyncRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'claims guest records and queued writes for an authenticated user',
    () async {
      final guestRepository = DriftRoutineRepository(database);
      final localRoutine = routine(
        id: 'routine-1',
        title: 'Read',
        startDate: date(2026, 11, 21),
        targetTime: time(8, 0),
      );
      await guestRepository.save(localRoutine);

      await syncRepository.claimGuestData('firebase-user-1');

      final signedInRepository = DriftRoutineRepository(
        database,
        userId: 'firebase-user-1',
      );
      expect(valueOf(await guestRepository.getAllRoutines()), isEmpty);
      expect(valueOf(await signedInRepository.getAllRoutines()), hasLength(1));

      final pending = await syncRepository.pendingMutations('firebase-user-1');
      expect(pending, hasLength(1));
      expect(pending.single.userId, 'firebase-user-1');
      expect(
        (jsonDecode(pending.single.payload) as Map<String, dynamic>)['userId'],
        'firebase-user-1',
      );
    },
  );

  test(
    'applies a newer remote record and clears its stale outbox entry',
    () async {
      final userId = 'firebase-user-1';
      final localRepository = DriftRoutineRepository(
        database,
        userId: userId,
        clock: () => DateTime.utc(2026, 11, 20, 10),
      );
      final localRoutine = routine(
        id: 'routine-1',
        title: 'Local title',
        startDate: date(2026, 11, 21),
        targetTime: time(8, 0),
      );
      await localRepository.save(localRoutine);

      final remoteRoutine = routine(
        id: localRoutine.id,
        title: 'Remote title',
        startDate: localRoutine.startDate,
        targetTime: localRoutine.targetTime,
      );
      final remotePayload = DriftRecordMappers.routinePayload(
        routine: remoteRoutine,
        userId: userId,
        updatedAtUtc: DateTime.utc(2026, 11, 20, 11),
        mutationId: 'remote-mutation',
      );

      await syncRepository.applyRemoteRecord(
        userId: userId,
        collectionName: 'routineTemplates',
        recordId: localRoutine.id,
        payload: Map<String, dynamic>.from(remotePayload),
      );

      final saved = valueOf(await localRepository.getAllRoutines());
      expect(saved.single.title, 'Remote title');
      expect(await syncRepository.pendingMutations(userId), isEmpty);
    },
  );

  test('persists per-user collection cursors', () async {
    final cursor = syncVersion(
      updatedAtUtc: DateTime.utc(2026, 11, 21, 12),
      mutationId: 'mutation-1',
    );

    await syncRepository.saveCursor(
      'firebase-user-1',
      'routineTemplates',
      cursor,
    );

    final saved = await syncRepository.cursorFor(
      'firebase-user-1',
      'routineTemplates',
    );
    expect(saved, isNotNull);
    expect(saved!.compareTo(cursor), 0);
    expect(
      await syncRepository.cursorFor('another-user', 'routineTemplates'),
      isNull,
    );
  });
}
