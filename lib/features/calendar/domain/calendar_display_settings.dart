import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/result.dart';

final class CalendarDisplaySettings {
  const CalendarDisplaySettings._({
    required this.startHour,
    required this.endHour,
  });

  static const defaults = CalendarDisplaySettings._(
    startHour: 6,
    endHour: 22,
  );

  final int startHour;
  final int endHour;

  static Result<CalendarDisplaySettings> create({
    required int startHour,
    required int endHour,
  }) {
    if (startHour < 0 ||
        startHour > 22 ||
        endHour < 1 ||
        endHour > 23 ||
        endHour <= startHour) {
      return const FailureResult<CalendarDisplaySettings>(
        ValidationFailure(
          'Calendar hours must start between 12:00 AM and 10:00 PM, '
          'and end after the start no later than 11:00 PM.',
        ),
      );
    }

    return Success<CalendarDisplaySettings>(
      CalendarDisplaySettings._(startHour: startHour, endHour: endHour),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarDisplaySettings &&
        other.startHour == startHour &&
        other.endHour == endHour;
  }

  @override
  int get hashCode => Object.hash(startHour, endHour);
}
