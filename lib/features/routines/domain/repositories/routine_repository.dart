import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/routines/domain/routine_occurrence_state.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';

abstract interface class RoutineRepository {
  Future<Result<Unit>> save(RoutineTemplate routine);

  Future<Result<List<RoutineTemplate>>> getEnabledRoutines();

  Future<Result<List<RoutineOccurrenceState>>> getOccurrenceStatesAffecting(
    LocalDate date,
  );
}
