import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_rule.dart';
import 'package:cadence_tasks/features/routines/domain/repositories/routine_repository.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';

final class CreateRoutine {
  const CreateRoutine(this._repository);

  final RoutineRepository _repository;

  Future<Result<Unit>> execute({
    required String id,
    required String title,
    required LocalDate startDate,
    required LocalTime targetTime,
    required RecurrenceRule recurrence,
    String? notes,
    LocalDate? endDate,
    bool reminderEnabled = true,
  }) {
    final result = RoutineTemplate.create(
      id: id,
      title: title,
      startDate: startDate,
      endDate: endDate,
      targetTime: targetTime,
      recurrence: recurrence,
      notes: notes,
      reminderEnabled: reminderEnabled,
    );

    return switch (result) {
      FailureResult<RoutineTemplate>(:final failure) =>
        Future<Result<Unit>>.value(FailureResult<Unit>(failure)),
      Success<RoutineTemplate>(:final value) => _repository.save(value),
    };
  }
}
