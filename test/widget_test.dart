import 'package:cadence_tasks/app/cadence_app.dart';
import 'package:cadence_tasks/app/home_shell.dart';
import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/application/ports/notification_scheduler.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_one_off_task_repository.dart';
import 'package:cadence_tasks/data/local/drift/drift_routine_repository.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
import 'package:cadence_tasks/features/agenda/domain/daily_agenda.dart';
import 'package:cadence_tasks/features/agenda/presentation/screens/today_screen.dart';
import 'package:cadence_tasks/features/calendar/domain/calendar_display_settings.dart';
import 'package:cadence_tasks/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:cadence_tasks/features/routines/presentation/screens/routines_screen.dart';
import 'package:cadence_tasks/features/settings/presentation/screens/settings_screen.dart';
import 'package:cadence_tasks/features/synchronization/domain/sync_coordinator.dart';
import 'package:cadence_tasks/features/tasks/presentation/widgets/task_editor_sheet.dart';
import 'package:cadence_tasks/infrastructure/firebase/firebase_bootstrap.dart';
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

  testWidgets('calendar opens a shared editor for tasks and routines', (
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('All day'), findsOneWidget);
    expect(find.text('6:00 AM'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('One-time'), findsOneWidget);
    expect(find.text('Routine'), findsOneWidget);
    expect(find.text('Task name'), findsOneWidget);

    await tester.tap(find.text('Routine'));
    await tester.pumpAndSettle();
    expect(find.text('Routine name'), findsOneWidget);
    expect(find.text('Repeats'), findsOneWidget);
  });

  testWidgets('task editor saves an optional duration', (
    WidgetTester tester,
  ) async {
    final today = LocalDate.fromDateTime(DateTime.now());
    const userId = 'duration-editor-user';
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          activeUserIdProvider.overrideWithValue(userId),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => TaskEditorSheet(
                      initialDate: today,
                      initialTime: time(8, 0),
                    ),
                  );
                },
                child: const Text('Open task editor'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open task editor'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Focus session');
    await tester.enterText(find.byType(TextFormField).at(2), '90');
    await tester.ensureVisible(find.text('Save task'));
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();

    final savedTasks = valueOf(
      await DriftOneOffTaskRepository(
        database,
        userId: userId,
      ).getScheduledFor(today),
    );
    expect(savedTasks.single.durationMinutes, 90);
  });

  testWidgets('editing a calendar task saves its updated details', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final today = LocalDate.fromDateTime(DateTime.now());
    const userId = 'calendar-edit-user';
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    });
    final repository = DriftOneOffTaskRepository(database, userId: userId);
    final task = oneOffTask(
      id: 'calendar-edit-task',
      title: 'Review notes',
      scheduledDate: today,
      scheduledTime: time(8, 0),
    );
    await repository.save(task);
    final agendaItem = _timedAgendaItem(
      id: task.id,
      title: task.title,
      date: today,
      startTime: task.scheduledTime!,
      durationMinutes: 60,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          activeUserIdProvider.overrideWithValue(userId),
          notificationSchedulerProvider.overrideWithValue(
            _NoopNotificationScheduler(),
          ),
          calendarDisplaySettingsProvider.overrideWith(
            (ref) => Stream.value(CalendarDisplaySettings.defaults),
          ),
          ..._agendaOverrides(today, agendaItem),
        ],
        child: const MaterialApp(home: CalendarScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review notes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit details'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Updated notes');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final savedTask = valueOf(await repository.getScheduledFor(today));
    expect(savedTask.single.title, 'Updated notes');
    expect(savedTask.single.scheduledTime, time(8, 0));
  });

  testWidgets('editing a Today item opens the same task editor', (
    WidgetTester tester,
  ) async {
    final today = LocalDate.fromDateTime(DateTime.now());
    const userId = 'today-edit-user';
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    });
    final repository = DriftOneOffTaskRepository(database, userId: userId);
    final task = oneOffTask(
      id: 'today-edit-task',
      title: 'Plan the day',
      scheduledDate: today,
      scheduledTime: time(8, 0),
    );
    await repository.save(task);
    final agendaItem = _timedAgendaItem(
      id: task.id,
      title: task.title,
      date: today,
      startTime: task.scheduledTime!,
      durationMinutes: 60,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          activeUserIdProvider.overrideWithValue(userId),
          notificationSchedulerProvider.overrideWithValue(
            _NoopNotificationScheduler(),
          ),
          dailyAgendaProvider(today).overrideWith(
            (ref) async => DailyAgenda(
              overdue: const [],
              upcoming: [agendaItem],
              completed: const [],
            ),
          ),
        ],
        child: const MaterialApp(home: TodayScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Task actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit details'));
    await tester.pumpAndSettle();

    expect(find.text('Edit task'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(TaskEditorSheet),
        matching: find.text('Plan the day'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('converting a completed task preserves its first occurrence', (
    WidgetTester tester,
  ) async {
    final today = LocalDate.fromDateTime(DateTime.now());
    const userId = 'type-conversion-user';
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    });
    final source = oneOffTask(
      id: 'convert-task',
      title: 'Read',
      scheduledDate: today,
      scheduledTime: time(8, 0),
      status: TaskStatus.completed,
      completedAtUtc: DateTime.utc(2026, 11, 24, 9),
    );
    await DriftOneOffTaskRepository(database, userId: userId).save(source);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          activeUserIdProvider.overrideWithValue(userId),
          notificationSchedulerProvider.overrideWithValue(
            _NoopNotificationScheduler(),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => TaskEditorSheet(task: source),
                  );
                },
                child: const Text('Open task'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Routine'));
    await tester.pumpAndSettle();
    final convertButton = find.widgetWithText(
      FilledButton,
      'Convert to routine',
    );
    await tester.ensureVisible(convertButton);
    await tester.tap(convertButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Convert'));
    await tester.pumpAndSettle();

    final routines = DriftRoutineRepository(database, userId: userId);
    final savedRoutines = valueOf(await routines.getAllRoutines());
    expect(savedRoutines.single.id, source.id);
    final firstOccurrence = valueOf(
      await routines.getOccurrenceStatesAffecting(today),
    );
    expect(firstOccurrence.single.status, TaskStatus.completed);
    expect(firstOccurrence.single.completedAtUtc, source.completedAtUtc);
    expect(
      valueOf(
        await DriftOneOffTaskRepository(
          database,
          userId: userId,
        ).getScheduledFor(today),
      ),
      isEmpty,
    );
  });

  testWidgets('new routines start in routine mode in the shared editor', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: RoutinesScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('New routine'));
    await tester.pumpAndSettle();

    expect(find.text('Routine name'), findsOneWidget);
    expect(find.text('Repeats'), findsOneWidget);
  });

  testWidgets('settings uses customer-facing offline storage copy', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          calendarDisplaySettingsProvider.overrideWith(
            (ref) => Stream.value(CalendarDisplaySettings.defaults),
          ),
          firebaseBootstrapStateProvider.overrideWithValue(
            const FirebaseOfflineMode(),
          ),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('On-device storage'), findsOneWidget);
    expect(find.text('Offline-only mode'), findsNothing);
    expect(find.textContaining('MVP'), findsNothing);
  });

  testWidgets('calendar displays a timed task as a duration block on mobile', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final today = LocalDate.fromDateTime(DateTime.now());
    const userId = 'duration-calendar-mobile-user';
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    });
    final item = _timedAgendaItem(
      id: 'focus-session',
      title: 'Focus session',
      date: today,
      startTime: time(8, 0),
      durationMinutes: 120,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          activeUserIdProvider.overrideWithValue(userId),
          calendarDisplaySettingsProvider.overrideWith(
            (ref) => Stream.value(CalendarDisplaySettings.defaults),
          ),
          ..._agendaOverrides(today, item),
        ],
        child: const MaterialApp(home: CalendarScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Focus session'), findsOneWidget);
    expect(find.text('8:00 AM - 10:00 AM'), findsOneWidget);
  });

  testWidgets('calendar displays duration blocks in the full week grid', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final today = LocalDate.fromDateTime(DateTime.now());
    const userId = 'duration-calendar-week-user';
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    });
    final item = _timedAgendaItem(
      id: 'week-focus-session',
      title: 'Week focus session',
      date: today,
      startTime: time(12, 0),
      durationMinutes: 60,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          activeUserIdProvider.overrideWithValue(userId),
          calendarDisplaySettingsProvider.overrideWith(
            (ref) => Stream.value(CalendarDisplaySettings.defaults),
          ),
          ..._agendaOverrides(today, item),
        ],
        child: const MaterialApp(home: CalendarScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Week focus session'), findsOneWidget);
    expect(find.text('12:00 PM - 1:00 PM'), findsOneWidget);
    final eventRect = tester.getRect(
      find.byKey(
        const ValueKey<String>('calendar-event:one-off:week-focus-session'),
      ),
    );
    final currentHourRect = tester.getRect(
      find.byKey(ValueKey<String>('calendar-slot:${today.iso8601}:12')),
    );
    final nextHourRect = tester.getRect(
      find.byKey(ValueKey<String>('calendar-slot:${today.iso8601}:13')),
    );
    expect(eventRect.left, greaterThan(currentHourRect.left));
    expect(eventRect.right, lessThan(currentHourRect.right));
    expect(eventRect.top, greaterThan(currentHourRect.top));
    expect(eventRect.bottom, lessThan(nextHourRect.top));
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
    expect(find.text('Add a task'), findsOneWidget);
    expect(find.text('Task name'), findsOneWidget);
    expect(find.text('One-time'), findsOneWidget);
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

AgendaItem _timedAgendaItem({
  required String id,
  required String title,
  required LocalDate date,
  required LocalTime startTime,
  required int durationMinutes,
}) {
  return AgendaItem(
    id: 'one-off:$id',
    sourceId: id,
    sourceDate: date,
    title: title,
    kind: AgendaItemKind.oneOff,
    scheduledDate: date,
    scheduledTime: startTime,
    durationMinutes: durationMinutes,
    status: TaskStatus.pending,
    reminderEnabled: false,
  );
}

List<Override> _agendaOverrides(LocalDate date, AgendaItem item) {
  final weekStart = date.addDays(-(date.weekday - DateTime.monday));
  return [
    for (var day = 0; day < 7; day++)
      dailyAgendaProvider(weekStart.addDays(day)).overrideWith(
        (ref) async => DailyAgenda(
          overdue: const [],
          upcoming: weekStart.addDays(day) == date ? [item] : const [],
          completed: const [],
        ),
      ),
  ];
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

final class _NoopNotificationScheduler implements NotificationScheduler {
  @override
  Future<Result<Unit>> initialize({
    required void Function(NotificationAction action) onAction,
  }) async => const Success<Unit>(Unit.value);

  @override
  Future<Result<Unit>> requestPermissions() async =>
      const Success<Unit>(Unit.value);

  @override
  Future<Result<Unit>> scheduleReminder(AgendaItem item) async =>
      const Success<Unit>(Unit.value);

  @override
  Future<Result<Unit>> cancelReminder(String itemId) async =>
      const Success<Unit>(Unit.value);

  @override
  Future<Result<Unit>> cancelRoutineReminders(String routineId) async =>
      const Success<Unit>(Unit.value);

  @override
  Future<Result<Unit>> cancelAllReminders() async =>
      const Success<Unit>(Unit.value);
}
