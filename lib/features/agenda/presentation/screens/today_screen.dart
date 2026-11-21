import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
import 'package:cadence_tasks/features/agenda/domain/daily_agenda.dart';
import 'package:cadence_tasks/features/agenda/presentation/controllers/agenda_actions_controller.dart';
import 'package:cadence_tasks/features/tasks/presentation/widgets/task_editor_sheet.dart';
// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  late LocalDate _selectedDate = LocalDate.fromDateTime(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final agenda = ref.watch(dailyAgendaProvider(_selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_isToday ? 'Today' : 'Agenda'),
            Text(
              _formatDate(_selectedDate),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Choose date',
            onPressed: _selectDate,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      body: agenda.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorView(
          onRetry: () => ref.invalidate(dailyAgendaProvider(_selectedDate)),
        ),
        data: _buildAgenda,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
    );
  }

  bool get _isToday {
    return _selectedDate == LocalDate.fromDateTime(DateTime.now());
  }

  Widget _buildAgenda(DailyAgenda agenda) {
    if (agenda.isEmpty) {
      return _EmptyAgenda(onAddTask: _addTask);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dailyAgendaProvider(_selectedDate));
        await ref.read(dailyAgendaProvider(_selectedDate).future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _AgendaSummary(agenda: agenda),
          if (agenda.overdue.isNotEmpty)
            _section(
              title: 'Overdue',
              items: agenda.overdue,
              color: Theme.of(context).colorScheme.error,
            ),
          if (agenda.upcoming.isNotEmpty)
            _section(
              title: 'Upcoming',
              items: agenda.upcoming,
              color: Theme.of(context).colorScheme.primary,
            ),
          if (agenda.completed.isNotEmpty)
            _section(
              title: 'Completed',
              items: agenda.completed,
              color: Theme.of(context).colorScheme.tertiary,
            ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required List<AgendaItem> items,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8),
              Text(
                '${items.length}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in items)
            _AgendaItemCard(
              item: item,
              onComplete: () => _perform(item, _AgendaAction.complete),
              onSkip: () => _perform(item, _AgendaAction.skip),
              onSnooze: () => _perform(item, _AgendaAction.snooze),
              onReschedule: () => _reschedule(item),
              onUndo: () => _perform(item, _AgendaAction.undo),
              onDelete: () => _deleteTask(item),
            ),
        ],
      ),
    );
  }

  Future<void> _addTask() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => TaskEditorSheet(initialDate: _selectedDate),
    );
    if (saved == true && mounted) {
      ref.invalidate(dailyAgendaProvider(_selectedDate));
    }
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = LocalDate.fromDateTime(selected);
    });
  }

  Future<void> _perform(AgendaItem item, _AgendaAction action) async {
    final AgendaActionsController controller = ref.read(
      agendaActionsControllerProvider,
    );
    late final Future<Result<Unit>> operation;
    switch (action) {
      case _AgendaAction.complete:
        operation = controller.setStatus(item, TaskStatus.completed);
        break;
      case _AgendaAction.skip:
        operation = controller.setStatus(item, TaskStatus.skipped);
        break;
      case _AgendaAction.snooze:
        operation = controller.snooze(item);
        break;
      case _AgendaAction.reschedule:
        await _reschedule(item);
        return;
      case _AgendaAction.undo:
        operation = controller.setStatus(item, TaskStatus.pending);
        break;
      case _AgendaAction.delete:
        await _deleteTask(item);
        return;
    }
    final result = await operation;
    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<Unit>():
        ref.invalidate(dailyAgendaProvider(_selectedDate));
      case FailureResult<Unit>(:final failure):
        ref.invalidate(dailyAgendaProvider(_selectedDate));
        _showError(failure.message);
    }
  }

  Future<void> _reschedule(AgendaItem item) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(
        item.scheduledDate.year,
        item.scheduledDate.month,
        item.scheduledDate.day,
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate == null || !mounted) {
      return;
    }

    final initialTime = item.scheduledTime;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: initialTime.hour, minute: initialTime.minute),
    );
    if (selectedTime == null || !mounted) {
      return;
    }

    final timeResult = LocalTime.create(
      hour: selectedTime.hour,
      minute: selectedTime.minute,
    );
    late final LocalTime time;
    switch (timeResult) {
      case Success<LocalTime>(:final value):
        time = value;
        break;
      case FailureResult<LocalTime>(:final failure):
        _showError(failure.message);
        return;
    }
    final result = await ref
        .read(agendaActionsControllerProvider)
        .reschedule(
          item,
          date: LocalDate.fromDateTime(selectedDate),
          time: time,
        );
    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<Unit>():
        ref.invalidate(dailyAgendaProvider(_selectedDate));
      case FailureResult<Unit>(:final failure):
        _showError(failure.message);
    }
  }

  Future<void> _deleteTask(AgendaItem item) async {
    if (item.kind != AgendaItemKind.oneOff) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Delete "${item.title}"?'),
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
    if (confirmed != true || !mounted) {
      return;
    }

    final result = await ref
        .read(agendaActionsControllerProvider)
        .deleteOneOffTask(item);
    if (!mounted) {
      return;
    }
    switch (result) {
      case Success<Unit>():
        ref.invalidate(dailyAgendaProvider(_selectedDate));
      case FailureResult<Unit>(:final failure):
        ref.invalidate(dailyAgendaProvider(_selectedDate));
        _showError(failure.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(LocalDate date) {
    return DateFormat(
      'EEEE, MMM d',
      'en_US',
    ).format(DateTime(date.year, date.month, date.day));
  }
}

class _AgendaSummary extends StatelessWidget {
  const _AgendaSummary({required this.agenda});

  final DailyAgenda agenda;

  @override
  Widget build(BuildContext context) {
    final pendingCount = agenda.overdue.length + agenda.upcoming.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              pendingCount == 0 ? Icons.check_circle_outline : Icons.bolt,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                pendingCount == 0
                    ? 'You are all caught up'
                    : '$pendingCount ${pendingCount == 1 ? 'item' : 'items'} '
                          'to take care of',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (agenda.completed.isNotEmpty)
              Text(
                '${agenda.completed.length} done',
                style: Theme.of(context).textTheme.labelMedium,
              ),
          ],
        ),
      ),
    );
  }
}

class _AgendaItemCard extends StatelessWidget {
  const _AgendaItemCard({
    required this.item,
    required this.onComplete,
    required this.onSkip,
    required this.onSnooze,
    required this.onReschedule,
    required this.onUndo,
    required this.onDelete,
  });

  final AgendaItem item;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final VoidCallback onSnooze;
  final VoidCallback onReschedule;
  final VoidCallback onUndo;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final status = item.status;
    final leadingIcon = switch (status) {
      TaskStatus.completed => Icons.check_circle,
      TaskStatus.skipped => Icons.skip_next,
      TaskStatus.pending =>
        item.kind == AgendaItemKind.routine
            ? Icons.repeat
            : Icons.check_circle_outline,
    };
    final subtitle = [
      item.scheduledTime == null
          ? 'Any time'
          : TimeOfDay(
              hour: item.scheduledTime!.hour,
              minute: item.scheduledTime!.minute,
            ).format(context),
      item.kind == AgendaItemKind.routine ? 'Routine' : 'Task',
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          leadingIcon,
          color: status == TaskStatus.completed
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: status == TaskStatus.completed
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == TaskStatus.pending)
              IconButton(
                tooltip: 'Complete',
                onPressed: onComplete,
                icon: const Icon(Icons.check),
              ),
            PopupMenuButton<_AgendaAction>(
              tooltip: 'Task actions',
              onSelected: (action) {
                switch (action) {
                  case _AgendaAction.complete:
                    onComplete();
                  case _AgendaAction.skip:
                    onSkip();
                  case _AgendaAction.snooze:
                    onSnooze();
                  case _AgendaAction.reschedule:
                    onReschedule();
                  case _AgendaAction.undo:
                    onUndo();
                  case _AgendaAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (context) => [
                if (status == TaskStatus.pending) ...[
                  const PopupMenuItem(
                    value: _AgendaAction.complete,
                    child: Text('Complete'),
                  ),
                  const PopupMenuItem(
                    value: _AgendaAction.snooze,
                    child: Text('Snooze 10 minutes'),
                  ),
                  const PopupMenuItem(
                    value: _AgendaAction.reschedule,
                    child: Text('Reschedule'),
                  ),
                  const PopupMenuItem(
                    value: _AgendaAction.skip,
                    child: Text('Skip'),
                  ),
                ] else
                  const PopupMenuItem(
                    value: _AgendaAction.undo,
                    child: Text('Mark as pending'),
                  ),
                if (item.kind == AgendaItemKind.oneOff)
                  const PopupMenuItem(
                    value: _AgendaAction.delete,
                    child: Text('Delete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAgenda extends StatelessWidget {
  const _EmptyAgenda({required this.onAddTask});

  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Your day is clear',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a task or create a routine to start planning your day.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add),
              label: const Text('Add a task'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            const Text(
              'The agenda could not be loaded.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AgendaAction { complete, skip, snooze, reschedule, undo, delete }
