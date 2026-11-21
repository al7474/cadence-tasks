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
