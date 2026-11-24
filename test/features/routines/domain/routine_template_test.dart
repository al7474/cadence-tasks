import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_rule.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/domain_test_factories.dart';

void main() {
  test('accepts an optional routine duration that ends before midnight', () {
    final routineWithDuration = routine(
      id: 'late-routine',
      title: 'Read',
      startDate: date(2026, 11, 24),
      targetTime: time(22, 0),
      durationMinutes: 120,
    );

    expect(routineWithDuration.durationMinutes, 120);
  });

  test('rejects a routine duration that extends past midnight', () {
    expect(
      RoutineTemplate.create(
        id: 'overnight-routine',
        title: 'Read',
        startDate: date(2026, 11, 24),
        targetTime: time(23, 0),
        recurrence: const DailyRecurrence(),
        durationMinutes: 61,
      ),
      isA<FailureResult<RoutineTemplate>>(),
    );
  });
}
