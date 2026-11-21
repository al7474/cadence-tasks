import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/result.dart';

sealed class RecurrenceRule {
  const RecurrenceRule();
}

final class DailyRecurrence extends RecurrenceRule {
  const DailyRecurrence();
}

final class WeekdayRecurrence extends RecurrenceRule {
  WeekdayRecurrence._(Iterable<int> weekdaysIso)
    : weekdaysIso = Set<int>.unmodifiable(weekdaysIso);

  final Set<int> weekdaysIso;

  static Result<WeekdayRecurrence> create(Iterable<int> weekdaysIso) {
    final weekdays = weekdaysIso.toSet();
    if (weekdays.isEmpty ||
        weekdays.any(
          (weekday) => weekday < DateTime.monday || weekday > DateTime.sunday,
        )) {
      return const FailureResult<WeekdayRecurrence>(
        ValidationFailure('Select at least one valid ISO weekday.'),
      );
    }

    return Success<WeekdayRecurrence>(WeekdayRecurrence._(weekdays));
  }
}

final class IntervalRecurrence extends RecurrenceRule {
  const IntervalRecurrence._(this.intervalDays);

  final int intervalDays;

  static Result<IntervalRecurrence> create(int intervalDays) {
    if (intervalDays < 1) {
      return const FailureResult<IntervalRecurrence>(
        ValidationFailure('The recurrence interval must be at least one day.'),
      );
    }

    return Success<IntervalRecurrence>(IntervalRecurrence._(intervalDays));
  }
}
