import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';
import 'package:cadence_tasks/features/tasks/domain/repositories/one_off_task_repository.dart';

final class CreateOneOffTask {
  const CreateOneOffTask(this._repository);

  final OneOffTaskRepository _repository;

  Future<Result<OneOffTask>> execute({
    required String id,
    required String title,
    required LocalDate scheduledDate,
    LocalTime? scheduledTime,
    int? durationMinutes,
    bool reminderEnabled = false,
    String? notes,
  }) {
    final result = OneOffTask.create(
      id: id,
      title: title,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      durationMinutes: durationMinutes,
      reminderEnabled: reminderEnabled,
      notes: notes,
    );

    return switch (result) {
      FailureResult<OneOffTask>(:final failure) =>
        Future<Result<OneOffTask>>.value(FailureResult<OneOffTask>(failure)),
      Success<OneOffTask>(:final value) => _save(value),
    };
  }

  Future<Result<OneOffTask>> _save(OneOffTask task) async {
    final result = await _repository.save(task);
    return switch (result) {
      Success<Unit>() => Success<OneOffTask>(task),
      FailureResult<Unit>(:final failure) => FailureResult<OneOffTask>(failure),
    };
  }
}
