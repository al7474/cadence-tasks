import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_engine.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_rule.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/domain_test_factories.dart';

void main() {
  group('RecurrenceEngine', () {
    test(
      'daily recurrence includes its start date and respects its end date',
      () {
        final start = date(2026, 1, 10);
        final end = date(2026, 1, 12);
        final daily = routine(
          id: 'daily',
          title: 'Daily routine',
          startDate: start,
          endDate: end,
          targetTime: time(8, 0),
        );

        expect(RecurrenceEngine.occursOn(daily, date(2026, 1, 9)), isFalse);
        expect(RecurrenceEngine.occursOn(daily, start), isTrue);
        expect(RecurrenceEngine.occursOn(daily, end), isTrue);
        expect(RecurrenceEngine.occursOn(daily, date(2026, 1, 13)), isFalse);
      },
    );

    test('weekday recurrence uses ISO weekday numbers', () {
      final weekdays = valueOf(WeekdayRecurrence.create({DateTime.monday, 3}));
      final weekly = routine(
        id: 'weekly',
        title: 'Weekday routine',
        startDate: date(2026, 1, 5),
        targetTime: time(9, 0),
        recurrence: weekdays,
      );

      expect(RecurrenceEngine.occursOn(weekly, date(2026, 1, 5)), isTrue);
      expect(RecurrenceEngine.occursOn(weekly, date(2026, 1, 7)), isTrue);
      expect(RecurrenceEngine.occursOn(weekly, date(2026, 1, 6)), isFalse);
    });

    test('interval recurrence remains anchored to its start date', () {
      final interval = valueOf(IntervalRecurrence.create(3));
      final routineWithInterval = routine(
        id: 'interval',
        title: 'Every third day',
        startDate: date(2026, 1, 1),
        targetTime: time(7, 30),
        recurrence: interval,
      );

      expect(
        RecurrenceEngine.occursOn(routineWithInterval, date(2026, 1, 1)),
        isTrue,
      );
      expect(
        RecurrenceEngine.occursOn(routineWithInterval, date(2026, 1, 4)),
        isTrue,
      );
      expect(
        RecurrenceEngine.occursOn(routineWithInterval, date(2026, 1, 5)),
        isFalse,
      );
      expect(
        RecurrenceEngine.occursOn(routineWithInterval, date(2025, 12, 31)),
        isFalse,
      );
    });

    test('disabled routines do not produce occurrences', () {
      final disabledRoutine = routine(
        id: 'disabled',
        title: 'Disabled routine',
        startDate: date(2026, 1, 1),
        targetTime: time(10, 0),
        isEnabled: false,
      );

      expect(
        RecurrenceEngine.occursOn(disabledRoutine, date(2026, 1, 1)),
        isFalse,
      );
    });

    test('date ranges return only matching dates', () {
      final everyOtherDay = routine(
        id: 'interval',
        title: 'Every other day',
        startDate: date(2026, 2, 1),
        targetTime: time(10, 0),
        recurrence: valueOf(IntervalRecurrence.create(2)),
      );

      expect(
        RecurrenceEngine.datesBetween(
          everyOtherDay,
          start: date(2026, 2, 1),
          end: date(2026, 2, 5),
        ).toList(),
        <LocalDate>[date(2026, 2, 1), date(2026, 2, 3), date(2026, 2, 5)],
      );
    });

    test('invalid recurrence rules return validation failures', () {
      expect(
        IntervalRecurrence.create(0),
        isA<FailureResult<IntervalRecurrence>>(),
      );
      expect(
        WeekdayRecurrence.create({}),
        isA<FailureResult<WeekdayRecurrence>>(),
      );
      expect(
        WeekdayRecurrence.create({DateTime.sunday + 1}),
        isA<FailureResult<WeekdayRecurrence>>(),
      );
    });

    test('invalid calendar dates are rejected', () {
      expect(
        LocalDate.create(year: 2026, month: 2, day: 30),
        isA<FailureResult<LocalDate>>(),
      );
    });
  });
}
