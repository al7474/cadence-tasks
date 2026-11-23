import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/calendar/domain/calendar_display_settings.dart';

abstract interface class CalendarDisplaySettingsRepository {
  Stream<CalendarDisplaySettings> watchSettings();

  Future<Result<Unit>> saveSettings(CalendarDisplaySettings settings);
}
