import 'dart:async';

import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/agenda/presentation/screens/today_screen.dart';
import 'package:cadence_tasks/features/routines/presentation/screens/routines_screen.dart';
import 'package:cadence_tasks/features/settings/presentation/screens/settings_screen.dart';
import 'package:cadence_tasks/features/synchronization/domain/sync_coordinator.dart';
// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _syncInProgress = false;

  static const _pages = [TodayScreen(), RoutinesScreen(), SettingsScreen()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_synchronizeIfReady());
      unawaited(_reconcileReminders());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_synchronizeIfReady());
      unawaited(_reconcileReminders());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      if (next.asData?.value != null) {
        unawaited(_synchronizeIfReady());
      }
    });

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.repeat_outlined),
            selectedIcon: Icon(Icons.repeat),
            label: 'Routines',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Future<void> _synchronizeIfReady() async {
    if (_syncInProgress) {
      return;
    }
    final coordinator = ref.read(syncCoordinatorProvider);
    if (coordinator == null) {
      return;
    }

    _syncInProgress = true;
    try {
      final result = await coordinator.synchronize();
      if (!mounted) {
        return;
      }

      switch (result) {
        case Success<SyncSummary>(:final value):
          ref.read(syncStatusProvider.notifier).state =
              'Last sync: ${value.uploaded} uploaded, '
              '${value.downloaded} downloaded.';
          ref.invalidate(dailyAgendaProvider);
          ref.invalidate(routinesProvider);
        case FailureResult<SyncSummary>(:final failure):
          ref.read(syncStatusProvider.notifier).state = failure.message;
      }
    } finally {
      _syncInProgress = false;
    }
  }

  Future<void> _reconcileReminders() async {
    final result = await ref.read(reminderReconcilerProvider).reconcile();
    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<Unit>():
        ref.read(notificationSetupErrorProvider.notifier).state = null;
      case FailureResult<Unit>(:final failure):
        ref.read(notificationSetupErrorProvider.notifier).state =
            failure.message;
    }
  }
}
