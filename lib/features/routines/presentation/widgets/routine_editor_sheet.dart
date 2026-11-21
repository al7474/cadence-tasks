import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/routines/domain/recurrence_rule.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/routines/domain/use_cases/create_routine.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class RoutineEditorSheet extends ConsumerStatefulWidget {
  const RoutineEditorSheet({this.routine, super.key});

  final RoutineTemplate? routine;

  @override
  ConsumerState<RoutineEditorSheet> createState() => _RoutineEditorSheetState();
}

class _RoutineEditorSheetState extends ConsumerState<RoutineEditorSheet> {
  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _intervalController;

  late LocalDate _startDate;
  late LocalTime _targetTime;
  late _RecurrenceMode _recurrenceMode;
  late Set<int> _weekdays;
  late bool _reminderEnabled;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final routine = widget.routine;
    _titleController = TextEditingController(text: routine?.title ?? '');
    _notesController = TextEditingController(text: routine?.notes ?? '');
    _intervalController = TextEditingController(
      text: _intervalFor(routine?.recurrence).toString(),
    );
    _startDate = routine?.startDate ?? LocalDate.fromDateTime(DateTime.now());
    _targetTime = routine?.targetTime ?? _localTime(7, 30);
    _recurrenceMode = _modeFor(routine?.recurrence);
    _weekdays = _weekdaysFor(routine?.recurrence);
    _reminderEnabled = routine?.reminderEnabled ?? !kIsWeb;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isEditing = widget.routine != null;

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
                  isEditing ? 'Edit routine' : 'New routine',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Routine name',
                    hintText: 'For example, morning walk',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a routine name.';
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
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Target time'),
                  subtitle: Text(_formatTime(context, _targetTime)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectTime,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Starts on'),
                  subtitle: Text(_formatDate(_startDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectStartDate,
                ),
                const SizedBox(height: 8),
                Text('Repeats', style: Theme.of(context).textTheme.titleSmall),
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
                    subtitle: const Text('Remind me at the target time'),
                    value: _reminderEnabled,
                    onChanged: (value) {
                      setState(() {
                        _reminderEnabled = value;
                      });
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
                      : Icon(isEditing ? Icons.save_outlined : Icons.add),
                  label: Text(isEditing ? 'Save changes' : 'Create routine'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _targetTime.hour,
        minute: _targetTime.minute,
      ),
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
          _targetTime = value;
        });
      case FailureResult<LocalTime>(:final failure):
        _showError(failure.message);
    }
  }

  Future<void> _selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(_startDate.year, _startDate.month, _startDate.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _startDate = LocalDate.fromDateTime(selected);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final recurrenceResult = _buildRecurrence();
    late final RecurrenceRule recurrence;
    switch (recurrenceResult) {
      case Success<RecurrenceRule>(:final value):
        recurrence = value;
      case FailureResult<RecurrenceRule>(:final failure):
        _showError(failure.message);
        return;
    }

    setState(() {
      _isSaving = true;
    });
    final routine = widget.routine;
    final result = await CreateRoutine(ref.read(routineRepositoryProvider))
        .execute(
          id: routine?.id ?? const Uuid().v4(),
          title: _titleController.text,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          startDate: _startDate,
          targetTime: _targetTime,
          recurrence: recurrence,
          reminderEnabled: _reminderEnabled,
          isEnabled: routine?.isEnabled ?? true,
        );

    switch (result) {
      case Success<RoutineTemplate>():
        final notificationResult = await ref
            .read(reminderReconcilerProvider)
            .reconcile();
        if (!mounted) {
          return;
        }
        if (notificationResult case FailureResult<Unit>(:final failure)) {
          _showError(
            'Routine saved, but reminders were not scheduled: '
            '${failure.message}',
          );
        }
        setState(() {
          _isSaving = false;
        });
        Navigator.of(context).pop(true);
      case FailureResult<RoutineTemplate>(:final failure):
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
        _showError(failure.message);
    }
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

enum _RecurrenceMode { daily, weekdays, interval }
