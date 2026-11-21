import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/result.dart';

final class LocalTime implements Comparable<LocalTime> {
  const LocalTime._(this.minutesSinceMidnight);

  final int minutesSinceMidnight;

  static Result<LocalTime> create({required int hour, required int minute}) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return const FailureResult<LocalTime>(
        ValidationFailure('The time must be between 00:00 and 23:59.'),
      );
    }

    return Success<LocalTime>(LocalTime._(hour * 60 + minute));
  }

  static Result<LocalTime> fromMinutesSinceMidnight(int value) {
    if (value < 0 || value >= 24 * 60) {
      return const FailureResult<LocalTime>(
        ValidationFailure('The time must be between 00:00 and 23:59.'),
      );
    }

    return Success<LocalTime>(LocalTime._(value));
  }

  int get hour => minutesSinceMidnight ~/ 60;

  int get minute => minutesSinceMidnight % 60;

  bool isBefore(LocalTime other) => compareTo(other) < 0;

  @override
  int compareTo(LocalTime other) {
    return minutesSinceMidnight.compareTo(other.minutesSinceMidnight);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalTime &&
        other.minutesSinceMidnight == minutesSinceMidnight;
  }

  @override
  int get hashCode => minutesSinceMidnight.hashCode;

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}
