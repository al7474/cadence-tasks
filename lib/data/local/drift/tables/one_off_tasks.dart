import 'package:drift/drift.dart';

@DataClassName('OneOffTaskRow')
class OneOffTasks extends Table {
  TextColumn get userId => text()();

  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get notes => text().nullable()();

  TextColumn get scheduledDate => text()();

  IntColumn get scheduledTimeMinutes => integer().nullable()();

  IntColumn get durationMinutes => integer().nullable()();

  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();

  TextColumn get status => text()();

  IntColumn get completedAtUtcMillis => integer().nullable()();

  IntColumn get snoozedUntilUtcMillis => integer().nullable()();

  IntColumn get updatedAtUtcMillis => integer()();

  IntColumn get deletedAtUtcMillis => integer().nullable()();

  TextColumn get mutationId => text()();

  @override
  Set<Column<Object>> get primaryKey => {userId, id};
}
