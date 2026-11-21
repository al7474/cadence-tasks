import 'package:cadence_tasks/core/application/ports/notification_scheduler.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_one_off_task_repository.dart';
import 'package:cadence_tasks/data/local/drift/drift_routine_repository.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
import 'package:cadence_tasks/features/agenda/domain/daily_agenda_builder.dart';
import 'package:cadence_tasks/features/agenda/presentation/controllers/agenda_actions_controller.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_rule.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/domain_test_factories.dart';

void main() {
  late AppDatabase database;
  late DriftRoutineRepository routines;
  late DriftOneOffTaskRepository tasks;
  late _FakeNotificationScheduler notifications;
  late AgendaActionsController controller;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    routines = DriftRoutineRepository(database);
    tasks = DriftOneOffTaskRepository(database);
    notifications = _FakeNotificationScheduler();
    controller = AgendaActionsController(
      routines: routines,
      oneOffTasks: tasks,
      notifications: notifications,
      clock: () => DateTime(2026, 11, 21, 10),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'completing a moved occurrence keeps it on its destination date',
    () async {
      final originalDate = date(2026, 11, 20);
      final targetDate = date(2026, 11, 21);
      final routine = valueOf(
        RoutineTemplate.create(
          id: 'routine-1',
          title: 'Morning stretch',
          startDate: originalDate,
          targetTime: time(8, 0),
          recurrence: const DailyRecurrence(),
        ),
      );
      await routines.save(routine);
      await routines.saveOccurrenceState(
        occurrenceState(
          routineId: routine.id,
          occurrenceDate: originalDate,
          rescheduledDate: targetDate,
          rescheduledTime: time(9, 0),
        ),
      );

      final agenda = const DailyAgendaBuilder().build(
        forDate: targetDate,
        nowDate: targetDate,
        nowTime: time(8, 0),
        routines: [routine],
        occurrenceStates: valueOf(
          await routines.getOccurrenceStatesAffecting(targetDate),
        ),
        oneOffTasks: const [],
      );
      final movedItem = agenda.upcoming.firstWhere(
        (item) => item.sourceDate == originalDate,
      );

      expect(
        await controller.setStatus(movedItem, TaskStatus.completed),
        isA<Success<Unit>>(),
      );

      final updatedStates = valueOf(
        await routines.getOccurrenceStatesAffecting(targetDate),
      );
      expect(updatedStates.single.status, TaskStatus.completed);
      expect(updatedStates.single.rescheduledDate, targetDate);
      expect(notifications.cancelledItemIds, contains(movedItem.id));
    },
  );

  test('snoozing a one-off task moves it and schedules a reminder', () async {
    final scheduledDate = date(2026, 11, 21);
    final task = oneOffTask(
      id: 'task-1',
      title: 'Call the dentist',
      scheduledDate: scheduledDate,
      scheduledTime: time(9, 0),
    );
    await tasks.save(task);
    final item = AgendaItem(
      id: 'one-off:${task.id}',
      sourceId: task.id,
      sourceDate: task.scheduledDate,
      title: task.title,
      kind: AgendaItemKind.oneOff,
      scheduledDate: task.scheduledDate,
      scheduledTime: task.scheduledTime,
      status: TaskStatus.pending,
      reminderEnabled: task.reminderEnabled,
    );

    expect(await controller.snooze(item), isA<Success<Unit>>());

    final updated = valueOf(await tasks.getScheduledFor(scheduledDate));
    expect(updated.single.scheduledTime, time(10, 10));
    expect(updated.single.reminderEnabled, isTrue);
    expect(updated.single.snoozedUntilUtc, isNotNull);
    expect(notifications.scheduledItems.single.id, item.id);
  });

  test('deleting a one-off task cancels its reminder', () async {
    final scheduledDate = date(2026, 11, 21);
    final task = oneOffTask(
      id: 'task-2',
      title: 'Book a haircut',
      scheduledDate: scheduledDate,
      scheduledTime: time(11, 0),
      reminderEnabled: true,
    );
    await tasks.save(task);
    final item = AgendaItem(
      id: 'one-off:${task.id}',
      sourceId: task.id,
      sourceDate: task.scheduledDate,
      title: task.title,
      kind: AgendaItemKind.oneOff,
      scheduledDate: task.scheduledDate,
      scheduledTime: task.scheduledTime,
      status: TaskStatus.pending,
      reminderEnabled: true,
    );

    expect(await controller.deleteOneOffTask(item), isA<Success<Unit>>());
    expect(valueOf(await tasks.getScheduledFor(scheduledDate)), isEmpty);
    expect(notifications.cancelledItemIds, contains(item.id));
  });
}

final class _FakeNotificationScheduler implements NotificationScheduler {
  final List<AgendaItem> scheduledItems = [];
  final List<String> cancelledItemIds = [];

  @override
  Future<Result<Unit>> initialize({
    required void Function(NotificationAction action) onAction,
  }) async {
    return const Success<Unit>(Unit.value);
  }

  @override
  Future<Result<Unit>> requestPermissions() async {
    return const Success<Unit>(Unit.value);
  }

  @override
  Future<Result<Unit>> scheduleReminder(AgendaItem item) async {
    scheduledItems.add(item);
    return const Success<Unit>(Unit.value);
  }

  @override
  Future<Result<Unit>> cancelReminder(String itemId) async {
    cancelledItemIds.add(itemId);
    return const Success<Unit>(Unit.value);
  }

  @override
  Future<Result<Unit>> cancelRoutineReminders(String routineId) async {
    return const Success<Unit>(Unit.value);
  }
}
