import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';

final class RoutineOccurrenceState {
  const RoutineOccurrenceState._({
    required this.routineId,
    required this.occurrenceDate,
    required this.status,
    this.completedAtUtc,
    this.snoozedUntilUtc,
    this.rescheduledDate,
    this.rescheduledTime,
  });

  final String routineId;
  final LocalDate occurrenceDate;
  final TaskStatus status;
  final DateTime? completedAtUtc;
  final DateTime? snoozedUntilUtc;
  final LocalDate? rescheduledDate;
  final LocalTime? rescheduledTime;

  static Result<RoutineOccurrenceState> create({
    required String routineId,
    required LocalDate occurrenceDate,
    TaskStatus status = TaskStatus.pending,
    DateTime? completedAtUtc,
    DateTime? snoozedUntilUtc,
    LocalDate? rescheduledDate,
    LocalTime? rescheduledTime,
  }) {
    if (routineId.trim().isEmpty) {
      return const FailureResult<RoutineOccurrenceState>(
        ValidationFailure('A routine ID is required for occurrence state.'),
      );
    }
    if ((status == TaskStatus.completed) != (completedAtUtc != null)) {
      return const FailureResult<RoutineOccurrenceState>(
        ValidationFailure(
          'Completed occurrences must have a completion timestamp.',
        ),
      );
    }
    if (status != TaskStatus.pending &&
        (rescheduledDate != null ||
            rescheduledTime != null ||
            snoozedUntilUtc != null)) {
      return const FailureResult<RoutineOccurrenceState>(
        ValidationFailure(
          'Only pending occurrences can be snoozed or rescheduled.',
        ),
      );
    }
    if ((completedAtUtc != null && !completedAtUtc.isUtc) ||
        (snoozedUntilUtc != null && !snoozedUntilUtc.isUtc)) {
      return const FailureResult<RoutineOccurrenceState>(
        ValidationFailure('Occurrence timestamps must be UTC.'),
      );
    }

    return Success<RoutineOccurrenceState>(
      RoutineOccurrenceState._(
        routineId: routineId.trim(),
        occurrenceDate: occurrenceDate,
        status: status,
        completedAtUtc: completedAtUtc,
        snoozedUntilUtc: snoozedUntilUtc,
        rescheduledDate: rescheduledDate,
        rescheduledTime: rescheduledTime,
      ),
    );
  }
}
