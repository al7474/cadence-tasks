import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/agenda/domain/repositories/daily_agenda_repository.dart';
import 'package:cadence_tasks/features/routines/domain/repositories/routine_repository.dart';
import 'package:cadence_tasks/features/routines/domain/routine_occurrence_state.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';
import 'package:cadence_tasks/features/tasks/domain/repositories/one_off_task_repository.dart';

final class DriftDailyAgendaRepository implements DailyAgendaRepository {
  const DriftDailyAgendaRepository({
    required RoutineRepository routines,
    required OneOffTaskRepository oneOffTasks,
  }) : _routines = routines,
       _oneOffTasks = oneOffTasks;

  final RoutineRepository _routines;
  final OneOffTaskRepository _oneOffTasks;

  @override
  Future<Result<List<RoutineTemplate>>> getEnabledRoutines() {
    return _routines.getEnabledRoutines();
  }

  @override
  Future<Result<List<RoutineOccurrenceState>>> getOccurrenceStatesAffecting(
    LocalDate date,
  ) {
    return _routines.getOccurrenceStatesAffecting(date);
  }

  @override
  Future<Result<List<OneOffTask>>> getOneOffTasksFor(LocalDate date) {
    return _oneOffTasks.getScheduledFor(date);
  }
}
