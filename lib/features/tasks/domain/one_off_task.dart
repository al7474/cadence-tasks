import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';

final class OneOffTask {
  const OneOffTask._({
    required this.id,
    required this.title,
    required this.scheduledDate,
    required this.status,
    required this.reminderEnabled,
    this.notes,
    this.scheduledTime,
    this.durationMinutes,
    this.completedAtUtc,
    this.snoozedUntilUtc,
  });

  final String id;
  final String title;
  final String? notes;
  final LocalDate scheduledDate;
  final LocalTime? scheduledTime;
  final int? durationMinutes;
  final bool reminderEnabled;
  final TaskStatus status;
  final DateTime? completedAtUtc;
  final DateTime? snoozedUntilUtc;

  static Result<OneOffTask> create({
    required String id,
    required String title,
    required LocalDate scheduledDate,
    LocalTime? scheduledTime,
    int? durationMinutes,
    bool reminderEnabled = false,
    String? notes,
    TaskStatus status = TaskStatus.pending,
    DateTime? completedAtUtc,
    DateTime? snoozedUntilUtc,
  }) {
    if (id.trim().isEmpty) {
      return const FailureResult<OneOffTask>(
        ValidationFailure('A task ID is required.'),
      );
    }
    if (title.trim().isEmpty) {
      return const FailureResult<OneOffTask>(
        ValidationFailure('A task title is required.'),
      );
    }
    if (reminderEnabled && scheduledTime == null) {
      return const FailureResult<OneOffTask>(
        ValidationFailure('A reminder requires a scheduled time.'),
      );
    }
    if (durationMinutes != null &&
        (durationMinutes < 1 ||
            scheduledTime == null ||
            scheduledTime.minutesSinceMidnight + durationMinutes > 1440)) {
      return const FailureResult<OneOffTask>(
        ValidationFailure(
          'A task duration requires a start time and must end before midnight.',
        ),
      );
    }
    if ((status == TaskStatus.completed) != (completedAtUtc != null)) {
      return const FailureResult<OneOffTask>(
        ValidationFailure('Completed tasks must have a completion timestamp.'),
      );
    }
    if (status != TaskStatus.pending && snoozedUntilUtc != null) {
      return const FailureResult<OneOffTask>(
        ValidationFailure('Only pending tasks can be snoozed.'),
      );
    }
    if ((completedAtUtc != null && !completedAtUtc.isUtc) ||
        (snoozedUntilUtc != null && !snoozedUntilUtc.isUtc)) {
      return const FailureResult<OneOffTask>(
        ValidationFailure('Task timestamps must be UTC.'),
      );
    }

    return Success<OneOffTask>(
      OneOffTask._(
        id: id.trim(),
        title: title.trim(),
        notes: notes,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        durationMinutes: durationMinutes,
        reminderEnabled: reminderEnabled,
        status: status,
        completedAtUtc: completedAtUtc,
        snoozedUntilUtc: snoozedUntilUtc,
      ),
    );
  }
}
