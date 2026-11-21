import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/result.dart';

final class LocalDate implements Comparable<LocalDate> {
  const LocalDate._(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  static Result<LocalDate> create({
    required int year,
    required int month,
    required int day,
  }) {
    if (year < 1 ||
        year > 9999 ||
        month < 1 ||
        month > 12 ||
        day < 1 ||
        day > 31) {
      return const FailureResult<LocalDate>(
        ValidationFailure('The date is not a valid calendar date.'),
      );
    }

    final normalized = DateTime.utc(year, month, day);
    if (normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      return const FailureResult<LocalDate>(
        ValidationFailure('The date is not a valid calendar date.'),
      );
    }

    return Success<LocalDate>(LocalDate._(year, month, day));
  }

  static Result<LocalDate> parse(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      return const FailureResult<LocalDate>(
        ValidationFailure('The date must use YYYY-MM-DD format.'),
      );
    }

    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    if (year == null || month == null || day == null) {
      return const FailureResult<LocalDate>(
        ValidationFailure('The date must use YYYY-MM-DD format.'),
      );
    }

    return create(year: year, month: month, day: day);
  }

  static LocalDate fromDateTime(DateTime value) {
    return LocalDate._(value.year, value.month, value.day);
  }

  int get weekday => DateTime.utc(year, month, day).weekday;

  LocalDate addDays(int days) {
    final value = DateTime.utc(year, month, day).add(Duration(days: days));
    return LocalDate._(value.year, value.month, value.day);
  }

  int daysSince(LocalDate other) {
    return DateTime.utc(year, month, day)
        .difference(DateTime.utc(other.year, other.month, other.day))
        .inDays;
  }

  bool isBefore(LocalDate other) => compareTo(other) < 0;

  bool isAfter(LocalDate other) => compareTo(other) > 0;

  String get iso8601 => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDate other) {
    final yearComparison = year.compareTo(other.year);
    if (yearComparison != 0) {
      return yearComparison;
    }

    final monthComparison = month.compareTo(other.month);
    if (monthComparison != 0) {
      return monthComparison;
    }

    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalDate &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso8601;
}
