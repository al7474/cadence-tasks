import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/domain_test_factories.dart';

void main() {
  group('OneOffTask', () {
    test('requires a scheduled time when reminders are enabled', () {
      final result = OneOffTask.create(
        id: 'task-1',
        title: 'Review notes',
        scheduledDate: date(2026, 11, 21),
        reminderEnabled: true,
      );

      expect(result, isA<FailureResult<OneOffTask>>());
    });

    test('accepts a duration that fits in the scheduled day', () {
      final result = OneOffTask.create(
        id: 'task-1',
        title: 'Focus session',
        scheduledDate: date(2026, 11, 21),
        scheduledTime: time(22, 30),
        durationMinutes: 90,
      );

      expect(result, isA<Success<OneOffTask>>());
      expect((result as Success<OneOffTask>).value.durationMinutes, 90);
    });

    test(
      'requires a start time and prevents durations from crossing midnight',
      () {
        expect(
          OneOffTask.create(
            id: 'untimed-task',
            title: 'Focus session',
            scheduledDate: date(2026, 11, 21),
            durationMinutes: 30,
          ),
          isA<FailureResult<OneOffTask>>(),
        );
        expect(
          OneOffTask.create(
            id: 'overnight-task',
            title: 'Focus session',
            scheduledDate: date(2026, 11, 21),
            scheduledTime: time(23, 30),
            durationMinutes: 31,
          ),
          isA<FailureResult<OneOffTask>>(),
        );
        expect(
          OneOffTask.create(
            id: 'invalid-task',
            title: 'Focus session',
            scheduledDate: date(2026, 11, 21),
            scheduledTime: time(10, 0),
            durationMinutes: 0,
          ),
          isA<FailureResult<OneOffTask>>(),
        );
      },
    );

    test('requires a UTC completion timestamp for completed tasks', () {
      final result = OneOffTask.create(
        id: 'task-1',
        title: 'Review notes',
        scheduledDate: date(2026, 11, 21),
        status: TaskStatus.completed,
      );

      expect(result, isA<FailureResult<OneOffTask>>());
    });

    test('does not allow completed tasks to remain snoozed', () {
      final result = OneOffTask.create(
        id: 'task-1',
        title: 'Review notes',
        scheduledDate: date(2026, 11, 21),
        status: TaskStatus.completed,
        completedAtUtc: DateTime.utc(2026, 11, 21, 12),
        snoozedUntilUtc: DateTime.utc(2026, 11, 21, 12, 10),
      );

      expect(result, isA<FailureResult<OneOffTask>>());
    });
  });
}
