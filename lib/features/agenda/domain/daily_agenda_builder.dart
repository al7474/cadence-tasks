import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
import 'package:cadence_tasks/features/agenda/domain/daily_agenda.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_engine.dart';
import 'package:cadence_tasks/features/routines/domain/routine_occurrence_state.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';

final class DailyAgendaBuilder {
  const DailyAgendaBuilder();

  DailyAgenda build({
    required LocalDate forDate,
    required LocalDate nowDate,
    required LocalTime nowTime,
    required Iterable<RoutineTemplate> routines,
    required Iterable<RoutineOccurrenceState> occurrenceStates,
    required Iterable<OneOffTask> oneOffTasks,
  }) {
    final routineList = routines.toList(growable: false);
    final states = occurrenceStates.toList(growable: false);
    final routinesById = <String, RoutineTemplate>{
      for (final routine in routineList) routine.id: routine,
    };
    final statesByKey = <String, RoutineOccurrenceState>{
      for (final state in states)
        _stateKey(state.routineId, state.occurrenceDate): state,
    };
    final items = <AgendaItem>[];

    for (final routine in routineList) {
      if (!RecurrenceEngine.occursOn(routine, forDate)) {
        continue;
      }

      final state = statesByKey[_stateKey(routine.id, forDate)];
      final rescheduledDate = state?.rescheduledDate;
      if (rescheduledDate != null && rescheduledDate != forDate) {
        continue;
      }

      items.add(
        AgendaItem(
          id: _routineItemId(routine.id, forDate),
          sourceId: routine.id,
          sourceDate: forDate,
          title: routine.title,
          kind: AgendaItemKind.routine,
          scheduledDate: state?.rescheduledDate ?? forDate,
          scheduledTime: state?.rescheduledTime ?? routine.targetTime,
          status: state?.status ?? TaskStatus.pending,
          reminderEnabled: routine.reminderEnabled,
          snoozedUntilUtc: state?.snoozedUntilUtc,
        ),
      );
    }

    for (final state in states) {
      if (state.rescheduledDate != forDate || state.occurrenceDate == forDate) {
        continue;
      }

      final routine = routinesById[state.routineId];
      if (routine == null || !routine.isEnabled) {
        continue;
      }

      items.add(
        AgendaItem(
          id: _routineItemId(routine.id, state.occurrenceDate),
          sourceId: routine.id,
          sourceDate: state.occurrenceDate,
          title: routine.title,
          kind: AgendaItemKind.routine,
          scheduledDate: forDate,
          scheduledTime: state.rescheduledTime ?? routine.targetTime,
          status: state.status,
          reminderEnabled: routine.reminderEnabled,
          snoozedUntilUtc: state.snoozedUntilUtc,
        ),
      );
    }

    for (final task in oneOffTasks) {
      if (task.scheduledDate != forDate) {
        continue;
      }

      items.add(
        AgendaItem(
          id: 'one-off:${task.id}',
          sourceId: task.id,
          sourceDate: task.scheduledDate,
          title: task.title,
          kind: AgendaItemKind.oneOff,
          scheduledDate: task.scheduledDate,
          scheduledTime: task.scheduledTime,
          status: task.status,
          reminderEnabled: task.reminderEnabled,
          snoozedUntilUtc: task.snoozedUntilUtc,
        ),
      );
    }

    final overdue = <AgendaItem>[];
    final upcoming = <AgendaItem>[];
    final completed = <AgendaItem>[];

    for (final item in items) {
      if (item.status == TaskStatus.completed ||
          item.status == TaskStatus.skipped) {
        completed.add(item);
      } else if (_isOverdue(item, nowDate, nowTime)) {
        overdue.add(item);
      } else {
        upcoming.add(item);
      }
    }

    overdue.sort(_compareBySchedule);
    upcoming.sort(_compareBySchedule);
    completed.sort(_compareBySchedule);

    return DailyAgenda(
      overdue: overdue,
      upcoming: upcoming,
      completed: completed,
    );
  }

  static bool _isOverdue(
    AgendaItem item,
    LocalDate nowDate,
    LocalTime nowTime,
  ) {
    if (item.scheduledDate.isBefore(nowDate)) {
      return true;
    }
    final scheduledTime = item.scheduledTime;
    return item.scheduledDate == nowDate &&
        scheduledTime != null &&
        scheduledTime.isBefore(nowTime);
  }

  static int _compareBySchedule(AgendaItem first, AgendaItem second) {
    final firstTime = first.scheduledTime;
    final secondTime = second.scheduledTime;
    if (firstTime == null && secondTime != null) {
      return 1;
    }
    if (firstTime != null && secondTime == null) {
      return -1;
    }
    if (firstTime != null && secondTime != null) {
      final timeComparison = firstTime.compareTo(secondTime);
      if (timeComparison != 0) {
        return timeComparison;
      }
    }

    final titleComparison = first.title.compareTo(second.title);
    return titleComparison != 0
        ? titleComparison
        : first.id.compareTo(second.id);
  }

  static String _stateKey(String routineId, LocalDate date) {
    return '$routineId:${date.iso8601}';
  }

  static String _routineItemId(String routineId, LocalDate occurrenceDate) {
    return 'routine:$routineId:${occurrenceDate.iso8601}';
  }
}
