import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/routines/domain/routine_occurrence_state.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';

abstract interface class DailyAgendaRepository {
  Future<Result<List<RoutineTemplate>>> getEnabledRoutines();

  Future<Result<List<RoutineOccurrenceState>>> getOccurrenceStatesAffecting(
    LocalDate date,
  );

  Future<Result<List<OneOffTask>>> getOneOffTasksFor(LocalDate date);
}
