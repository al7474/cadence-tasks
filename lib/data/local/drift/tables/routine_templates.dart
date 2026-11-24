import 'package:drift/drift.dart';

@DataClassName('RoutineTemplateRow')
class RoutineTemplates extends Table {
  TextColumn get userId => text()();

  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get notes => text().nullable()();

  TextColumn get startDate => text()();

  TextColumn get endDate => text().nullable()();

  IntColumn get targetTimeMinutes => integer()();

  IntColumn get durationMinutes => integer().nullable()();

  TextColumn get recurrenceKind => text()();

  IntColumn get weekdaysMask => integer().withDefault(const Constant(0))();

  IntColumn get intervalDays => integer().nullable()();

  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  IntColumn get updatedAtUtcMillis => integer()();

  IntColumn get deletedAtUtcMillis => integer().nullable()();

  TextColumn get mutationId => text()();

  @override
  Set<Column<Object>> get primaryKey => {userId, id};
}
