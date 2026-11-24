import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_one_off_task_repository.dart';
import 'package:cadence_tasks/data/local/drift/drift_routine_repository.dart';
import 'package:cadence_tasks/data/local/drift/drift_sync_repository.dart';
import 'package:cadence_tasks/data/local/drift/drift_task_type_conversion_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/domain_test_factories.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('converts a completed one-off task into a routine atomically', () async {
    const userId = 'conversion-user';
    final occurrenceDate = date(2026, 11, 24);
    final completedAtUtc = DateTime.utc(2026, 11, 24, 10);
    final source = oneOffTask(
      id: 'convert-me',
      title: 'Read',
      scheduledDate: occurrenceDate,
      scheduledTime: time(9, 0),
      durationMinutes: 60,
      status: TaskStatus.completed,
      completedAtUtc: completedAtUtc,
    );
    final target = routine(
      id: source.id,
      title: source.title,
      startDate: occurrenceDate,
      targetTime: source.scheduledTime!,
      durationMinutes: source.durationMinutes,
    );
    final oneOffRepository = DriftOneOffTaskRepository(
      database,
      userId: userId,
    );
    final routineRepository = DriftRoutineRepository(database, userId: userId);
    final conversionRepository = DriftTaskTypeConversionRepository(
      database,
      userId: userId,
      clock: () => DateTime.utc(2026, 11, 24, 11),
    );

    await oneOffRepository.save(source);
    expect(
      await conversionRepository.convertOneOffTaskToRoutine(
        source: source,
        target: target,
      ),
      isA<Success<Unit>>(),
    );

    expect(
      valueOf(await oneOffRepository.getScheduledFor(occurrenceDate)),
      isEmpty,
    );
    final savedRoutines = valueOf(await routineRepository.getAllRoutines());
    expect(savedRoutines, hasLength(1));
    expect(savedRoutines.single.id, target.id);
    expect(savedRoutines.single.durationMinutes, target.durationMinutes);
    final initialState = valueOf(
      await routineRepository.getOccurrenceStatesAffecting(occurrenceDate),
    );
    expect(initialState.single.status, TaskStatus.completed);
    expect(initialState.single.completedAtUtc, completedAtUtc);
    expect(
      await DriftSyncRepository(database).pendingMutations(userId),
      hasLength(3),
    );
  });

  test(
    'converts a routine into a one-off task without deleting its history',
    () async {
      const userId = 'conversion-user';
      final occurrenceDate = date(2026, 11, 24);
      final completedAtUtc = DateTime.utc(2026, 11, 24, 10);
      final source = routine(
        id: 'convert-me',
        title: 'Read',
        startDate: occurrenceDate,
        targetTime: time(9, 0),
        durationMinutes: 60,
      );
      final sourceState = occurrenceState(
        routineId: source.id,
        occurrenceDate: occurrenceDate,
        status: TaskStatus.completed,
        completedAtUtc: completedAtUtc,
      );
      final target = oneOffTask(
        id: source.id,
        title: source.title,
        scheduledDate: occurrenceDate,
        scheduledTime: source.targetTime,
        durationMinutes: source.durationMinutes,
        status: sourceState.status,
        completedAtUtc: sourceState.completedAtUtc,
      );
      final routineRepository = DriftRoutineRepository(
        database,
        userId: userId,
      );
      final oneOffRepository = DriftOneOffTaskRepository(
        database,
        userId: userId,
      );
      final conversionRepository = DriftTaskTypeConversionRepository(
        database,
        userId: userId,
      );

      await routineRepository.save(source);
      await routineRepository.saveOccurrenceState(sourceState);
      expect(
        await conversionRepository.convertRoutineToOneOffTask(
          source: source,
          target: target,
        ),
        isA<Success<Unit>>(),
      );

      expect(valueOf(await routineRepository.getAllRoutines()), isEmpty);
      expect(
        valueOf(
          await routineRepository.getOccurrenceStatesAffecting(occurrenceDate),
        ).single.status,
        TaskStatus.completed,
      );
      final savedTask = valueOf(
        await oneOffRepository.getScheduledFor(occurrenceDate),
      );
      expect(savedTask.single.status, TaskStatus.completed);
      expect(savedTask.single.durationMinutes, 60);
    },
  );

  test(
    'keeps task data unchanged when the source task no longer exists',
    () async {
      final occurrenceDate = date(2026, 11, 24);
      final source = oneOffTask(
        id: 'missing-task',
        title: 'Read',
        scheduledDate: occurrenceDate,
        scheduledTime: time(9, 0),
      );
      final target = routine(
        id: source.id,
        title: source.title,
        startDate: occurrenceDate,
        targetTime: source.scheduledTime!,
      );
      final result = await DriftTaskTypeConversionRepository(
        database,
        userId: 'conversion-user',
      ).convertOneOffTaskToRoutine(source: source, target: target);

      expect(result, isA<FailureResult<Unit>>());
      expect(
        await DriftSyncRepository(database).pendingMutations('conversion-user'),
        isEmpty,
      );
    },
  );
}
