import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_rule.dart';
import 'package:cadence_tasks/features/routines/domain/repositories/routine_repository.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';

final class CreateRoutine {
  const CreateRoutine(this._repository);

  final RoutineRepository _repository;

  Future<Result<RoutineTemplate>> execute({
    required String id,
    required String title,
    required LocalDate startDate,
    required LocalTime targetTime,
    required RecurrenceRule recurrence,
    String? notes,
    LocalDate? endDate,
    int? durationMinutes,
    bool reminderEnabled = true,
    bool isEnabled = true,
  }) {
    final result = RoutineTemplate.create(
      id: id,
      title: title,
      startDate: startDate,
      endDate: endDate,
      targetTime: targetTime,
      recurrence: recurrence,
      durationMinutes: durationMinutes,
      notes: notes,
      reminderEnabled: reminderEnabled,
      isEnabled: isEnabled,
    );

    return switch (result) {
      FailureResult<RoutineTemplate>(:final failure) =>
        Future<Result<RoutineTemplate>>.value(
          FailureResult<RoutineTemplate>(failure),
        ),
      Success<RoutineTemplate>(:final value) => _save(value),
    };
  }

  Future<Result<RoutineTemplate>> _save(RoutineTemplate routine) async {
    final result = await _repository.save(routine);
    return switch (result) {
      Success<Unit>() => Success<RoutineTemplate>(routine),
      FailureResult<Unit>(:final failure) => FailureResult<RoutineTemplate>(
        failure,
      ),
    };
  }
}
