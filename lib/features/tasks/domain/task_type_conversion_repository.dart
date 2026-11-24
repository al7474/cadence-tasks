import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';

abstract interface class TaskTypeConversionRepository {
  Future<Result<Unit>> convertOneOffTaskToRoutine({
    required OneOffTask source,
    required RoutineTemplate target,
  });

  Future<Result<Unit>> convertRoutineToOneOffTask({
    required RoutineTemplate source,
    required OneOffTask target,
  });
}
