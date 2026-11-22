import 'dart:convert';

import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_one_off_task_repository.dart';
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

  test(
    'deletes one account local data without affecting another account',
    () async {
      final targetUserId = 'firebase-user-1';
      final otherUserId = 'firebase-user-2';
      final scheduledDate = date(2026, 11, 21);
      final targetRoutines = DriftRoutineRepository(
        database,
        userId: targetUserId,
      );
      final otherRoutines = DriftRoutineRepository(
        database,
        userId: otherUserId,
      );
      final targetTasks = DriftOneOffTaskRepository(
        database,
        userId: targetUserId,
      );
      final otherTasks = DriftOneOffTaskRepository(
        database,
        userId: otherUserId,
      );

      await targetRoutines.save(
        routine(
          id: 'target-routine',
          title: 'Target routine',
          startDate: scheduledDate,
          targetTime: time(8, 0),
        ),
      );
      await otherRoutines.save(
        routine(
          id: 'other-routine',
          title: 'Other routine',
          startDate: scheduledDate,
          targetTime: time(9, 0),
        ),
      );
      await targetRoutines.saveOccurrenceState(
        occurrenceState(
          routineId: 'target-routine',
          occurrenceDate: scheduledDate,
        ),
      );
      await otherRoutines.saveOccurrenceState(
        occurrenceState(
          routineId: 'other-routine',
          occurrenceDate: scheduledDate,
        ),
      );
      await targetTasks.save(
        oneOffTask(
          id: 'target-task',
          title: 'Target task',
          scheduledDate: scheduledDate,
        ),
      );
      await otherTasks.save(
        oneOffTask(
          id: 'other-task',
          title: 'Other task',
          scheduledDate: scheduledDate,
        ),
      );
      await syncRepository.saveCursor(
        targetUserId,
        'oneOffTasks',
        syncVersion(
          updatedAtUtc: DateTime.utc(2026, 11, 21, 12),
          mutationId: 'target-cursor',
        ),
      );

      await syncRepository.deleteUserData(targetUserId);

      expect(valueOf(await targetRoutines.getAllRoutines()), isEmpty);
      expect(
        valueOf(
          await targetRoutines.getOccurrenceStatesAffecting(scheduledDate),
        ),
        isEmpty,
      );
      expect(
        valueOf(await targetTasks.getScheduledFor(scheduledDate)),
        isEmpty,
      );
      expect(await syncRepository.pendingMutations(targetUserId), isEmpty);
      expect(
        await syncRepository.cursorFor(targetUserId, 'oneOffTasks'),
        isNull,
      );
      expect(valueOf(await otherRoutines.getAllRoutines()), hasLength(1));
      expect(
        valueOf(
          await otherRoutines.getOccurrenceStatesAffecting(scheduledDate),
        ),
        hasLength(1),
      );
      expect(
        valueOf(await otherTasks.getScheduledFor(scheduledDate)),
        hasLength(1),
      );
      expect(await syncRepository.pendingMutations(otherUserId), hasLength(3));
    },
  );

  test(
    'applies a remote hard delete only to its authenticated owner',
    () async {
      final userId = 'firebase-user-1';
      final otherUserId = 'firebase-user-2';
      final scheduledDate = date(2026, 11, 21);
      final userTasks = DriftOneOffTaskRepository(database, userId: userId);
      final otherTasks = DriftOneOffTaskRepository(
        database,
        userId: otherUserId,
      );
      await userTasks.save(
        oneOffTask(
          id: 'deleted-task',
          title: 'Deleted task',
          scheduledDate: scheduledDate,
        ),
      );
      await otherTasks.save(
        oneOffTask(
          id: 'other-task',
          title: 'Other task',
          scheduledDate: scheduledDate,
        ),
      );

      await syncRepository.deleteRemoteRecord(
        userId: userId,
        collectionName: 'oneOffTasks',
        recordId: 'deleted-task',
      );

      expect(valueOf(await userTasks.getScheduledFor(scheduledDate)), isEmpty);
      expect(
        valueOf(await otherTasks.getScheduledFor(scheduledDate)),
        hasLength(1),
      );
      expect(await syncRepository.pendingMutations(userId), isEmpty);
      expect(await syncRepository.pendingMutations(otherUserId), hasLength(1));
    },
  );

  test(
    'deletes all local accounts and queued changes on explicit request',
    () async {
      final scheduledDate = date(2026, 11, 21);
      final guestTasks = DriftOneOffTaskRepository(database);
      final signedInTasks = DriftOneOffTaskRepository(
        database,
        userId: 'firebase-user-1',
      );
      await guestTasks.save(
        oneOffTask(
          id: 'guest-task',
          title: 'Guest task',
          scheduledDate: scheduledDate,
        ),
      );
      await signedInTasks.save(
        oneOffTask(
          id: 'signed-in-task',
          title: 'Signed-in task',
          scheduledDate: scheduledDate,
        ),
      );

      await syncRepository.deleteAllLocalData();

      expect(valueOf(await guestTasks.getScheduledFor(scheduledDate)), isEmpty);
      expect(
        valueOf(await signedInTasks.getScheduledFor(scheduledDate)),
        isEmpty,
      );
      expect(await syncRepository.pendingMutations('local'), isEmpty);
      expect(await syncRepository.pendingMutations('firebase-user-1'), isEmpty);
    },
  );
}
