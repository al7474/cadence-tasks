import 'package:drift/drift.dart';

@DataClassName('SyncCursorRow')
class SyncCursors extends Table {
  TextColumn get userId => text()();

  TextColumn get collectionName => text()();

  IntColumn get lastUpdatedAtUtcMillis =>
      integer().withDefault(const Constant(0))();

  TextColumn get lastMutationId => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {userId, collectionName};
}
