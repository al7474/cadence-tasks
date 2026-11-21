import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/authentication/domain/auth_user.dart';
import 'package:cadence_tasks/features/synchronization/domain/sync_coordinator.dart';
import 'package:cadence_tasks/infrastructure/firebase/firebase_bootstrap.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isWorking = false;

  @override
  Widget build(BuildContext context) {
    final notificationError = ref.watch(notificationSetupErrorProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final firebaseState = ref.watch(firebaseBootstrapStateProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(
                notificationError == null
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
              ),
              title: Text(kIsWeb ? 'Reminders' : 'Android reminders'),
              subtitle: Text(
                notificationError ??
                    (kIsWeb
                        ? 'Scheduled reminders are available in the Android app.'
                        : 'Exact reminders are requested when you enable them.'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _cloudSyncCard(context, firebaseState, authState, syncStatus),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 24, 8, 8),
            child: Text(
              'Cadence Tasks MVP',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Routines and tasks are available offline. '
              'Cloud sync uses your own Firebase project and free-tier quota.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _cloudSyncCard(
    BuildContext context,
    FirebaseBootstrapState firebaseState,
    AsyncValue<AuthUser?> authState,
    String? syncStatus,
  ) {
    return switch (firebaseState) {
      FirebaseOfflineMode() => const Card(
        child: ListTile(
          leading: Icon(Icons.cloud_off_outlined),
          title: Text('Offline-only mode'),
          subtitle: Text(
            'Cloud sync is not configured. Your data stays on this device.',
          ),
        ),
      ),
      FirebaseStartupFailure(:final message) => Card(
        child: ListTile(
          leading: const Icon(Icons.cloud_off_outlined),
          title: const Text('Cloud sync unavailable'),
          subtitle: Text(message),
        ),
      ),
      FirebaseReady() => authState.when(
        loading: () => const Card(
          child: ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Checking account'),
          ),
        ),
        error: (error, stackTrace) => Card(
          child: ListTile(
            leading: const Icon(Icons.error_outline),
            title: const Text('Account status unavailable'),
            subtitle: Text(error.toString()),
          ),
        ),
        data: (user) => user == null
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud sync',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in with Google to sync your data across devices.',
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _isWorking ? null : _signIn,
                        icon: const Icon(Icons.login),
                        label: const Text('Continue with Google'),
                      ),
                    ],
                  ),
                ),
              )
            : Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.cloud_done_outlined),
                        title: Text(user.displayName ?? 'Signed in'),
                        subtitle: Text(
                          user.email.isEmpty ? user.id : user.email,
                        ),
                      ),
                      if (syncStatus != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(syncStatus),
                        ),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: _isWorking ? null : _synchronize,
                            icon: const Icon(Icons.sync),
                            label: const Text('Sync now'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _isWorking ? null : _signOut,
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign out'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    };
  }

  Future<void> _signIn() async {
    final repository = ref.read(authenticationRepositoryProvider);
    if (repository == null) {
      _showError('Firebase is not configured.');
      return;
    }

    setState(() {
      _isWorking = true;
    });
    final result = await repository.signInWithGoogle();
    if (!mounted) {
      return;
    }
    setState(() {
      _isWorking = false;
    });

    switch (result) {
      case Success<AuthUser>():
        ref.invalidate(authStateProvider);
        ref.invalidate(activeUserIdProvider);
      case FailureResult<AuthUser>(:final failure):
        _showError(failure.message);
    }
  }

  Future<void> _signOut() async {
    final repository = ref.read(authenticationRepositoryProvider);
    if (repository == null) {
      _showError('Firebase is not configured.');
      return;
    }

    setState(() {
      _isWorking = true;
    });
    final result = await repository.signOut();
    if (!mounted) {
      return;
    }
    setState(() {
      _isWorking = false;
    });

    switch (result) {
      case Success<Unit>():
        ref.invalidate(authStateProvider);
        ref.invalidate(activeUserIdProvider);
      case FailureResult<Unit>(:final failure):
        _showError(failure.message);
    }
  }

  Future<void> _synchronize() async {
    final coordinator = ref.read(syncCoordinatorProvider);
    if (coordinator == null) {
      _showError('Sign in before syncing.');
      return;
    }

    setState(() {
      _isWorking = true;
    });
    ref.read(syncStatusProvider.notifier).state = null;
    final result = await coordinator.synchronize();
    if (!mounted) {
      return;
    }
    setState(() {
      _isWorking = false;
    });

    switch (result) {
      case Success<SyncSummary>(:final value):
        ref.invalidate(dailyAgendaProvider);
        ref.invalidate(routinesProvider);
        ref.read(syncStatusProvider.notifier).state =
            'Synced ${value.uploaded} uploaded and '
            '${value.downloaded} downloaded records.';
      case FailureResult<SyncSummary>(:final failure):
        _showError(failure.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
