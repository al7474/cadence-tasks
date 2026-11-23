import 'package:drift/drift.dart';

@DataClassName('CalendarDisplaySettingsRow')
class CalendarDisplaySettingsTable extends Table {
  TextColumn get userId => text()();

  IntColumn get startHour => integer()();

  IntColumn get endHour => integer()();

  IntColumn get updatedAtUtcMillis => integer()();

  TextColumn get mutationId => text()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}
