import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
import 'package:cadence_tasks/features/agenda/domain/daily_agenda_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/domain_test_factories.dart';

void main() {
  group('DailyAgendaBuilder', () {
    test('merges routines and one-off tasks into ordered status groups', () {
      final today = date(2026, 11, 21);
      final routines = [
        routine(
          id: 'early',
          title: 'Early routine',
          startDate: today,
          targetTime: time(8, 0),
        ),
        routine(
          id: 'upcoming',
          title: 'Upcoming routine',
          startDate: today,
          targetTime: time(10, 0),
        ),
        routine(
          id: 'done',
          title: 'Completed routine',
          startDate: today,
          targetTime: time(11, 0),
        ),
        routine(
          id: 'skipped',
          title: 'Skipped routine',
          startDate: today,
          targetTime: time(12, 0),
        ),
      ];
      final states = [
        occurrenceState(
          routineId: 'done',
          occurrenceDate: today,
          status: TaskStatus.completed,
          completedAtUtc: DateTime.utc(2026, 11, 21, 12),
        ),
        occurrenceState(
          routineId: 'skipped',
          occurrenceDate: today,
          status: TaskStatus.skipped,
        ),
      ];
      final tasks = [
        oneOffTask(
          id: 'early-task',
          title: 'Early task',
          scheduledDate: today,
          scheduledTime: time(8, 30),
        ),
        oneOffTask(
          id: 'untimed-task',
          title: 'Untimed task',
          scheduledDate: today,
        ),
      ];

      final agenda = const DailyAgendaBuilder().build(
        forDate: today,
        nowDate: today,
        nowTime: time(9, 0),
        routines: routines,
        occurrenceStates: states,
        oneOffTasks: tasks,
      );

      expect(agenda.overdue.map((item) => item.title).toList(), [
        'Early routine',
        'Early task',
      ]);
      expect(agenda.upcoming.map((item) => item.title).toList(), [
        'Upcoming routine',
        'Untimed task',
      ]);
      expect(agenda.completed.map((item) => item.title).toList(), [
        'Completed routine',
        'Skipped routine',
      ]);
    });

    test('moves a rescheduled occurrence without dropping the regular one', () {
      final originalDate = date(2026, 11, 20);
      final targetDate = date(2026, 11, 21);
      final dailyRoutine = routine(
        id: 'routine',
        title: 'Daily routine',
        startDate: originalDate,
        targetTime: time(10, 0),
      );
      final movedOccurrence = occurrenceState(
        routineId: dailyRoutine.id,
        occurrenceDate: originalDate,
        rescheduledDate: targetDate,
        rescheduledTime: time(9, 30),
      );

      final originalAgenda = const DailyAgendaBuilder().build(
        forDate: originalDate,
        nowDate: originalDate,
        nowTime: time(8, 0),
        routines: [dailyRoutine],
        occurrenceStates: [movedOccurrence],
        oneOffTasks: const [],
      );
      final targetAgenda = const DailyAgendaBuilder().build(
        forDate: targetDate,
        nowDate: originalDate,
        nowTime: time(8, 0),
        routines: [dailyRoutine],
        occurrenceStates: [movedOccurrence],
        oneOffTasks: const [],
      );

      expect(originalAgenda.upcoming, isEmpty);
      expect(targetAgenda.upcoming, hasLength(2));
      expect(targetAgenda.upcoming.first.scheduledTime, time(9, 30));
      expect(targetAgenda.upcoming.map((item) => item.id).toSet(), {
        'routine:routine:2026-11-20',
        'routine:routine:2026-11-21',
      });
    });

    test(
      'keeps a completed rescheduled occurrence on its destination date',
      () {
        final originalDate = date(2026, 11, 20);
        final targetDate = date(2026, 11, 21);
        final dailyRoutine = routine(
          id: 'routine',
          title: 'Daily routine',
          startDate: originalDate,
          targetTime: time(10, 0),
        );
        final completedOccurrence = occurrenceState(
          routineId: dailyRoutine.id,
          occurrenceDate: originalDate,
          status: TaskStatus.completed,
          completedAtUtc: DateTime.utc(2026, 11, 21, 10),
          rescheduledDate: targetDate,
          rescheduledTime: time(9, 30),
        );

        final originalAgenda = const DailyAgendaBuilder().build(
          forDate: originalDate,
          nowDate: targetDate,
          nowTime: time(11, 0),
          routines: [dailyRoutine],
          occurrenceStates: [completedOccurrence],
          oneOffTasks: const [],
        );
        final targetAgenda = const DailyAgendaBuilder().build(
          forDate: targetDate,
          nowDate: targetDate,
          nowTime: time(11, 0),
          routines: [dailyRoutine],
          occurrenceStates: [completedOccurrence],
          oneOffTasks: const [],
        );

        expect(originalAgenda.upcoming, isEmpty);
        expect(targetAgenda.completed, hasLength(1));
        expect(targetAgenda.completed.single.scheduledDate, targetDate);
        expect(targetAgenda.completed.single.sourceDate, originalDate);
      },
    );

    test('returns an empty agenda when there are no scheduled items', () {
      final today = date(2026, 11, 21);
      final agenda = const DailyAgendaBuilder().build(
        forDate: today,
        nowDate: today,
        nowTime: time(9, 0),
        routines: const [],
        occurrenceStates: const [],
        oneOffTasks: const [],
      );

      expect(agenda.isEmpty, isTrue);
      expect(agenda.overdue, isEmpty);
      expect(agenda.upcoming, isEmpty);
      expect(agenda.completed, isEmpty);
    });

    test('keeps task kinds identifiable after merging', () {
      final today = date(2026, 11, 21);
      final agenda = const DailyAgendaBuilder().build(
        forDate: today,
        nowDate: today,
        nowTime: time(7, 0),
        routines: [
          routine(
            id: 'routine',
            title: 'Routine',
            startDate: today,
            targetTime: time(8, 0),
          ),
        ],
        occurrenceStates: const [],
        oneOffTasks: [
          oneOffTask(
            id: 'task',
            title: 'Task',
            scheduledDate: today,
            scheduledTime: time(9, 0),
          ),
        ],
      );

      expect(agenda.upcoming[0].kind, AgendaItemKind.routine);
      expect(agenda.upcoming[1].kind, AgendaItemKind.oneOff);
    });
  });
}
