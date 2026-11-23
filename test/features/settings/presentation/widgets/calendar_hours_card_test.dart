import 'dart:async';

import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/calendar/domain/calendar_display_settings.dart';
import 'package:cadence_tasks/features/calendar/domain/calendar_display_settings_repository.dart';
import 'package:cadence_tasks/features/settings/presentation/widgets/calendar_hours_card.dart';
// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('saves a selected calendar start hour', (
    WidgetTester tester,
  ) async {
    final repository = _FakeCalendarDisplaySettingsRepository();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await repository.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarDisplaySettingsRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: CalendarHoursCard())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('6:00 AM'), findsOneWidget);
    expect(find.text('10:00 PM'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<int>).first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('8:00 AM'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('8:00 AM'), findsOneWidget);
    expect(repository.savedSettings?.startHour, 8);
    expect(repository.savedSettings?.endHour, 22);
  });
}

final class _FakeCalendarDisplaySettingsRepository
    implements CalendarDisplaySettingsRepository {
  final _settingsStream = StreamController<CalendarDisplaySettings>.broadcast();
  CalendarDisplaySettings _settings = CalendarDisplaySettings.defaults;
  CalendarDisplaySettings? savedSettings;

  @override
  Stream<CalendarDisplaySettings> watchSettings() async* {
    yield _settings;
    yield* _settingsStream.stream;
  }

  @override
  Future<Result<Unit>> saveSettings(CalendarDisplaySettings settings) async {
    _settings = settings;
    savedSettings = settings;
    _settingsStream.add(settings);
    return const Success<Unit>(Unit.value);
  }

  Future<void> close() => _settingsStream.close();
}
