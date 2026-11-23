import 'package:cadence_tasks/app/cadence_app.dart';
import 'package:cadence_tasks/app/home_shell.dart';
import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_one_off_task_repository.dart';
import 'package:cadence_tasks/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:cadence_tasks/features/synchronization/domain/sync_coordinator.dart';
import 'package:cadence_tasks/features/tasks/presentation/widgets/task_editor_sheet.dart';
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

  testWidgets('calendar offers one-time tasks and repeating routines', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: CalendarScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('All day'), findsOneWidget);
    expect(find.text('6:00 AM'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('One-time task'), findsOneWidget);
    expect(find.text('Repeating routine'), findsOneWidget);

    await tester.tap(find.text('One-time task'));
    await tester.pumpAndSettle();

    expect(find.text('Add a task'), findsOneWidget);
  });

  testWidgets('calendar displays all seven days in the wide week grid', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: CalendarScreen()),
      ),
    );
    await tester.pumpAndSettle();

    for (final weekday in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
      expect(find.text(weekday), findsOneWidget);
    }
    expect(find.text('All day'), findsOneWidget);
    expect(find.text('6:00 AM'), findsOneWidget);
    expect(find.text('10:00 PM'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add).at(7));
    await tester.pumpAndSettle();
    expect(find.text('One-time task'), findsOneWidget);
    expect(find.textContaining(' at 6:00 AM'), findsOneWidget);

    await tester.tap(find.text('One-time task'));
    await tester.pumpAndSettle();
    expect(find.text('Add a task'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(TaskEditorSheet),
        matching: find.text('6:00 AM'),
      ),
      findsOneWidget,
    );
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
