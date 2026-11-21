import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_rule.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';

abstract final class RecurrenceEngine {
  static bool occursOn(RoutineTemplate routine, LocalDate date) {
    if (!routine.isEnabled ||
        date.isBefore(routine.startDate) ||
        (routine.endDate != null && date.isAfter(routine.endDate!))) {
      return false;
    }

    return switch (routine.recurrence) {
      DailyRecurrence() => true,
      WeekdayRecurrence(:final weekdaysIso) => weekdaysIso.contains(
        date.weekday,
      ),
      IntervalRecurrence(:final intervalDays) =>
        date.daysSince(routine.startDate) % intervalDays == 0,
    };
  }

  static Iterable<LocalDate> datesBetween(
    RoutineTemplate routine, {
    required LocalDate start,
    required LocalDate end,
  }) sync* {
    if (end.isBefore(start)) {
      return;
    }

    var date = start;
    while (!date.isAfter(end)) {
      if (occursOn(routine, date)) {
        yield date;
      }
      date = date.addDays(1);
    }
  }
}
