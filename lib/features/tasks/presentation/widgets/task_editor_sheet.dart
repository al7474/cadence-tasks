import 'dart:async';

import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_rule.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/routines/domain/use_cases/create_routine.dart';
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
    this.task,
    this.routine,
    this.sourceOccurrence,
    this.initialDate,
    this.initialTime,
    this.startAsRoutine = false,
    super.key,
  }) : assert(task == null || routine == null);

  final OneOffTask? task;
  final RoutineTemplate? routine;
  final AgendaItem? sourceOccurrence;
  final LocalDate? initialDate;
  final LocalTime? initialTime;
  final bool startAsRoutine;

  @override
  ConsumerState<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends ConsumerState<TaskEditorSheet> {
  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();
  final _intervalController = TextEditingController();

  late _TaskType _type;
  late LocalDate _scheduledDate;
  late LocalDate _routineStartDate;
  LocalTime? _scheduledTime;
  late _RecurrenceMode _recurrenceMode;
  late Set<int> _weekdays;
  bool _reminderEnabled = false;
  bool _isSaving = false;
  OneOffTask? _savedOneOffTask;

  bool get _isEditing => widget.task != null || widget.routine != null;

  bool get _isConversion {
    return (widget.task != null && _type == _TaskType.routine) ||
        (widget.routine != null && _type == _TaskType.oneTime);
  }

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    final routine = widget.routine;
    _type = routine != null || widget.startAsRoutine
        ? _TaskType.routine
        : _TaskType.oneTime;
    _titleController.text = task?.title ?? routine?.title ?? '';
    _notesController.text = task?.notes ?? routine?.notes ?? '';
    _durationController.text =
        (task?.durationMinutes ?? routine?.durationMinutes)?.toString() ?? '';
    _intervalController.text = _intervalFor(routine?.recurrence).toString();
    _routineStartDate =
        routine?.startDate ??
        task?.scheduledDate ??
        widget.initialDate ??
        LocalDate.fromDateTime(DateTime.now());
    _scheduledDate =
        task?.scheduledDate ??
        widget.initialDate ??
        routine?.startDate ??
        LocalDate.fromDateTime(DateTime.now());
    _scheduledTime =
        task?.scheduledTime ??
        widget.sourceOccurrence?.scheduledTime ??
        routine?.targetTime ??
        widget.initialTime;
    _recurrenceMode = _modeFor(routine?.recurrence);
    _weekdays = _weekdaysFor(routine?.recurrence);
    _reminderEnabled =
        task?.reminderEnabled ?? routine?.reminderEnabled ?? false;
    if (_type == _TaskType.routine && _scheduledTime == null) {
      _scheduledTime = _localTime(7, 30);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _durationController.dispose();
    _intervalController.dispose();
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
                  _heading,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                SegmentedButton<_TaskType>(
                  segments: const [
                    ButtonSegment(
                      value: _TaskType.oneTime,
                      label: Text('One-time'),
                      icon: Icon(Icons.task_alt_outlined),
                    ),
                    ButtonSegment(
                      value: _TaskType.routine,
                      label: Text('Routine'),
                      icon: Icon(Icons.repeat),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) =>
                      _changeType(selection.first),
                ),
                if (_type == _TaskType.routine && widget.routine != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Changes apply to this routine and its future occurrences.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: _type == _TaskType.routine
                        ? 'Routine name'
                        : 'Task name',
                    hintText: 'What do you need to do?',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a name.';
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
                  title: Text(
                    _type == _TaskType.routine ? 'Starts on' : 'Date',
                  ),
                  subtitle: Text(_formatDate(_currentDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectDate,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_outlined),
                  title: Text(
                    _type == _TaskType.routine ? 'Target time' : 'Time',
                  ),
                  subtitle: Text(
                    _scheduledTime == null
                        ? 'No time set'
                        : _formatTime(context, _scheduledTime!),
                  ),
                  trailing: _scheduledTime == null || _type == _TaskType.routine
                      ? const Icon(Icons.chevron_right)
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
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Duration',
                    suffixText: 'minutes',
                    helperText: _type == _TaskType.routine
                        ? 'Optional. The calendar will show this routine for its duration.'
                        : 'Optional. Set a time to show this task as a calendar block.',
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validateDuration,
                ),
                if (_type == _TaskType.routine) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Repeats',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<_RecurrenceMode>(
                    segments: const [
                      ButtonSegment(
                        value: _RecurrenceMode.daily,
                        label: Text('Daily'),
                      ),
                      ButtonSegment(
                        value: _RecurrenceMode.weekdays,
                        label: Text('Weekdays'),
                      ),
                      ButtonSegment(
                        value: _RecurrenceMode.interval,
                        label: Text('Interval'),
                      ),
                    ],
                    selected: {_recurrenceMode},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _recurrenceMode = selection.first;
                      });
                    },
                  ),
                  if (_recurrenceMode == _RecurrenceMode.weekdays) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      children: List<Widget>.generate(7, (index) {
                        final weekday = index + 1;
                        final selected = _weekdays.contains(weekday);
                        return FilterChip(
                          label: Text(_weekdayLabels[index]),
                          selected: selected,
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                _weekdays.add(weekday);
                              } else {
                                _weekdays.remove(weekday);
                              }
                            });
                          },
                        );
                      }),
                    ),
                  ],
                  if (_recurrenceMode == _RecurrenceMode.interval) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _intervalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Repeat every',
                        suffixText: 'days',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final interval = int.tryParse(value ?? '');
                        if (interval == null || interval < 1) {
                          return 'Enter an interval of at least one day.';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 8),
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
                    subtitle: Text(
                      _type == _TaskType.routine
                          ? 'Remind me at the target time'
                          : 'Remind me at the scheduled time',
                    ),
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
                      : Icon(
                          _isConversion
                              ? Icons.swap_horiz
                              : _isEditing
                              ? Icons.save_outlined
                              : Icons.add,
                        ),
                  label: Text(_saveLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _heading {
    if (_isConversion) {
      return _type == _TaskType.routine
          ? 'Convert to routine'
          : 'Convert to task';
    }
    if (_isEditing) {
      return _type == _TaskType.routine ? 'Edit routine' : 'Edit task';
    }
    return _type == _TaskType.routine ? 'New routine' : 'Add a task';
  }

  String get _saveLabel {
    if (_isConversion) {
      return _type == _TaskType.routine
          ? 'Convert to routine'
          : 'Convert to one-time task';
    }
    if (_isEditing) {
      return 'Save changes';
    }
    return _type == _TaskType.routine ? 'Create routine' : 'Save task';
  }

  LocalDate get _currentDate {
    return _type == _TaskType.routine ? _routineStartDate : _scheduledDate;
  }

  void _changeType(_TaskType type) {
    if (type == _type) {
      return;
    }
    setState(() {
      if (type == _TaskType.routine) {
        _routineStartDate = widget.routine?.startDate ?? _scheduledDate;
        _scheduledTime ??= _localTime(7, 30);
      } else {
        _scheduledDate =
            widget.task?.scheduledDate ??
            widget.sourceOccurrence?.scheduledDate ??
            widget.initialDate ??
            _routineStartDate;
      }
      _type = type;
    });
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateTimeFor(_currentDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      final date = LocalDate.fromDateTime(selected);
      if (_type == _TaskType.routine) {
        _routineStartDate = date;
      } else {
        _scheduledDate = date;
      }
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

  String? _validateDuration(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    final durationMinutes = int.tryParse(trimmed);
    if (durationMinutes == null || durationMinutes < 1) {
      return 'Enter a duration of at least one minute.';
    }
    final scheduledTime = _scheduledTime;
    if (scheduledTime == null) {
      return 'Set a start time before adding a duration.';
    }
    if (scheduledTime.minutesSinceMidnight + durationMinutes > 1440) {
      return 'The duration must end before midnight.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_type == _TaskType.routine && _scheduledTime == null) {
      _showError('Set a target time for the routine.');
      return;
    }
    if (_isConversion && !await _confirmConversion()) {
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    final Result<Unit> result;
    if (_type == _TaskType.routine) {
      result = await _saveRoutine();
    } else {
      result = await _saveOneOffTask();
    }
    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<Unit>():
        final reminderResult = await _updateReminders();
        if (!mounted) {
          return;
        }
        if (reminderResult case FailureResult<Unit>(:final failure)) {
          _showError(
            '${_type == _TaskType.routine ? 'Routine' : 'Task'} saved, '
            'but reminders could not be updated: ${failure.message}',
          );
        }
        setState(() {
          _isSaving = false;
        });
        Navigator.of(context).pop(true);
      case FailureResult<Unit>(:final failure):
        setState(() {
          _isSaving = false;
        });
        _showError(failure.message);
    }
  }

  Future<Result<Unit>> _saveOneOffTask() async {
    final taskResult = OneOffTask.create(
      id: widget.task?.id ?? widget.routine?.id ?? const Uuid().v4(),
      title: _titleController.text,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      scheduledDate: _scheduledDate,
      scheduledTime: _scheduledTime,
      durationMinutes: int.tryParse(_durationController.text.trim()),
      reminderEnabled: _reminderEnabled,
      status:
          widget.task?.status ??
          widget.sourceOccurrence?.status ??
          TaskStatus.pending,
      completedAtUtc:
          widget.task?.completedAtUtc ??
          widget.sourceOccurrence?.completedAtUtc,
      snoozedUntilUtc:
          widget.task?.snoozedUntilUtc ??
          widget.sourceOccurrence?.snoozedUntilUtc,
    );
    switch (taskResult) {
      case FailureResult<OneOffTask>(:final failure):
        return FailureResult<Unit>(failure);
      case Success<OneOffTask>(:final value):
        final result = await _persistOneOffTask(value);
        if (result case Success<Unit>()) {
          _savedOneOffTask = value;
        }
        return result;
    }
  }

  Future<Result<Unit>> _persistOneOffTask(OneOffTask task) async {
    final taskRepository = ref.read(oneOffTaskRepositoryProvider);
    if (widget.task != null) {
      return taskRepository.save(task);
    }
    final sourceRoutine = widget.routine;
    if (sourceRoutine != null) {
      return ref
          .read(taskTypeConversionRepositoryProvider)
          .convertRoutineToOneOffTask(source: sourceRoutine, target: task);
    }

    final result = await CreateOneOffTask(taskRepository).execute(
      id: task.id,
      title: task.title,
      notes: task.notes,
      scheduledDate: task.scheduledDate,
      scheduledTime: task.scheduledTime,
      durationMinutes: task.durationMinutes,
      reminderEnabled: task.reminderEnabled,
    );
    return switch (result) {
      Success<OneOffTask>() => const Success<Unit>(Unit.value),
      FailureResult<OneOffTask>(:final failure) => FailureResult<Unit>(failure),
    };
  }

  Future<Result<Unit>> _saveRoutine() async {
    final time = _scheduledTime;
    if (time == null) {
      return const FailureResult<Unit>(
        ValidationFailure('A routine target time is required.'),
      );
    }
    final recurrenceResult = _buildRecurrence();
    late final RecurrenceRule recurrence;
    switch (recurrenceResult) {
      case Success<RecurrenceRule>(:final value):
        recurrence = value;
      case FailureResult<RecurrenceRule>(:final failure):
        return FailureResult<Unit>(failure);
    }

    final routineResult = RoutineTemplate.create(
      id: widget.routine?.id ?? widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      startDate: _routineStartDate,
      targetTime: time,
      durationMinutes: int.tryParse(_durationController.text.trim()),
      recurrence: recurrence,
      reminderEnabled: _reminderEnabled,
      isEnabled: widget.routine?.isEnabled ?? true,
    );
    switch (routineResult) {
      case FailureResult<RoutineTemplate>(:final failure):
        return FailureResult<Unit>(failure);
      case Success<RoutineTemplate>(:final value):
        final sourceTask = widget.task;
        if (sourceTask != null) {
          return ref
              .read(taskTypeConversionRepositoryProvider)
              .convertOneOffTaskToRoutine(source: sourceTask, target: value);
        }
        if (widget.routine != null) {
          return ref.read(routineRepositoryProvider).save(value);
        }
        final result = await CreateRoutine(ref.read(routineRepositoryProvider))
            .execute(
              id: value.id,
              title: value.title,
              notes: value.notes,
              startDate: value.startDate,
              targetTime: value.targetTime,
              durationMinutes: value.durationMinutes,
              recurrence: value.recurrence,
              reminderEnabled: value.reminderEnabled,
              isEnabled: value.isEnabled,
            );
        return switch (result) {
          Success<RoutineTemplate>() => const Success<Unit>(Unit.value),
          FailureResult<RoutineTemplate>(:final failure) => FailureResult<Unit>(
            failure,
          ),
        };
    }
  }

  Future<Result<Unit>> _updateReminders() async {
    if (_type == _TaskType.routine) {
      final sourceTask = widget.task;
      if (sourceTask != null) {
        final cancelled = await ref
            .read(notificationSchedulerProvider)
            .cancelReminder('one-off:${sourceTask.id}');
        if (cancelled case FailureResult<Unit>()) {
          return cancelled;
        }
      }
      return ref.read(reminderReconcilerProvider).reconcile();
    }

    final sourceRoutine = widget.routine;
    if (sourceRoutine != null) {
      final cancelled = await ref
          .read(notificationSchedulerProvider)
          .cancelRoutineReminders(sourceRoutine.id);
      if (cancelled case FailureResult<Unit>()) {
        return cancelled;
      }
    }

    final task = _savedOneOffTask;
    if (task == null) {
      return const FailureResult<Unit>(
        ValidationFailure(
          'The saved task is unavailable for reminder updates.',
        ),
      );
    }
    final item = AgendaItem(
      id: 'one-off:${task.id}',
      sourceId: task.id,
      sourceDate: task.scheduledDate,
      title: task.title,
      kind: AgendaItemKind.oneOff,
      scheduledDate: task.scheduledDate,
      scheduledTime: task.scheduledTime,
      durationMinutes: task.durationMinutes,
      status: task.status,
      reminderEnabled: task.reminderEnabled,
      completedAtUtc: task.completedAtUtc,
      snoozedUntilUtc: task.snoozedUntilUtc,
    );
    final scheduler = ref.read(notificationSchedulerProvider);
    if (task.reminderEnabled && task.status == TaskStatus.pending) {
      return scheduler.scheduleReminder(item);
    }
    if (widget.task != null) {
      return scheduler.cancelReminder(item.id);
    }
    return const Success<Unit>(Unit.value);
  }

  Result<RecurrenceRule> _buildRecurrence() {
    return switch (_recurrenceMode) {
      _RecurrenceMode.daily => const Success<RecurrenceRule>(DailyRecurrence()),
      _RecurrenceMode.weekdays => _toRecurrenceRule(
        WeekdayRecurrence.create(_weekdays),
      ),
      _RecurrenceMode.interval => _toRecurrenceRule(
        IntervalRecurrence.create(int.tryParse(_intervalController.text) ?? 0),
      ),
    };
  }

  Future<bool> _confirmConversion() async {
    final isBecomingRoutine = _type == _TaskType.routine;
    final date = _currentDate;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isBecomingRoutine ? 'Convert to a routine?' : 'Convert to a task?',
        ),
        content: Text(
          isBecomingRoutine
              ? 'This replaces the one-time task with a recurring routine '
                    'starting ${_formatDate(date)}. Its current status will '
                    'carry over to the first occurrence.'
              : 'This stops the recurring routine and creates a one-time task '
                    'for ${_formatDate(date)}. The selected occurrence status '
                    'will carry over, and existing routine history will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Convert'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static Result<RecurrenceRule> _toRecurrenceRule<T extends RecurrenceRule>(
    Result<T> result,
  ) {
    return switch (result) {
      Success<T>(:final value) => Success<RecurrenceRule>(value),
      FailureResult<T>(:final failure) => FailureResult<RecurrenceRule>(
        failure,
      ),
    };
  }

  static _RecurrenceMode _modeFor(RecurrenceRule? recurrence) {
    return switch (recurrence) {
      WeekdayRecurrence() => _RecurrenceMode.weekdays,
      IntervalRecurrence() => _RecurrenceMode.interval,
      _ => _RecurrenceMode.daily,
    };
  }

  static Set<int> _weekdaysFor(RecurrenceRule? recurrence) {
    return switch (recurrence) {
      WeekdayRecurrence(:final weekdaysIso) => {...weekdaysIso},
      _ => {
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
      },
    };
  }

  static int _intervalFor(RecurrenceRule? recurrence) {
    return switch (recurrence) {
      IntervalRecurrence(:final intervalDays) => intervalDays,
      _ => 2,
    };
  }

  static LocalTime _localTime(int hour, int minute) {
    return switch (LocalTime.create(hour: hour, minute: minute)) {
      Success<LocalTime>(:final value) => value,
      FailureResult<LocalTime>(:final failure) => throw StateError(
        failure.message,
      ),
    };
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

enum _TaskType { oneTime, routine }

enum _RecurrenceMode { daily, weekdays, interval }
