import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/calendar/domain/calendar_display_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to 6:00 AM through 10:00 PM', () {
    expect(CalendarDisplaySettings.defaults.startHour, 6);
    expect(CalendarDisplaySettings.defaults.endHour, 22);
  });

  test('accepts a valid custom display range', () {
    final settings = CalendarDisplaySettings.create(startHour: 8, endHour: 20);

    expect(settings, isA<Success<CalendarDisplaySettings>>());
    final value = (settings as Success<CalendarDisplaySettings>).value;
    expect(value.startHour, 8);
    expect(value.endHour, 20);
  });

  test('accepts the latest supported hours', () {
    expect(
      CalendarDisplaySettings.create(startHour: 22, endHour: 23),
      isA<Success<CalendarDisplaySettings>>(),
    );
  });

  test('rejects invalid or non-increasing display ranges', () {
    expect(
      CalendarDisplaySettings.create(startHour: -1, endHour: 22),
      isA<FailureResult<CalendarDisplaySettings>>(),
    );
    expect(
      CalendarDisplaySettings.create(startHour: 6, endHour: 6),
      isA<FailureResult<CalendarDisplaySettings>>(),
    );
    expect(
      CalendarDisplaySettings.create(startHour: 23, endHour: 24),
      isA<FailureResult<CalendarDisplaySettings>>(),
    );
  });
}
