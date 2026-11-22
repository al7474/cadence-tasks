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
  bool _syncRequested = false;
  bool _hasPendingSyncMutations = false;
  Timer? _syncDebounce;

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
    _syncDebounce?.cancel();
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
    ref.listen(pendingSyncOutboxProvider, (previous, next) {
      final pendingMutations = next.asData?.value;
      if (pendingMutations == null) {
        return;
      }

      _hasPendingSyncMutations = pendingMutations.isNotEmpty;
      if (_hasPendingSyncMutations) {
        _scheduleSynchronization();
      }
    });
    ref.listen(realtimeSyncEventsProvider, (previous, next) {
      next.when(
        data: (result) {
          switch (result) {
            case Success<SyncSummary>(:final value):
              if (value.downloaded > 0) {
                ref.invalidate(dailyAgendaProvider);
                ref.invalidate(routinesProvider);
                ref.read(syncStatusProvider.notifier).state =
                    'Live sync: ${value.downloaded} downloaded.';
              }
              if (_hasPendingSyncMutations) {
                _scheduleSynchronization();
              }
            case FailureResult<SyncSummary>(:final failure):
              ref.read(syncStatusProvider.notifier).state = failure.message;
          }
        },
        error: (error, stackTrace) {
          ref.read(syncStatusProvider.notifier).state =
              'Live sync failed: $error';
        },
        loading: () {},
      );
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
      _syncRequested = true;
      return;
    }
    _syncInProgress = true;
    try {
      do {
        _syncRequested = false;
        final coordinator = ref.read(syncCoordinatorProvider);
        if (coordinator == null) {
          return;
        }

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
      } while (_syncRequested && mounted);
    } finally {
      _syncInProgress = false;
    }
  }

  void _scheduleSynchronization() {
    if (!mounted) {
      return;
    }

    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(milliseconds: 300), () {
      _syncDebounce = null;
      if (mounted) {
        unawaited(_synchronizeIfReady());
      }
    });
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
