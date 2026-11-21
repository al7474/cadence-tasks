import 'dart:convert';

import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_one_off_task_repository.dart';
import 'package:cadence_tasks/data/local/drift/drift_routine_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/domain_test_factories.dart';

void main() {
  late AppDatabase database;
  late DriftRoutineRepository routines;
  late DriftOneOffTaskRepository oneOffTasks;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    routines = DriftRoutineRepository(database);
    oneOffTasks = DriftOneOffTaskRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftRoutineRepository', () {
    test('persists routines and replaces pending sync mutations', () async {
      final today = date(2026, 11, 21);
      final first = routine(
        id: 'routine-1',
        title: 'Morning walk',
        startDate: today,
        targetTime: time(8, 0),
      );
      final updated = routine(
        id: first.id,
        title: 'Morning walk outside',
        startDate: today,
        targetTime: time(8, 30),
      );

      expect(await routines.save(first), isA<Success<Unit>>());
      expect(await routines.save(updated), isA<Success<Unit>>());

      final saved = valueOf(await routines.getAllRoutines());
      final outbox = await database.select(database.syncOutboxEntries).get();

      expect(saved, hasLength(1));
      expect(saved.single.title, updated.title);
      expect(saved.single.targetTime, updated.targetTime);
      expect(outbox, hasLength(1));
      expect(outbox.single.collectionName, 'routineTemplates');
      expect(
        jsonDecode(outbox.single.payload),
        containsPair('title', updated.title),
      );
    });

    test('keeps routine data isolated by local user ID', () async {
      final otherUserRoutines = DriftRoutineRepository(
        database,
        userId: 'other-user',
      );
      final item = routine(
        id: 'routine-1',
        title: 'Read',
        startDate: date(2026, 11, 21),
        targetTime: time(9, 0),
      );

      await routines.save(item);

      expect(valueOf(await routines.getAllRoutines()), hasLength(1));
      expect(valueOf(await otherUserRoutines.getAllRoutines()), isEmpty);
    });

    test('persists completion state and soft-deletes templates', () async {
      final occurrenceDate = date(2026, 11, 21);
      final item = routine(
        id: 'routine-1',
        title: 'Read',
        startDate: occurrenceDate,
        targetTime: time(9, 0),
      );
      final state = occurrenceState(
        routineId: item.id,
        occurrenceDate: occurrenceDate,
        status: TaskStatus.completed,
        completedAtUtc: DateTime.utc(2026, 11, 21, 14),
      );

      await routines.save(item);
      await routines.saveOccurrenceState(state);

      final savedState = valueOf(
        await routines.getOccurrenceStatesAffecting(occurrenceDate),
      );
      expect(savedState.single.status, TaskStatus.completed);
      expect(savedState.single.completedAtUtc, DateTime.utc(2026, 11, 21, 14));

      expect(await routines.delete(item.id), isA<Success<Unit>>());
      expect(valueOf(await routines.getAllRoutines()), isEmpty);

      final outbox = await database.select(database.syncOutboxEntries).get();
      expect(outbox, hasLength(2));
      final deletion = outbox.singleWhere(
        (entry) => entry.collectionName == 'routineTemplates',
      );
      final payload = jsonDecode(deletion.payload) as Map<String, dynamic>;
      expect(payload['deletedAtUtcMillis'], isNotNull);
    });

    test('hides disabled routines from the agenda query', () async {
      final today = date(2026, 11, 21);
      final disabled = routine(
        id: 'routine-1',
        title: 'Read',
        startDate: today,
        targetTime: time(9, 0),
        isEnabled: false,
      );

      await routines.save(disabled);

      expect(valueOf(await routines.getAllRoutines()), hasLength(1));
      expect(valueOf(await routines.getEnabledRoutines()), isEmpty);
    });
  });

  group('DriftOneOffTaskRepository', () {
    test('persists scheduled tasks and soft-deletes them', () async {
      final today = date(2026, 11, 21);
      final task = oneOffTask(
        id: 'task-1',
        title: 'Call the dentist',
        scheduledDate: today,
        scheduledTime: time(10, 15),
        reminderEnabled: true,
      );

      await oneOffTasks.save(task);

      final saved = valueOf(await oneOffTasks.getScheduledFor(today));
      expect(saved, hasLength(1));
      expect(saved.single.title, task.title);
      expect(saved.single.scheduledTime, task.scheduledTime);
      expect(saved.single.reminderEnabled, isTrue);

      expect(await oneOffTasks.delete(task.id), isA<Success<Unit>>());
      expect(valueOf(await oneOffTasks.getScheduledFor(today)), isEmpty);
    });
  });
}
