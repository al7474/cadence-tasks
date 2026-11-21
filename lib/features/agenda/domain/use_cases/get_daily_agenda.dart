import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/agenda/domain/daily_agenda.dart';
import 'package:cadence_tasks/features/agenda/domain/daily_agenda_builder.dart';
import 'package:cadence_tasks/features/agenda/domain/repositories/daily_agenda_repository.dart';
import 'package:cadence_tasks/features/routines/domain/routine_occurrence_state.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';

final class GetDailyAgenda {
  const GetDailyAgenda({
    required DailyAgendaRepository repository,
    DailyAgendaBuilder builder = const DailyAgendaBuilder(),
  })  : _repository = repository,
        _builder = builder;

  final DailyAgendaRepository _repository;
  final DailyAgendaBuilder _builder;

  Future<Result<DailyAgenda>> execute({
    required LocalDate date,
    required LocalDate nowDate,
    required LocalTime nowTime,
  }) async {
    final routinesResult = await _repository.getEnabledRoutines();
    late final List<RoutineTemplate> routines;
    switch (routinesResult) {
      case Success<List<RoutineTemplate>>(:final value):
        routines = value;
        break;
      case FailureResult<List<RoutineTemplate>>(:final failure):
        return FailureResult<DailyAgenda>(failure);
    }

    final statesResult = await _repository.getOccurrenceStatesAffecting(date);
    late final List<RoutineOccurrenceState> states;
    switch (statesResult) {
      case Success<List<RoutineOccurrenceState>>(:final value):
        states = value;
        break;
      case FailureResult<List<RoutineOccurrenceState>>(:final failure):
        return FailureResult<DailyAgenda>(failure);
    }

    final tasksResult = await _repository.getOneOffTasksFor(date);
    late final List<OneOffTask> tasks;
    switch (tasksResult) {
      case Success<List<OneOffTask>>(:final value):
        tasks = value;
        break;
      case FailureResult<List<OneOffTask>>(:final failure):
        return FailureResult<DailyAgenda>(failure);
    }

    return Success<DailyAgenda>(
      _builder.build(
        forDate: date,
        nowDate: nowDate,
        nowTime: nowTime,
        routines: routines,
        occurrenceStates: states,
        oneOffTasks: tasks,
      ),
    );
  }
}
