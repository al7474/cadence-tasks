import 'package:cadence_tasks/app/cadence_app.dart';
import 'package:cadence_tasks/app/home_shell.dart';
import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_one_off_task_repository.dart';
import 'package:cadence_tasks/features/synchronization/domain/sync_coordinator.dart';
import 'package:drift/native.dart';
// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/domain_test_factories.dart';

void main() {
  testWidgets('CadenceApp displays the empty agenda', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const CadenceApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your day is clear'), findsOneWidget);
  });

  testWidgets('a local outbox mutation triggers automatic synchronization', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final coordinator = _CountingSyncCoordinator();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          activeUserIdProvider.overrideWithValue('sync-test-user'),
          syncCoordinatorProvider.overrideWithValue(coordinator),
        ],
        child: const MaterialApp(home: HomeShell()),
      ),
    );
    await tester.pumpAndSettle();
    final initialSyncCount = coordinator.synchronizationCount;

    final now = DateTime.now();
    final result =
        await DriftOneOffTaskRepository(
          database,
          userId: 'sync-test-user',
        ).save(
          oneOffTask(
            id: 'sync-test-task',
            title: 'Sync test',
            scheduledDate: date(now.year, now.month, now.day),
            reminderEnabled: false,
          ),
        );

    expect(result, isA<Success<Unit>>());
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(coordinator.synchronizationCount, greaterThan(initialSyncCount));
  });
}

final class _CountingSyncCoordinator implements SyncCoordinator {
  int synchronizationCount = 0;

  @override
  Future<Result<SyncSummary>> synchronize() async {
    synchronizationCount++;
    return const Success<SyncSummary>(
      SyncSummary(uploaded: 0, downloaded: 0, conflictsResolved: 0),
    );
  }

  @override
  Stream<Result<SyncSummary>> watchRemoteChanges() => const Stream.empty();
}
