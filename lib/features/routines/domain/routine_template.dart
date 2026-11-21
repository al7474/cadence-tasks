import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_rule.dart';

final class RoutineTemplate {
  const RoutineTemplate._({
    required this.id,
    required this.title,
    required this.startDate,
    required this.targetTime,
    required this.recurrence,
    required this.isEnabled,
    this.notes,
    this.endDate,
    this.reminderEnabled = true,
  });

  final String id;
  final String title;
  final String? notes;
  final LocalDate startDate;
  final LocalDate? endDate;
  final LocalTime targetTime;
  final RecurrenceRule recurrence;
  final bool reminderEnabled;
  final bool isEnabled;

  static Result<RoutineTemplate> create({
    required String id,
    required String title,
    required LocalDate startDate,
    required LocalTime targetTime,
    required RecurrenceRule recurrence,
    String? notes,
    LocalDate? endDate,
    bool reminderEnabled = true,
    bool isEnabled = true,
  }) {
    if (id.trim().isEmpty) {
      return const FailureResult<RoutineTemplate>(
        ValidationFailure('A routine ID is required.'),
      );
    }
    if (title.trim().isEmpty) {
      return const FailureResult<RoutineTemplate>(
        ValidationFailure('A routine title is required.'),
      );
    }
    if (endDate != null && endDate.isBefore(startDate)) {
      return const FailureResult<RoutineTemplate>(
        ValidationFailure('The end date cannot be before the start date.'),
      );
    }

    return Success<RoutineTemplate>(
      RoutineTemplate._(
        id: id.trim(),
        title: title.trim(),
        notes: notes,
        startDate: startDate,
        endDate: endDate,
        targetTime: targetTime,
        recurrence: recurrence,
        reminderEnabled: reminderEnabled,
        isEnabled: isEnabled,
      ),
    );
  }
}
