import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_rule.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/routines/presentation/widgets/routine_editor_sheet.dart';
// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Routines')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New routine'),
      ),
      body: routines.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            _RoutinesErrorView(onRetry: () => ref.invalidate(routinesProvider)),
        data: (items) {
          if (items.isEmpty) {
            return _EmptyRoutinesView(
              onCreate: () => _openEditor(context, ref),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Build consistency with a routine that repeats.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              for (final routine in items)
                _RoutineCard(
                  routine: routine,
                  onTap: () => _openEditor(context, ref, routine: routine),
                  onToggle: (enabled) => _toggle(ref, routine, enabled),
                  onDelete: () => _delete(context, ref, routine),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    RoutineTemplate? routine,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => RoutineEditorSheet(routine: routine),
    );
    if (saved == true) {
      ref.invalidate(routinesProvider);
      ref.invalidate(dailyAgendaProvider);
    }
  }

  Future<void> _toggle(
    WidgetRef ref,
    RoutineTemplate routine,
    bool enabled,
  ) async {
    final updated = RoutineTemplate.create(
      id: routine.id,
      title: routine.title,
      notes: routine.notes,
      startDate: routine.startDate,
      endDate: routine.endDate,
      targetTime: routine.targetTime,
      recurrence: routine.recurrence,
      reminderEnabled: routine.reminderEnabled,
      isEnabled: enabled,
    );
    switch (updated) {
      case FailureResult<RoutineTemplate>(:final failure):
        _showError(ref, failure.message);
        return;
      case Success<RoutineTemplate>(:final value):
        final result = await ref.read(routineRepositoryProvider).save(value);
        switch (result) {
          case Success<Unit>():
            final notificationResult = await ref
                .read(reminderReconcilerProvider)
                .reconcile();
            ref.invalidate(routinesProvider);
            ref.invalidate(dailyAgendaProvider);
            if (notificationResult case FailureResult<Unit>(:final failure)) {
              _showError(
                ref,
                'Routine updated, but reminders could not be changed: '
                '${failure.message}',
              );
            }
          case FailureResult<Unit>(:final failure):
            _showError(ref, failure.message);
        }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    RoutineTemplate routine,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete routine?'),
        content: Text(
          'Delete "${routine.title}"? Existing completion history will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    final result = await ref.read(routineRepositoryProvider).delete(routine.id);
    switch (result) {
      case Success<Unit>():
        final notificationResult = await ref
            .read(notificationSchedulerProvider)
            .cancelRoutineReminders(routine.id);
        ref.invalidate(routinesProvider);
        ref.invalidate(dailyAgendaProvider);
        if (notificationResult case FailureResult<Unit>(:final failure)) {
          _showError(
            ref,
            'Routine deleted, but reminders could not be cancelled: '
            '${failure.message}',
          );
        }
      case FailureResult<Unit>(:final failure):
        _showError(ref, failure.message);
    }
  }

  void _showError(WidgetRef ref, String message) {
    final context = ref.context;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final RoutineTemplate routine;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(
      hour: routine.targetTime.hour,
      minute: routine.targetTime.minute,
    ).format(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(routine.isEnabled ? Icons.repeat : Icons.pause),
        ),
        title: Text(routine.title),
        subtitle: Text('$time · ${_recurrenceDescription(routine.recurrence)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: routine.isEnabled, onChanged: onToggle),
            PopupMenuButton<String>(
              tooltip: 'Routine actions',
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete();
                } else if (value == 'edit') {
                  onTap();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _recurrenceDescription(RecurrenceRule recurrence) {
    return switch (recurrence) {
      DailyRecurrence() => 'Every day',
      WeekdayRecurrence(:final weekdaysIso) => _weekdayDescription(weekdaysIso),
      IntervalRecurrence(:final intervalDays) =>
        'Every $intervalDays ${intervalDays == 1 ? 'day' : 'days'}',
    };
  }

  static String _weekdayDescription(Set<int> weekdays) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selected = [
      for (var index = 0; index < names.length; index++)
        if (weekdays.contains(index + 1)) names[index],
    ];
    return selected.join(', ');
  }
}

class _EmptyRoutinesView extends StatelessWidget {
  const _EmptyRoutinesView({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.repeat,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No routines yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a daily, weekday, or interval routine.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create routine'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutinesErrorView extends StatelessWidget {
  const _RoutinesErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Routines could not be loaded.'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
