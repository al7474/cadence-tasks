import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_rule.dart';
import 'package:cadence_tasks/features/routines/domain/routine_occurrence_state.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/synchronization/domain/sync_version.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';

T valueOf<T>(Result<T> result) {
  return switch (result) {
    Success<T>(:final value) => value,
    FailureResult<T>(:final failure) => throw StateError(failure.message),
  };
}

LocalDate date(int year, int month, int day) {
  return valueOf(LocalDate.create(year: year, month: month, day: day));
}

LocalTime time(int hour, int minute) {
  return valueOf(LocalTime.create(hour: hour, minute: minute));
}

RoutineTemplate routine({
  required String id,
  required String title,
  required LocalDate startDate,
  required LocalTime targetTime,
  RecurrenceRule recurrence = const DailyRecurrence(),
  LocalDate? endDate,
  bool reminderEnabled = true,
  bool isEnabled = true,
}) {
  return valueOf(
    RoutineTemplate.create(
      id: id,
      title: title,
      startDate: startDate,
      endDate: endDate,
      targetTime: targetTime,
      recurrence: recurrence,
      reminderEnabled: reminderEnabled,
      isEnabled: isEnabled,
    ),
  );
}

RoutineOccurrenceState occurrenceState({
  required String routineId,
  required LocalDate occurrenceDate,
  TaskStatus status = TaskStatus.pending,
  DateTime? completedAtUtc,
  DateTime? snoozedUntilUtc,
  LocalDate? rescheduledDate,
  LocalTime? rescheduledTime,
}) {
  return valueOf(
    RoutineOccurrenceState.create(
      routineId: routineId,
      occurrenceDate: occurrenceDate,
      status: status,
      completedAtUtc: completedAtUtc,
      snoozedUntilUtc: snoozedUntilUtc,
      rescheduledDate: rescheduledDate,
      rescheduledTime: rescheduledTime,
    ),
  );
}

OneOffTask oneOffTask({
  required String id,
  required String title,
  required LocalDate scheduledDate,
  LocalTime? scheduledTime,
  bool reminderEnabled = false,
  TaskStatus status = TaskStatus.pending,
  DateTime? completedAtUtc,
  DateTime? snoozedUntilUtc,
}) {
  return valueOf(
    OneOffTask.create(
      id: id,
      title: title,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      reminderEnabled: reminderEnabled,
      status: status,
      completedAtUtc: completedAtUtc,
      snoozedUntilUtc: snoozedUntilUtc,
    ),
  );
}

SyncVersion syncVersion({
  required DateTime updatedAtUtc,
  required String mutationId,
}) {
  return valueOf(
    SyncVersion.create(updatedAtUtc: updatedAtUtc, mutationId: mutationId),
  );
}
