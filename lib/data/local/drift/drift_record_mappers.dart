import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_rule.dart';
import 'package:cadence_tasks/features/routines/domain/routine_occurrence_state.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';
import 'package:drift/drift.dart';

abstract final class DriftRecordMappers {
  static RoutineTemplatesCompanion routineToCompanion({
    required RoutineTemplate routine,
    required String userId,
    required DateTime updatedAtUtc,
    required String mutationId,
    DateTime? deletedAtUtc,
  }) {
    final recurrence = _encodeRecurrence(routine.recurrence);

    return RoutineTemplatesCompanion.insert(
      userId: userId,
      id: routine.id,
      title: routine.title,
      notes: Value<String?>(routine.notes),
      startDate: routine.startDate.iso8601,
      endDate: Value<String?>(routine.endDate?.iso8601),
      targetTimeMinutes: routine.targetTime.minutesSinceMidnight,
      recurrenceKind: recurrence.kind,
      weekdaysMask: Value<int>(recurrence.weekdaysMask),
      intervalDays: Value<int?>(recurrence.intervalDays),
      reminderEnabled: Value<bool>(routine.reminderEnabled),
      isEnabled: Value<bool>(routine.isEnabled),
      updatedAtUtcMillis: updatedAtUtc.millisecondsSinceEpoch,
      deletedAtUtcMillis: Value<int?>(deletedAtUtc?.millisecondsSinceEpoch),
      mutationId: mutationId,
    );
  }

  static RoutineOccurrenceLogsCompanion occurrenceToCompanion({
    required RoutineOccurrenceState state,
    required String userId,
    required DateTime updatedAtUtc,
    required String mutationId,
    DateTime? deletedAtUtc,
  }) {
    return RoutineOccurrenceLogsCompanion.insert(
      userId: userId,
      routineId: state.routineId,
      occurrenceDate: state.occurrenceDate.iso8601,
      status: state.status.name,
      completedAtUtcMillis: Value<int?>(
        state.completedAtUtc?.millisecondsSinceEpoch,
      ),
      snoozedUntilUtcMillis: Value<int?>(
        state.snoozedUntilUtc?.millisecondsSinceEpoch,
      ),
      rescheduledDate: Value<String?>(state.rescheduledDate?.iso8601),
      rescheduledTimeMinutes: Value<int?>(
        state.rescheduledTime?.minutesSinceMidnight,
      ),
      updatedAtUtcMillis: updatedAtUtc.millisecondsSinceEpoch,
      deletedAtUtcMillis: Value<int?>(deletedAtUtc?.millisecondsSinceEpoch),
      mutationId: mutationId,
    );
  }

  static OneOffTasksCompanion oneOffTaskToCompanion({
    required OneOffTask task,
    required String userId,
    required DateTime updatedAtUtc,
    required String mutationId,
    DateTime? deletedAtUtc,
  }) {
    return OneOffTasksCompanion.insert(
      userId: userId,
      id: task.id,
      title: task.title,
      notes: Value<String?>(task.notes),
      scheduledDate: task.scheduledDate.iso8601,
      scheduledTimeMinutes: Value<int?>(
        task.scheduledTime?.minutesSinceMidnight,
      ),
      reminderEnabled: Value<bool>(task.reminderEnabled),
      status: task.status.name,
      completedAtUtcMillis: Value<int?>(
        task.completedAtUtc?.millisecondsSinceEpoch,
      ),
      snoozedUntilUtcMillis: Value<int?>(
        task.snoozedUntilUtc?.millisecondsSinceEpoch,
      ),
      updatedAtUtcMillis: updatedAtUtc.millisecondsSinceEpoch,
      deletedAtUtcMillis: Value<int?>(deletedAtUtc?.millisecondsSinceEpoch),
      mutationId: mutationId,
    );
  }

  static RoutineTemplate routineFromRow(RoutineTemplateRow row) {
    final result = RoutineTemplate.create(
      id: row.id,
      title: row.title,
      notes: row.notes,
      startDate: _dateFromString(row.startDate),
      endDate: row.endDate == null ? null : _dateFromString(row.endDate!),
      targetTime: _timeFromMinutes(row.targetTimeMinutes),
      recurrence: _decodeRecurrence(
        row.recurrenceKind,
        row.weekdaysMask,
        row.intervalDays,
      ),
      reminderEnabled: row.reminderEnabled,
      isEnabled: row.isEnabled,
    );

    return _requireValidRow(result);
  }

  static RoutineOccurrenceState occurrenceFromRow(RoutineOccurrenceLogRow row) {
    final result = RoutineOccurrenceState.create(
      routineId: row.routineId,
      occurrenceDate: _dateFromString(row.occurrenceDate),
      status: _statusFromString(row.status),
      completedAtUtc: _dateTimeFromMillis(row.completedAtUtcMillis),
      snoozedUntilUtc: _dateTimeFromMillis(row.snoozedUntilUtcMillis),
      rescheduledDate: row.rescheduledDate == null
          ? null
          : _dateFromString(row.rescheduledDate!),
      rescheduledTime: row.rescheduledTimeMinutes == null
          ? null
          : _timeFromMinutes(row.rescheduledTimeMinutes!),
    );

    return _requireValidRow(result);
  }

  static OneOffTask oneOffTaskFromRow(OneOffTaskRow row) {
    final result = OneOffTask.create(
      id: row.id,
      title: row.title,
      notes: row.notes,
      scheduledDate: _dateFromString(row.scheduledDate),
      scheduledTime: row.scheduledTimeMinutes == null
          ? null
          : _timeFromMinutes(row.scheduledTimeMinutes!),
      reminderEnabled: row.reminderEnabled,
      status: _statusFromString(row.status),
      completedAtUtc: _dateTimeFromMillis(row.completedAtUtcMillis),
      snoozedUntilUtc: _dateTimeFromMillis(row.snoozedUntilUtcMillis),
    );

    return _requireValidRow(result);
  }

  static RoutineTemplate routineFromPayload(Map<String, dynamic> payload) {
    final result = RoutineTemplate.create(
      id: _requiredString(payload, 'id'),
      title: _requiredString(payload, 'title'),
      notes: _optionalString(payload, 'notes'),
      startDate: _dateFromString(_requiredString(payload, 'startDate')),
      endDate: _optionalString(payload, 'endDate') == null
          ? null
          : _dateFromString(_optionalString(payload, 'endDate')!),
      targetTime: _timeFromMinutes(_requiredInt(payload, 'targetTimeMinutes')),
      recurrence: _decodeRecurrence(
        _requiredString(payload, 'recurrenceKind'),
        _requiredInt(payload, 'weekdaysMask'),
        _optionalInt(payload, 'intervalDays'),
      ),
      reminderEnabled: _requiredBool(payload, 'reminderEnabled'),
      isEnabled: _requiredBool(payload, 'isEnabled'),
    );

    return _requireValidRow(result);
  }

  static RoutineOccurrenceState occurrenceFromPayload(
    Map<String, dynamic> payload,
  ) {
    final result = RoutineOccurrenceState.create(
      routineId: _requiredString(payload, 'routineId'),
      occurrenceDate: _dateFromString(
        _requiredString(payload, 'occurrenceDate'),
      ),
      status: _statusFromString(_requiredString(payload, 'status')),
      completedAtUtc: _dateTimeFromMillis(
        _optionalInt(payload, 'completedAtUtcMillis'),
      ),
      snoozedUntilUtc: _dateTimeFromMillis(
        _optionalInt(payload, 'snoozedUntilUtcMillis'),
      ),
      rescheduledDate: _optionalString(payload, 'rescheduledDate') == null
          ? null
          : _dateFromString(_optionalString(payload, 'rescheduledDate')!),
      rescheduledTime: _optionalInt(payload, 'rescheduledTimeMinutes') == null
          ? null
          : _timeFromMinutes(_optionalInt(payload, 'rescheduledTimeMinutes')!),
    );

    return _requireValidRow(result);
  }

  static OneOffTask oneOffTaskFromPayload(Map<String, dynamic> payload) {
    final result = OneOffTask.create(
      id: _requiredString(payload, 'id'),
      title: _requiredString(payload, 'title'),
      notes: _optionalString(payload, 'notes'),
      scheduledDate: _dateFromString(_requiredString(payload, 'scheduledDate')),
      scheduledTime: _optionalInt(payload, 'scheduledTimeMinutes') == null
          ? null
          : _timeFromMinutes(_optionalInt(payload, 'scheduledTimeMinutes')!),
      reminderEnabled: _requiredBool(payload, 'reminderEnabled'),
      status: _statusFromString(_requiredString(payload, 'status')),
      completedAtUtc: _dateTimeFromMillis(
        _optionalInt(payload, 'completedAtUtcMillis'),
      ),
      snoozedUntilUtc: _dateTimeFromMillis(
        _optionalInt(payload, 'snoozedUntilUtcMillis'),
      ),
    );

    return _requireValidRow(result);
  }

  static Map<String, Object?> routinePayload({
    required RoutineTemplate routine,
    required String userId,
    required DateTime updatedAtUtc,
    required String mutationId,
    DateTime? deletedAtUtc,
  }) {
    final recurrence = _encodeRecurrence(routine.recurrence);

    return {
      'userId': userId,
      'id': routine.id,
      'title': routine.title,
      'notes': routine.notes,
      'startDate': routine.startDate.iso8601,
      'endDate': routine.endDate?.iso8601,
      'targetTimeMinutes': routine.targetTime.minutesSinceMidnight,
      'recurrenceKind': recurrence.kind,
      'weekdaysMask': recurrence.weekdaysMask,
      'intervalDays': recurrence.intervalDays,
      'reminderEnabled': routine.reminderEnabled,
      'isEnabled': routine.isEnabled,
      'updatedAtUtcMillis': updatedAtUtc.millisecondsSinceEpoch,
      'deletedAtUtcMillis': deletedAtUtc?.millisecondsSinceEpoch,
      'mutationId': mutationId,
    };
  }

  static Map<String, Object?> occurrencePayload({
    required RoutineOccurrenceState state,
    required String userId,
    required DateTime updatedAtUtc,
    required String mutationId,
  }) {
    return {
      'userId': userId,
      'routineId': state.routineId,
      'occurrenceDate': state.occurrenceDate.iso8601,
      'status': state.status.name,
      'completedAtUtcMillis': state.completedAtUtc?.millisecondsSinceEpoch,
      'snoozedUntilUtcMillis': state.snoozedUntilUtc?.millisecondsSinceEpoch,
      'rescheduledDate': state.rescheduledDate?.iso8601,
      'rescheduledTimeMinutes': state.rescheduledTime?.minutesSinceMidnight,
      'updatedAtUtcMillis': updatedAtUtc.millisecondsSinceEpoch,
      'deletedAtUtcMillis': null,
      'mutationId': mutationId,
    };
  }

  static Map<String, Object?> oneOffTaskPayload({
    required OneOffTask task,
    required String userId,
    required DateTime updatedAtUtc,
    required String mutationId,
    DateTime? deletedAtUtc,
  }) {
    return {
      'userId': userId,
      'id': task.id,
      'title': task.title,
      'notes': task.notes,
      'scheduledDate': task.scheduledDate.iso8601,
      'scheduledTimeMinutes': task.scheduledTime?.minutesSinceMidnight,
      'reminderEnabled': task.reminderEnabled,
      'status': task.status.name,
      'completedAtUtcMillis': task.completedAtUtc?.millisecondsSinceEpoch,
      'snoozedUntilUtcMillis': task.snoozedUntilUtc?.millisecondsSinceEpoch,
      'updatedAtUtcMillis': updatedAtUtc.millisecondsSinceEpoch,
      'deletedAtUtcMillis': deletedAtUtc?.millisecondsSinceEpoch,
      'mutationId': mutationId,
    };
  }

  static DateTime? dateTimeFromMillis(int? value) {
    return _dateTimeFromMillis(value);
  }

  static LocalDate dateFromString(String value) => _dateFromString(value);

  static LocalTime timeFromMinutes(int value) => _timeFromMinutes(value);

  static TaskStatus statusFromString(String value) => _statusFromString(value);

  static _EncodedRecurrence _encodeRecurrence(RecurrenceRule recurrence) {
    return switch (recurrence) {
      DailyRecurrence() => const _EncodedRecurrence(kind: 'daily'),
      WeekdayRecurrence(:final weekdaysIso) => _EncodedRecurrence(
        kind: 'weekdays',
        weekdaysMask: weekdaysIso.fold<int>(
          0,
          (mask, weekday) => mask | (1 << (weekday - 1)),
        ),
      ),
      IntervalRecurrence(:final intervalDays) => _EncodedRecurrence(
        kind: 'interval',
        intervalDays: intervalDays,
      ),
    };
  }

  static RecurrenceRule _decodeRecurrence(
    String kind,
    int weekdaysMask,
    int? intervalDays,
  ) {
    return switch (kind) {
      'daily' => const DailyRecurrence(),
      'weekdays' => _requireValidRow(
        WeekdayRecurrence.create(
          Iterable<int>.generate(7)
              .map((index) => index + 1)
              .where((weekday) => weekdaysMask & (1 << (weekday - 1)) != 0),
        ),
      ),
      'interval' => _requireValidRow(
        IntervalRecurrence.create(
          intervalDays ??
              (throw const FormatException(
                'An interval recurrence has no interval.',
              )),
        ),
      ),
      _ => throw FormatException('Unknown recurrence kind: $kind.'),
    };
  }

  static LocalDate _dateFromString(String value) {
    return _requireValidRow(LocalDate.parse(value));
  }

  static LocalTime _timeFromMinutes(int value) {
    return _requireValidRow(LocalTime.fromMinutesSinceMidnight(value));
  }

  static DateTime? _dateTimeFromMillis(int? value) {
    return value == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }

  static TaskStatus _statusFromString(String value) {
    for (final status in TaskStatus.values) {
      if (status.name == value) {
        return status;
      }
    }

    throw FormatException('Unknown task status: $value.');
  }

  static String _requiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is String) {
      return value;
    }
    throw FormatException('The local sync payload has no valid $key.');
  }

  static String? _optionalString(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value == null || value is String) {
      return value as String?;
    }
    throw FormatException('The local sync payload has an invalid $key.');
  }

  static int _requiredInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is int) {
      return value;
    }
    throw FormatException('The local sync payload has no valid $key.');
  }

  static int? _optionalInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value == null || value is int) {
      return value as int?;
    }
    throw FormatException('The local sync payload has an invalid $key.');
  }

  static bool _requiredBool(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is bool) {
      return value;
    }
    throw FormatException('The local sync payload has no valid $key.');
  }

  static T _requireValidRow<T>(Result<T> result) {
    return switch (result) {
      Success<T>(:final value) => value,
      FailureResult<T>(:final failure) => throw FormatException(
        'Invalid local database row: ${failure.message}',
      ),
    };
  }
}

final class _EncodedRecurrence {
  const _EncodedRecurrence({
    required this.kind,
    this.weekdaysMask = 0,
    this.intervalDays,
  });

  final String kind;
  final int weekdaysMask;
  final int? intervalDays;
}
