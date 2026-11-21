import 'package:cadence_tasks/data/local/drift/tables/one_off_tasks.dart';
import 'package:cadence_tasks/data/local/drift/tables/routine_occurrence_logs.dart';
import 'package:cadence_tasks/data/local/drift/tables/routine_templates.dart';
import 'package:cadence_tasks/data/local/drift/tables/sync_cursors.dart';
import 'package:cadence_tasks/data/local/drift/tables/sync_outbox_entries.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    RoutineTemplates,
    RoutineOccurrenceLogs,
    OneOffTasks,
    SyncCursors,
    SyncOutboxEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(syncCursors);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'cadence_tasks',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
