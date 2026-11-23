import 'dart:convert';

import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_calendar_display_settings_repository.dart';
import 'package:cadence_tasks/data/local/drift/drift_sync_repository.dart';
import 'package:cadence_tasks/features/calendar/domain/calendar_display_settings.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('uses the default range until a user saves a preference', () async {
    final repository = DriftCalendarDisplaySettingsRepository(
      database,
      userId: 'calendar-user-1',
    );

    expect(
      await repository.watchSettings().first,
      CalendarDisplaySettings.defaults,
    );
  });

  test('saves per-user preferences and queues a sync mutation', () async {
    final ownerRepository = DriftCalendarDisplaySettingsRepository(
      database,
      userId: 'calendar-user-1',
      clock: () => DateTime.utc(2026, 11, 23, 12),
    );
    final otherRepository = DriftCalendarDisplaySettingsRepository(
      database,
      userId: 'calendar-user-2',
    );
    final settings = calendarSettings(startHour: 8, endHour: 20);

    expect(await ownerRepository.saveSettings(settings), isA<Success<Unit>>());
    expect(await ownerRepository.watchSettings().first, settings);
    expect(
      await otherRepository.watchSettings().first,
      CalendarDisplaySettings.defaults,
    );

    final pending = await DriftSyncRepository(
      database,
    ).pendingMutations('calendar-user-1');
    expect(pending, hasLength(1));
    expect(pending.single.collectionName, 'calendarPreferences');
    expect(pending.single.recordId, 'display-hours');
    expect(
      (jsonDecode(pending.single.payload) as Map<String, dynamic>)['startHour'],
      8,
    );
  });

  test('claims guest calendar preferences for the signed-in user', () async {
    final guestRepository = DriftCalendarDisplaySettingsRepository(
      database,
      userId: DriftSyncRepository.guestUserId,
    );
    final signedInRepository = DriftCalendarDisplaySettingsRepository(
      database,
      userId: 'calendar-user-1',
    );
    final settings = calendarSettings(startHour: 7, endHour: 21);
    final syncRepository = DriftSyncRepository(database);

    await guestRepository.saveSettings(settings);
    await syncRepository.claimGuestData('calendar-user-1');

    expect(
      await guestRepository.watchSettings().first,
      CalendarDisplaySettings.defaults,
    );
    expect(await signedInRepository.watchSettings().first, settings);
    expect(
      await syncRepository.pendingMutations('calendar-user-1'),
      hasLength(1),
    );
  });
}

CalendarDisplaySettings calendarSettings({
  required int startHour,
  required int endHour,
}) {
  return switch (CalendarDisplaySettings.create(
    startHour: startHour,
    endHour: endHour,
  )) {
    Success<CalendarDisplaySettings>(:final value) => value,
    FailureResult<CalendarDisplaySettings>(:final failure) => throw StateError(
      failure.message,
    ),
  };
}
