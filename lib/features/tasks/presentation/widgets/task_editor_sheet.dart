import 'dart:async';

import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
import 'package:cadence_tasks/features/tasks/domain/one_off_task.dart';
import 'package:cadence_tasks/features/tasks/domain/use_cases/create_one_off_task.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TaskEditorSheet extends ConsumerStatefulWidget {
  const TaskEditorSheet({
    required this.initialDate,
    this.initialTime,
    super.key,
  });

  final LocalDate initialDate;
  final LocalTime? initialTime;

  @override
  ConsumerState<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends ConsumerState<TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late LocalDate _scheduledDate;
  LocalTime? _scheduledTime;
  bool _reminderEnabled = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _scheduledDate = widget.initialDate;
    _scheduledTime = widget.initialTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Add a task',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Task name',
                    hintText: 'What do you need to do?',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a task name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Date'),
                  subtitle: Text(_formatDate(_scheduledDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectDate,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Time'),
                  subtitle: Text(
                    _scheduledTime == null
                        ? 'No time set'
                        : _formatTime(context, _scheduledTime!),
                  ),
                  trailing: _scheduledTime == null
                      ? const Icon(Icons.add)
                      : IconButton(
                          tooltip: 'Clear time',
                          onPressed: () {
                            setState(() {
                              _scheduledTime = null;
                              _reminderEnabled = false;
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                  onTap: _selectTime,
                ),
                if (kIsWeb)
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.notifications_outlined),
                    title: Text('Reminders'),
                    subtitle: Text(
                      'Scheduled reminders are available on Android.',
                    ),
                  )
                else
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Reminder'),
                    subtitle: const Text('Remind me at the scheduled time'),
                    value: _reminderEnabled,
                    onChanged: (enabled) {
                      setState(() {
                        _reminderEnabled = enabled;
                      });
                      if (enabled && _scheduledTime == null) {
                        unawaited(_selectTime());
                      }
                    },
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: const Text('Save task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateTimeFor(_scheduledDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _scheduledDate = LocalDate.fromDateTime(selected);
    });
  }

  Future<void> _selectTime() async {
    final current = _scheduledTime;
    final selected = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (selected == null || !mounted) {
      return;
    }

    final result = LocalTime.create(
      hour: selected.hour,
      minute: selected.minute,
    );
    switch (result) {
      case Success<LocalTime>(:final value):
        setState(() {
          _scheduledTime = value;
        });
      case FailureResult<LocalTime>(:final failure):
        _showError(failure.message);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    final result =
        await CreateOneOffTask(ref.read(oneOffTaskRepositoryProvider)).execute(
          id: const Uuid().v4(),
          title: _titleController.text,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          scheduledDate: _scheduledDate,
          scheduledTime: _scheduledTime,
          reminderEnabled: _reminderEnabled,
        );
    switch (result) {
      case Success<OneOffTask>(:final value):
        if (value.reminderEnabled) {
          final scheduled = await ref
              .read(notificationSchedulerProvider)
              .scheduleReminder(
                AgendaItem(
                  id: 'one-off:${value.id}',
                  sourceId: value.id,
                  sourceDate: value.scheduledDate,
                  title: value.title,
                  kind: AgendaItemKind.oneOff,
                  scheduledDate: value.scheduledDate,
                  scheduledTime: value.scheduledTime,
                  status: value.status,
                  reminderEnabled: true,
                ),
              );
          if (!mounted) {
            return;
          }
          if (scheduled case FailureResult<Unit>(:final failure)) {
            _showError(
              'Task saved, but the reminder was not scheduled: '
              '${failure.message}',
            );
          }
        }
        if (!mounted) {
          return;
        }
        setState(() {
          _isSaving = false;
        });
        Navigator.of(context).pop(true);
      case FailureResult<OneOffTask>(:final failure):
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
        _showError(failure.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static DateTime _dateTimeFor(LocalDate date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String _formatDate(LocalDate date) {
    return DateFormat('EEE, MMM d, y', 'en_US').format(_dateTimeFor(date));
  }

  static String _formatTime(BuildContext context, LocalTime time) {
    return TimeOfDay(hour: time.hour, minute: time.minute).format(context);
  }
}
