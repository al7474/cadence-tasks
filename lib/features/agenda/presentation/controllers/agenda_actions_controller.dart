import 'package:cadence_tasks/core/application/ports/notification_scheduler.dart';
import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
import 'package:cadence_tasks/features/routines/domain/repositories/routine_repository.dart';
import 'package:cadence_tasks/features/routines/domain/routine_occurrence_state.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';
import 'package:cadence_tasks/features/tasks/domain/repositories/one_off_task_repository.dart';

final class AgendaActionsController {
  AgendaActionsController({
    required RoutineRepository routines,
    required OneOffTaskRepository oneOffTasks,
    required NotificationScheduler notifications,
    DateTime Function()? clock,
  }) : _routines = routines,
       _oneOffTasks = oneOffTasks,
       _notifications = notifications,
       _clock = clock ?? DateTime.now;

  final RoutineRepository _routines;
  final OneOffTaskRepository _oneOffTasks;
  final NotificationScheduler _notifications;
  final DateTime Function() _clock;

  Future<Result<Unit>> setStatus(AgendaItem item, TaskStatus status) async {
    return switch (item.kind) {
      AgendaItemKind.routine => _setRoutineStatus(item, status),
      AgendaItemKind.oneOff => _setOneOffStatus(item, status),
    };
  }

  Future<Result<Unit>> deleteOneOffTask(AgendaItem item) async {
    if (item.kind != AgendaItemKind.oneOff) {
      return const FailureResult<Unit>(
        ValidationFailure('Only one-off tasks can be deleted from the agenda.'),
      );
    }

    final deleted = await _oneOffTasks.delete(item.sourceId);
    return switch (deleted) {
      FailureResult<Unit>(:final failure) => FailureResult<Unit>(failure),
      Success<Unit>() => _notifications.cancelReminder(item.id),
    };
  }

  Future<Result<Unit>> snooze(AgendaItem item, {int minutes = 10}) async {
    if (minutes < 1) {
      return const FailureResult<Unit>(
        ValidationFailure('Snooze duration must be at least one minute.'),
      );
    }

    final snoozeUntil = _clock().toLocal().add(Duration(minutes: minutes));
    final snoozeDate = LocalDate.fromDateTime(snoozeUntil);
    final snoozeTimeResult = LocalTime.create(
      hour: snoozeUntil.hour,
      minute: snoozeUntil.minute,
    );
    late final LocalTime snoozeTime;
    switch (snoozeTimeResult) {
      case Success<LocalTime>(:final value):
        snoozeTime = value;
        break;
      case FailureResult<LocalTime>(:final failure):
        return FailureResult<Unit>(failure);
    }

    return switch (item.kind) {
      AgendaItemKind.routine => _saveRoutineOccurrence(
        item,
        status: TaskStatus.pending,
        rescheduledDate: snoozeDate,
        rescheduledTime: snoozeTime,
        snoozedUntilUtc: snoozeUntil.toUtc(),
      ),
      AgendaItemKind.oneOff => _updateOneOffTask(
        item,
        status: TaskStatus.pending,
        scheduledDate: snoozeDate,
        scheduledTime: snoozeTime,
        reminderEnabled: true,
        snoozedUntilUtc: snoozeUntil.toUtc(),
      ),
    };
  }

  Future<Result<Unit>> reschedule(
    AgendaItem item, {
    required LocalDate date,
    required LocalTime time,
  }) {
    return switch (item.kind) {
      AgendaItemKind.routine => _saveRoutineOccurrence(
        item,
        status: TaskStatus.pending,
        rescheduledDate: date,
        rescheduledTime: time,
      ),
      AgendaItemKind.oneOff => _updateOneOffTask(
        item,
        status: TaskStatus.pending,
        scheduledDate: date,
        scheduledTime: time,
      ),
    };
  }

  Future<Result<Unit>> _setRoutineStatus(
    AgendaItem item,
    TaskStatus status,
  ) async {
    final statesResult = await _routines.getOccurrenceStatesAffecting(
      item.scheduledDate,
    );
    switch (statesResult) {
      case FailureResult<List<RoutineOccurrenceState>>(:final failure):
        return FailureResult<Unit>(failure);
      case Success<List<RoutineOccurrenceState>>(:final value):
        return _saveRoutineOccurrence(
          item,
          status: status,
          existing: _findOccurrence(item, value),
        );
    }
  }

  Future<Result<Unit>> _saveRoutineOccurrence(
    AgendaItem item, {
    required TaskStatus status,
    RoutineOccurrenceState? existing,
    LocalDate? rescheduledDate,
    LocalTime? rescheduledTime,
    DateTime? snoozedUntilUtc,
  }) async {
    final stateResult = RoutineOccurrenceState.create(
      routineId: item.sourceId,
      occurrenceDate: item.sourceDate,
      status: status,
      completedAtUtc: status == TaskStatus.completed ? _clock().toUtc() : null,
      snoozedUntilUtc: status == TaskStatus.pending
          ? snoozedUntilUtc ?? existing?.snoozedUntilUtc
          : null,
      rescheduledDate:
          rescheduledDate ?? existing?.rescheduledDate ?? _dateIfMoved(item),
      rescheduledTime:
          rescheduledTime ?? existing?.rescheduledTime ?? _timeIfMoved(item),
    );

    late final RoutineOccurrenceState state;
    switch (stateResult) {
      case FailureResult<RoutineOccurrenceState>(:final failure):
        return FailureResult<Unit>(failure);
      case Success<RoutineOccurrenceState>(:final value):
        state = value;
    }

    final saved = await _routines.saveOccurrenceState(state);
    if (saved case FailureResult<Unit>()) {
      return saved;
    }

    final shouldSchedule =
        status == TaskStatus.pending &&
        (item.reminderEnabled || state.snoozedUntilUtc != null);
    if (!shouldSchedule) {
      return _notifications.cancelReminder(item.id);
    }

    return _notifications.scheduleReminder(
      AgendaItem(
        id: item.id,
        sourceId: item.sourceId,
        sourceDate: item.sourceDate,
        title: item.title,
        kind: item.kind,
        scheduledDate: state.rescheduledDate ?? item.scheduledDate,
        scheduledTime: state.rescheduledTime ?? item.scheduledTime,
        status: state.status,
        reminderEnabled: true,
        snoozedUntilUtc: state.snoozedUntilUtc,
      ),
    );
  }

  Future<Result<Unit>> _setOneOffStatus(AgendaItem item, TaskStatus status) {
    return _updateOneOffTask(item, status: status);
  }

  Future<Result<Unit>> _updateOneOffTask(
    AgendaItem item, {
    required TaskStatus status,
    LocalDate? scheduledDate,
    LocalTime? scheduledTime,
    bool? reminderEnabled,
    DateTime? snoozedUntilUtc,
  }) async {
    final tasksResult = await _oneOffTasks.getScheduledFor(item.sourceDate);
    late final OneOffTask task;
    switch (tasksResult) {
      case FailureResult<List<OneOffTask>>(:final failure):
        return FailureResult<Unit>(failure);
      case Success<List<OneOffTask>>(:final value):
        final matchingTasks = value.where((task) => task.id == item.sourceId);
        if (matchingTasks.isEmpty) {
          return FailureResult<Unit>(
            NotFoundFailure('Task ${item.sourceId} was not found.'),
          );
        }
        task = matchingTasks.first;
    }

    final updatedTaskResult = OneOffTask.create(
      id: task.id,
      title: task.title,
      notes: task.notes,
      scheduledDate: scheduledDate ?? task.scheduledDate,
      scheduledTime: scheduledTime ?? task.scheduledTime,
      reminderEnabled: reminderEnabled ?? task.reminderEnabled,
      status: status,
      completedAtUtc: status == TaskStatus.completed ? _clock().toUtc() : null,
      snoozedUntilUtc: status == TaskStatus.pending ? snoozedUntilUtc : null,
    );
    late final OneOffTask updatedTask;
    switch (updatedTaskResult) {
      case FailureResult<OneOffTask>(:final failure):
        return FailureResult<Unit>(failure);
      case Success<OneOffTask>(:final value):
        updatedTask = value;
    }

    final saved = await _oneOffTasks.save(updatedTask);
    if (saved case FailureResult<Unit>()) {
      return saved;
    }

    if (status != TaskStatus.pending || !updatedTask.reminderEnabled) {
      return _notifications.cancelReminder(item.id);
    }

    return _notifications.scheduleReminder(
      AgendaItem(
        id: item.id,
        sourceId: updatedTask.id,
        sourceDate: updatedTask.scheduledDate,
        title: updatedTask.title,
        kind: AgendaItemKind.oneOff,
        scheduledDate: updatedTask.scheduledDate,
        scheduledTime: updatedTask.scheduledTime,
        status: updatedTask.status,
        reminderEnabled: updatedTask.reminderEnabled,
        snoozedUntilUtc: updatedTask.snoozedUntilUtc,
      ),
    );
  }

  static RoutineOccurrenceState? _findOccurrence(
    AgendaItem item,
    Iterable<RoutineOccurrenceState> states,
  ) {
    for (final state in states) {
      if (state.routineId == item.sourceId &&
          state.occurrenceDate == item.sourceDate) {
        return state;
      }
    }
    return null;
  }

  static LocalDate? _dateIfMoved(AgendaItem item) {
    return item.scheduledDate == item.sourceDate ? null : item.scheduledDate;
  }

  static LocalTime? _timeIfMoved(AgendaItem item) {
    return item.scheduledDate == item.sourceDate ? null : item.scheduledTime;
  }
}
