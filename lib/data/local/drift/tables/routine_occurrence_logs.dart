import 'package:drift/drift.dart';

@DataClassName('RoutineOccurrenceLogRow')
class RoutineOccurrenceLogs extends Table {
  TextColumn get userId => text()();

  TextColumn get routineId => text()();

  TextColumn get occurrenceDate => text()();

  TextColumn get status => text()();

  IntColumn get completedAtUtcMillis => integer().nullable()();

  IntColumn get snoozedUntilUtcMillis => integer().nullable()();

  TextColumn get rescheduledDate => text().nullable()();

  IntColumn get rescheduledTimeMinutes => integer().nullable()();

  IntColumn get updatedAtUtcMillis => integer()();

  IntColumn get deletedAtUtcMillis => integer().nullable()();

  TextColumn get mutationId => text()();

  @override
  Set<Column<Object>> get primaryKey => {userId, routineId, occurrenceDate};
}
