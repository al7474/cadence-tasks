import 'package:drift/drift.dart';

@DataClassName('SyncOutboxEntryRow')
class SyncOutboxEntries extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get collectionName => text()();

  TextColumn get recordId => text()();

  IntColumn get updatedAtUtcMillis => integer()();

  TextColumn get mutationId => text()();

  TextColumn get payload => text()();

  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
