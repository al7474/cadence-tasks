import 'package:cadence_tasks/core/application/ports/notification_scheduler.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
import 'package:cadence_tasks/features/agenda/domain/daily_agenda_builder.dart';
import 'package:cadence_tasks/features/agenda/domain/repositories/daily_agenda_repository.dart';
import 'package:cadence_tasks/features/routines/domain/repositories/routine_repository.dart';
import 'package:cadence_tasks/features/routines/domain/routine_occurrence_state.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';
import 'package:flutter/foundation.dart';

final class ReminderReconciler {
  ReminderReconciler({
    required RoutineRepository routines,
    required DailyAgendaRepository repository,
    required NotificationScheduler scheduler,
    DateTime Function()? clock,
  }) : _routines = routines,
       _repository = repository,
       _scheduler = scheduler,
       _clock = clock ?? DateTime.now;

  static const _horizonDays = 30;

  final DailyAgendaRepository _repository;
  final RoutineRepository _routines;
  final NotificationScheduler _scheduler;
  final DateTime Function() _clock;
  final DailyAgendaBuilder _builder = const DailyAgendaBuilder();

  Future<Result<Unit>> reconcile() async {
    if (kIsWeb) {
      return const Success<Unit>(Unit.value);
    }

    final allRoutinesResult = await _routines.getAllRoutines();
    late final List<RoutineTemplate> allRoutines;
    switch (allRoutinesResult) {
      case FailureResult<List<RoutineTemplate>>(:final failure):
        return FailureResult<Unit>(failure);
      case Success<List<RoutineTemplate>>(:final value):
        allRoutines = value;
    }

    for (final routine in allRoutines) {
      final cancelled = await _scheduler.cancelRoutineReminders(routine.id);
      if (cancelled case FailureResult<Unit>()) {
        return cancelled;
      }
    }

    final routinesResult = await _repository.getEnabledRoutines();
    late final List<RoutineTemplate> routines;
    switch (routinesResult) {
      case FailureResult<List<RoutineTemplate>>(:final failure):
        return FailureResult<Unit>(failure);
      case Success<List<RoutineTemplate>>(:final value):
        routines = value;
    }

    final now = _clock().toLocal();
    final nowDate = LocalDate.fromDateTime(now);
    final nowTimeResult = LocalTime.fromMinutesSinceMidnight(
      now.hour * 60 + now.minute,
    );
    late final LocalTime nowTime;
    switch (nowTimeResult) {
      case FailureResult<LocalTime>(:final failure):
        return FailureResult<Unit>(failure);
      case Success<LocalTime>(:final value):
        nowTime = value;
    }

    for (var offset = 0; offset < _horizonDays; offset++) {
      final date = nowDate.addDays(offset);
      final statesResult = await _repository.getOccurrenceStatesAffecting(date);
      late final List<RoutineOccurrenceState> states;
      switch (statesResult) {
        case FailureResult<List<RoutineOccurrenceState>>(:final failure):
          return FailureResult<Unit>(failure);
        case Success<List<RoutineOccurrenceState>>(:final value):
          states = value;
      }

      final tasksResult = await _repository.getOneOffTasksFor(date);
      late final List<OneOffTask> tasks;
      switch (tasksResult) {
        case FailureResult<List<OneOffTask>>(:final failure):
          return FailureResult<Unit>(failure);
        case Success<List<OneOffTask>>(:final value):
          tasks = value;
      }

      final agenda = _builder.build(
        forDate: date,
        nowDate: nowDate,
        nowTime: nowTime,
        routines: routines,
        occurrenceStates: states,
        oneOffTasks: tasks,
      );
      final items = [
        ...agenda.overdue,
        ...agenda.upcoming,
        ...agenda.completed,
      ];

      for (final item in items) {
        final scheduledAt = _scheduledAt(item);
        final shouldSchedule =
            item.status == TaskStatus.pending &&
            item.reminderEnabled &&
            scheduledAt != null &&
            scheduledAt.isAfter(now);
        final result = shouldSchedule
            ? await _scheduler.scheduleReminder(item)
            : await _scheduler.cancelReminder(item.id);
        if (result case FailureResult<Unit>()) {
          return result;
        }
      }
    }

    return const Success<Unit>(Unit.value);
  }

  static DateTime? _scheduledAt(AgendaItem item) {
    final time = item.scheduledTime;
    if (time == null) {
      return null;
    }
    return DateTime(
      item.scheduledDate.year,
      item.scheduledDate.month,
      item.scheduledDate.day,
      time.hour,
      time.minute,
    );
  }
}
