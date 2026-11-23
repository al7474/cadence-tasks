import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/outbox_writer.dart';
import 'package:cadence_tasks/features/calendar/domain/calendar_display_settings.dart';
import 'package:cadence_tasks/features/calendar/domain/calendar_display_settings_repository.dart';
import 'package:uuid/uuid.dart';

final class DriftCalendarDisplaySettingsRepository
    implements CalendarDisplaySettingsRepository {
  DriftCalendarDisplaySettingsRepository(
    this._database, {
    required this.userId,
    DateTime Function()? clock,
    Uuid? uuid,
  }) : _clock = clock ?? DateTime.now,
       _uuid = uuid ?? const Uuid() {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'Must not be empty.');
    }
  }

  static const collectionName = 'calendarPreferences';
  static const recordId = 'display-hours';

  final AppDatabase _database;
  final String userId;
  final DateTime Function() _clock;
  final Uuid _uuid;

  @override
  Stream<CalendarDisplaySettings> watchSettings() {
    return (_database.select(_database.calendarDisplaySettingsTable)
          ..where((row) => row.userId.equals(userId)))
        .watchSingleOrNull()
        .map((row) {
          if (row == null) {
            return CalendarDisplaySettings.defaults;
          }
          return switch (
            CalendarDisplaySettings.create(
              startHour: row.startHour,
              endHour: row.endHour,
            )
          ) {
            Success<CalendarDisplaySettings>(:final value) => value,
            FailureResult<CalendarDisplaySettings>(:final failure) =>
              throw StateError(
                'Saved calendar display settings are invalid: ${failure.message}',
              ),
          };
        });
  }

  @override
  Future<Result<Unit>> saveSettings(
    CalendarDisplaySettings settings,
  ) async {
    final updatedAtUtc = _clock().toUtc();
    final mutationId = _uuid.v4();
    final payload = <String, Object?>{
      'userId': userId,
      'id': recordId,
      'startHour': settings.startHour,
      'endHour': settings.endHour,
      'updatedAtUtcMillis': updatedAtUtc.millisecondsSinceEpoch,
      'deletedAtUtcMillis': null,
      'mutationId': mutationId,
    };

    await _database.transaction(() async {
      await _database
          .into(_database.calendarDisplaySettingsTable)
          .insertOnConflictUpdate(
            CalendarDisplaySettingsTableCompanion.insert(
              userId: userId,
              startHour: settings.startHour,
              endHour: settings.endHour,
              updatedAtUtcMillis: updatedAtUtc.millisecondsSinceEpoch,
              mutationId: mutationId,
            ),
          );
      await enqueueSyncMutation(
        _database,
        userId: userId,
        collectionName: collectionName,
        recordId: recordId,
        updatedAtUtc: updatedAtUtc,
        mutationId: mutationId,
        payload: payload,
      );
    });

    return const Success<Unit>(Unit.value);
  }
}
