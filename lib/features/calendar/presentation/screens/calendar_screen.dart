import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
import 'package:cadence_tasks/features/agenda/domain/daily_agenda.dart';
import 'package:cadence_tasks/features/calendar/domain/calendar_display_settings.dart';
import 'package:cadence_tasks/features/tasks/presentation/widgets/task_editor_sheet.dart';
// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const _hourHeight = 64.0;

  late LocalDate _selectedDate = LocalDate.fromDateTime(DateTime.now());
  late LocalDate _weekStart = _startOfWeek(_selectedDate);

  List<LocalDate> get _weekDates {
    return List<LocalDate>.generate(7, _weekStart.addDays);
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(calendarDisplaySettingsProvider);
    final displaySettings = settingsState.asData?.value;
    if (displaySettings == null) {
      if (settingsState.asError != null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Calendar')),
          body: const Center(
            child: Text('Calendar display settings could not be loaded.'),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Calendar')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final dates = _weekDates;
    final agendaStates = [
      for (final date in dates) ref.watch(dailyAgendaProvider(date)),
    ];
    final schedules = <_DaySchedule>[];
    for (var index = 0; index < dates.length; index++) {
      final date = dates[index];
      final agendaState = agendaStates[index];
      final agenda = agendaState.asData?.value;
      if (agenda != null) {
        schedules.add(_DaySchedule(date: date, agenda: agenda));
        continue;
      }

      final error = agendaState.asError;
      if (error != null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Calendar')),
          body: _CalendarErrorView(
            onRetry: () {
              for (final weekDate in dates) {
                ref.invalidate(dailyAgendaProvider(weekDate));
              }
            },
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Calendar')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            tooltip: 'Choose date',
            onPressed: _chooseDate,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _weekToolbar(context, displaySettings),
              if (MediaQuery.sizeOf(context).width < 820)
                _weekdaySelector(context, schedules)
              else
                const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 820) {
                      return _weekGrid(context, schedules, displaySettings);
                    }
                    final selectedSchedule = schedules.firstWhere(
                      (schedule) => schedule.date == _selectedDate,
                    );
                    return _selectedDayTimeline(
                      context,
                      selectedSchedule,
                      displaySettings,
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: FloatingActionButton.extended(
                onPressed: () => _openEditor(date: _selectedDate),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekToolbar(
    BuildContext context,
    CalendarDisplaySettings displaySettings,
  ) {
    final firstDate = _weekStart;
    final lastDate = _weekStart.addDays(6);
    final sameMonth =
        firstDate.month == lastDate.month && firstDate.year == lastDate.year;
    final range = sameMonth
        ? '${_formatShortDate(firstDate)} - ${DateFormat('d, y', 'en_US').format(_toDateTime(lastDate))}'
        : '${_formatShortDate(firstDate)} - ${_formatShortDate(lastDate)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous week',
            onPressed: () => _moveWeek(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _formatMonth(firstDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(range, style: Theme.of(context).textTheme.labelMedium),
                Text(
                  '${_formatHour(context, displaySettings.startHour)} - '
                  '${_formatHour(context, displaySettings.endHour)}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          TextButton(onPressed: _showToday, child: const Text('Today')),
          IconButton(
            tooltip: 'Next week',
            onPressed: () => _moveWeek(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _weekdaySelector(BuildContext context, List<_DaySchedule> schedules) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        children: [
          for (final schedule in schedules)
            Expanded(
              child: _WeekdayButton(
                date: schedule.date,
                selected: schedule.date == _selectedDate,
                itemCount: schedule.items.length,
                onTap: () {
                  setState(() {
                    _selectedDate = schedule.date;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _selectedDayTimeline(
    BuildContext context,
    _DaySchedule schedule,
    CalendarDisplaySettings displaySettings,
  ) {
    final allDayItems = schedule.items
        .where((item) => item.scheduledTime == null)
        .toList(growable: false);
    final visibleEndHour = displaySettings.endHour + 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      children: [
        _AllDaySection(
          items: allDayItems,
          onAdd: () => _openEditor(date: schedule.date),
          onOpenItem: _openItemActions,
        ),
        SizedBox(
          height: (visibleEndHour - displaySettings.startHour) * _hourHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 62,
                child: _CalendarTimeAxis(
                  startHour: displaySettings.startHour,
                  endHour: displaySettings.endHour,
                  hourHeight: _hourHeight,
                ),
              ),
              Expanded(
                child: _TimedCalendarColumn(
                  startHour: displaySettings.startHour,
                  endHour: displaySettings.endHour,
                  hourHeight: _hourHeight,
                  items: schedule.items,
                  date: schedule.date,
                  onAdd: (hour) =>
                      _openEditor(date: schedule.date, time: _timeAtHour(hour)),
                  onOpenItem: _openItemActions,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _weekGrid(
    BuildContext context,
    List<_DaySchedule> schedules,
    CalendarDisplaySettings displaySettings,
  ) {
    final allDayItems = [
      for (final schedule in schedules)
        for (final item in schedule.items)
          if (item.scheduledTime == null) item,
    ];
    final visibleEndHour = displaySettings.endHour + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 100),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 56),
              for (final schedule in schedules)
                Expanded(
                  child: _WeekGridDayHeader(
                    date: schedule.date,
                    itemCount: schedule.items.length,
                    onTap: () => _openEditor(date: schedule.date),
                  ),
                ),
            ],
          ),
          _WeekGridAllDayRow(
            schedules: schedules,
            items: allDayItems,
            onAdd: (date) => _openEditor(date: date),
            onOpenItem: _openItemActions,
          ),
          SizedBox(
            height: (visibleEndHour - displaySettings.startHour) * _hourHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 56,
                  child: _CalendarTimeAxis(
                    startHour: displaySettings.startHour,
                    endHour: displaySettings.endHour,
                    hourHeight: _hourHeight,
                  ),
                ),
                for (final schedule in schedules)
                  Expanded(
                    child: _TimedCalendarColumn(
                      startHour: displaySettings.startHour,
                      endHour: displaySettings.endHour,
                      hourHeight: _hourHeight,
                      items: schedule.items,
                      date: schedule.date,
                      onAdd: (hour) => _openEditor(
                        date: schedule.date,
                        time: _timeAtHour(hour),
                      ),
                      onOpenItem: _openItemActions,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor({required LocalDate date, LocalTime? time}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => TaskEditorSheet(initialDate: date, initialTime: time),
    );
    if (saved == true && mounted) {
      ref.invalidate(dailyAgendaProvider);
      ref.invalidate(routinesProvider);
    }
  }

  Future<void> _editItem(AgendaItem item) async {
    late final Widget editor;
    if (item.kind == AgendaItemKind.oneOff) {
      final result = await ref
          .read(oneOffTaskRepositoryProvider)
          .getScheduledFor(item.scheduledDate);
      if (!mounted) {
        return;
      }
      switch (result) {
        case FailureResult(:final failure):
          _showError(failure.message);
          return;
        case Success(:final value):
          final matches = value.where((task) => task.id == item.sourceId);
          if (matches.isEmpty) {
            _showError(
              'This task is no longer available. Refresh and try again.',
            );
            return;
          }
          editor = TaskEditorSheet(task: matches.first);
      }
    } else {
      final result = await ref.read(routineRepositoryProvider).getAllRoutines();
      if (!mounted) {
        return;
      }
      switch (result) {
        case FailureResult(:final failure):
          _showError(failure.message);
          return;
        case Success(:final value):
          final matches = value.where((routine) => routine.id == item.sourceId);
          if (matches.isEmpty) {
            _showError(
              'This routine is no longer available. Refresh and try again.',
            );
            return;
          }
          editor = TaskEditorSheet(
            routine: matches.first,
            sourceOccurrence: item,
            initialDate: item.scheduledDate,
            initialTime: item.scheduledTime,
          );
      }
    }

    if (!mounted) {
      return;
    }
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => editor,
    );
    if (saved == true && mounted) {
      ref.invalidate(dailyAgendaProvider);
      ref.invalidate(routinesProvider);
    }
  }

  Future<void> _openItemActions(AgendaItem item) async {
    final action = await showModalBottomSheet<_CalendarItemAction>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        final time = item.scheduledTime;
        final timeLabel = time == null ? 'All day' : _formatTime(context, time);
        final typeLabel = item.kind == AgendaItemKind.routine
            ? 'Routine'
            : 'One-time task';

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(item.title),
                subtitle: Text(
                  '$typeLabel - ${_formatFullDate(item.scheduledDate)} - $timeLabel - ${_statusLabel(item.status)}',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit details'),
                subtitle: const Text(
                  'Change the type, schedule, or repeat pattern.',
                ),
                onTap: () =>
                    Navigator.of(context).pop(_CalendarItemAction.edit),
              ),
              if (item.status == TaskStatus.pending) ...[
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('Mark complete'),
                  onTap: () =>
                      Navigator.of(context).pop(_CalendarItemAction.complete),
                ),
                ListTile(
                  leading: const Icon(Icons.skip_next_outlined),
                  title: const Text('Skip'),
                  onTap: () =>
                      Navigator.of(context).pop(_CalendarItemAction.skip),
                ),
                ListTile(
                  leading: const Icon(Icons.snooze_outlined),
                  title: const Text('Snooze 10 minutes'),
                  onTap: () =>
                      Navigator.of(context).pop(_CalendarItemAction.snooze),
                ),
              ] else
                ListTile(
                  leading: const Icon(Icons.undo),
                  title: const Text('Mark as pending'),
                  onTap: () =>
                      Navigator.of(context).pop(_CalendarItemAction.undo),
                ),
              if (item.kind == AgendaItemKind.oneOff)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Delete task',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () =>
                      Navigator.of(context).pop(_CalendarItemAction.delete),
                ),
            ],
          ),
        );
      },
    );
    if (action == null || !mounted) {
      return;
    }
    if (action == _CalendarItemAction.edit) {
      await _editItem(item);
      return;
    }

    final controller = ref.read(agendaActionsControllerProvider);
    final result = switch (action) {
      _CalendarItemAction.complete => controller.setStatus(
        item,
        TaskStatus.completed,
      ),
      _CalendarItemAction.skip => controller.setStatus(
        item,
        TaskStatus.skipped,
      ),
      _CalendarItemAction.snooze => controller.snooze(item),
      _CalendarItemAction.undo => controller.setStatus(
        item,
        TaskStatus.pending,
      ),
      _CalendarItemAction.delete => controller.deleteOneOffTask(item),
      _CalendarItemAction.edit => throw StateError(
        'Edit actions must be handled before task status actions.',
      ),
    };

    switch (await result) {
      case Success<Unit>():
        ref.invalidate(dailyAgendaProvider);
      case FailureResult<Unit>(:final failure):
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        }
    }
  }

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _toDateTime(_selectedDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = LocalDate.fromDateTime(selected);
      _weekStart = _startOfWeek(_selectedDate);
    });
  }

  void _moveWeek(int weeks) {
    setState(() {
      _weekStart = _weekStart.addDays(weeks * 7);
      _selectedDate = _selectedDate.addDays(weeks * 7);
    });
  }

  void _showToday() {
    setState(() {
      _selectedDate = LocalDate.fromDateTime(DateTime.now());
      _weekStart = _startOfWeek(_selectedDate);
    });
  }

  static LocalDate _startOfWeek(LocalDate date) {
    return date.addDays(-(date.weekday - DateTime.monday));
  }

  static LocalTime _timeAtHour(int hour) {
    return switch (LocalTime.create(hour: hour, minute: 0)) {
      Success<LocalTime>(:final value) => value,
      FailureResult<LocalTime>(:final failure) => throw StateError(
        failure.message,
      ),
    };
  }

  static String _statusLabel(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => 'Pending',
      TaskStatus.completed => 'Completed',
      TaskStatus.skipped => 'Skipped',
    };
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static DateTime _toDateTime(LocalDate date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String _formatMonth(LocalDate date) {
    return DateFormat('MMMM y', 'en_US').format(_toDateTime(date));
  }

  static String _formatShortDate(LocalDate date) {
    return DateFormat('MMM d', 'en_US').format(_toDateTime(date));
  }

  static String _formatFullDate(LocalDate date) {
    return DateFormat('EEE, MMM d, y', 'en_US').format(_toDateTime(date));
  }

  static String _formatTime(BuildContext context, LocalTime time) {
    return TimeOfDay(hour: time.hour, minute: time.minute).format(context);
  }

  static String _formatHour(BuildContext context, int hour) {
    return TimeOfDay(hour: hour, minute: 0).format(context);
  }
}

final class _DaySchedule {
  const _DaySchedule({required this.date, required this.agenda});

  final LocalDate date;
  final DailyAgenda agenda;

  List<AgendaItem> get items {
    final result = [...agenda.overdue, ...agenda.upcoming, ...agenda.completed];
    result.sort(_compareSchedule);
    return result;
  }

  static int _compareSchedule(AgendaItem first, AgendaItem second) {
    final firstTime = first.scheduledTime;
    final secondTime = second.scheduledTime;
    if (firstTime == null && secondTime != null) {
      return 1;
    }
    if (firstTime != null && secondTime == null) {
      return -1;
    }
    if (firstTime != null && secondTime != null) {
      final timeComparison = firstTime.compareTo(secondTime);
      if (timeComparison != 0) {
        return timeComparison;
      }
    }
    return first.title.compareTo(second.title);
  }
}

class _WeekdayButton extends StatelessWidget {
  const _WeekdayButton({
    required this.date,
    required this.selected,
    required this.itemCount,
    required this.onTap,
  });

  final LocalDate date;
  final bool selected;
  final int itemCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime(date.year, date.month, date.day);
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: DateFormat('EEEE, MMMM d, y', 'en_US').format(dateTime),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('EEEEE', 'en_US').format(dateTime),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? colorScheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: selected ? colorScheme.onPrimary : null,
                    fontWeight: selected ? FontWeight.bold : null,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: itemCount == 0
                      ? Colors.transparent
                      : selected
                      ? colorScheme.primary
                      : colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllDaySection extends StatelessWidget {
  const _AllDaySection({
    required this.items,
    required this.onAdd,
    required this.onOpenItem,
  });

  final List<AgendaItem> items;
  final VoidCallback onAdd;
  final ValueChanged<AgendaItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'All day',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in items)
                  _MobileEventCard(item: item, onTap: () => onOpenItem(item)),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Add an all-day item',
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarTimeAxis extends StatelessWidget {
  const _CalendarTimeAxis({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (endHour - startHour + 1) * hourHeight,
      child: Stack(
        children: [
          for (var hour = startHour; hour <= endHour; hour++)
            Positioned(
              top: (hour - startHour) * hourHeight + 4,
              left: 0,
              right: 4,
              child: Text(
                TimeOfDay(hour: hour, minute: 0).format(context),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimedCalendarColumn extends StatelessWidget {
  const _TimedCalendarColumn({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.items,
    required this.date,
    required this.onAdd,
    required this.onOpenItem,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final List<AgendaItem> items;
  final LocalDate date;
  final ValueChanged<int> onAdd;
  final ValueChanged<AgendaItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final visibleStartMinute = startHour * 60;
    final visibleEndMinute = (endHour + 1) * 60;
    final visibleItems = items
        .where((item) {
          final time = item.scheduledTime;
          if (time == null) {
            return false;
          }
          final startMinute = time.minutesSinceMidnight;
          final endMinute = startMinute + (item.durationMinutes ?? 30);
          return startMinute < visibleEndMinute &&
              endMinute > visibleStartMinute;
        })
        .toList(growable: false);
    final placements = _placeTimedEvents(visibleItems);
    final gridHeight = (endHour - startHour + 1) * hourHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final children = <Widget>[
          for (var hour = startHour; hour <= endHour; hour++)
            Positioned(
              top: (hour - startHour) * hourHeight,
              left: 0,
              right: 0,
              height: hourHeight,
              child: InkWell(
                onTap: () => onAdd(hour),
                child: Container(
                  key: ValueKey<String>('calendar-slot:${date.iso8601}:$hour'),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                      left: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  alignment: Alignment.topRight,
                  child:
                      visibleItems.any(
                        (item) => item.scheduledTime!.hour == hour,
                      )
                      ? null
                      : Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.add,
                            size: 14,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                ),
              ),
            ),
          for (final placement in placements)
            _positionedEvent(
              context,
              placement,
              constraints.maxWidth,
              visibleStartMinute,
              visibleEndMinute,
            ),
        ];

        return SizedBox(
          height: gridHeight,
          child: Stack(clipBehavior: Clip.hardEdge, children: children),
        );
      },
    );
  }

  Widget _positionedEvent(
    BuildContext context,
    _TimedEventPlacement placement,
    double columnWidth,
    int visibleStartMinute,
    int visibleEndMinute,
  ) {
    final item = placement.item;
    final startMinute = item.scheduledTime!.minutesSinceMidnight;
    final durationMinutes = _visualDurationMinutes(item);
    final endMinute = startMinute + durationMinutes;
    final clippedStartMinute = startMinute > visibleStartMinute
        ? startMinute
        : visibleStartMinute;
    final clippedEndMinute = endMinute < visibleEndMinute
        ? endMinute
        : visibleEndMinute;
    final availableHeight =
        (clippedEndMinute - clippedStartMinute) * hourHeight / 60;
    final verticalInset = availableHeight >= 6 ? 2.0 : availableHeight / 3;
    final height = availableHeight - verticalInset * 2;
    const horizontalInset = 2.0;
    const laneGap = 2.0;
    final laneWidth =
        (columnWidth -
            horizontalInset * 2 -
            laneGap * (placement.laneCount - 1)) /
        placement.laneCount;

    return Positioned(
      top:
          (clippedStartMinute - visibleStartMinute) * hourHeight / 60 +
          verticalInset,
      left: horizontalInset + placement.lane * (laneWidth + laneGap),
      width: laneWidth,
      height: height,
      child: _TimedEventBlock(
        key: ValueKey<String>('calendar-event:${item.id}'),
        item: item,
        onTap: () => onOpenItem(item),
      ),
    );
  }
}

List<_TimedEventPlacement> _placeTimedEvents(List<AgendaItem> items) {
  final events =
      items.map((item) {
        final startMinute = item.scheduledTime!.minutesSinceMidnight;
        return _TimedEventRange(
          item: item,
          startMinute: startMinute,
          endMinute: startMinute + _visualDurationMinutes(item),
        );
      }).toList()..sort((first, second) {
        final startComparison = first.startMinute.compareTo(second.startMinute);
        return startComparison != 0
            ? startComparison
            : first.endMinute.compareTo(second.endMinute);
      });

  final placements = <_TimedEventPlacement>[];
  var group = <_TimedEventRange>[];
  var groupEndMinute = 0;

  void flushGroup() {
    final laneEnds = <int>[];
    final groupPlacements = <({int lane, _TimedEventRange event})>[];
    for (final event in group) {
      var lane = laneEnds.indexWhere((end) => end <= event.startMinute);
      if (lane == -1) {
        lane = laneEnds.length;
        laneEnds.add(event.endMinute);
      } else {
        laneEnds[lane] = event.endMinute;
      }
      groupPlacements.add((lane: lane, event: event));
    }

    for (final placement in groupPlacements) {
      placements.add(
        _TimedEventPlacement(
          item: placement.event.item,
          lane: placement.lane,
          laneCount: laneEnds.length,
        ),
      );
    }
    group = <_TimedEventRange>[];
    groupEndMinute = 0;
  }

  for (final event in events) {
    if (group.isNotEmpty && event.startMinute >= groupEndMinute) {
      flushGroup();
    }
    group.add(event);
    if (event.endMinute > groupEndMinute || group.length == 1) {
      groupEndMinute = event.endMinute;
    }
  }
  if (group.isNotEmpty) {
    flushGroup();
  }

  return placements;
}

int _visualDurationMinutes(AgendaItem item) {
  final duration = item.durationMinutes;
  return duration == null
      ? 30
      : duration < 20
      ? 20
      : duration;
}

final class _TimedEventRange {
  const _TimedEventRange({
    required this.item,
    required this.startMinute,
    required this.endMinute,
  });

  final AgendaItem item;
  final int startMinute;
  final int endMinute;
}

final class _TimedEventPlacement {
  const _TimedEventPlacement({
    required this.item,
    required this.lane,
    required this.laneCount,
  });

  final AgendaItem item;
  final int lane;
  final int laneCount;
}

class _TimedEventBlock extends StatelessWidget {
  const _TimedEventBlock({required this.item, required this.onTap, super.key});

  final AgendaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isComplete = item.status != TaskStatus.pending;
    final timeRange = _timeRange(context, item);

    return Tooltip(
      message: '${item.title} · $timeRange',
      child: Material(
        color: isComplete
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.durationMinutes == null
                        ? '${_startTime(context, item)} ${item.title}'
                        : item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  if (item.durationMinutes != null &&
                      constraints.maxHeight >= 38)
                    Text(
                      timeRange,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _timeRange(BuildContext context, AgendaItem item) {
    final start = item.scheduledTime!;
    final startLabel = _startTime(context, item);
    final duration = item.durationMinutes;
    if (duration == null) {
      return startLabel;
    }
    final endMinute = (start.minutesSinceMidnight + duration) % 1440;
    final endLabel = TimeOfDay(
      hour: endMinute ~/ 60,
      minute: endMinute % 60,
    ).format(context);
    return '$startLabel - $endLabel';
  }

  static String _startTime(BuildContext context, AgendaItem item) {
    final time = item.scheduledTime!;
    return TimeOfDay(hour: time.hour, minute: time.minute).format(context);
  }
}

class _MobileEventCard extends StatelessWidget {
  const _MobileEventCard({required this.item, required this.onTap});

  final AgendaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isComplete = item.status != TaskStatus.pending;
    final time = item.scheduledTime;
    final timeLabel = time == null
        ? item.kind == AgendaItemKind.routine
              ? 'Routine'
              : 'All day'
        : TimeOfDay(hour: time.hour, minute: time.minute).format(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      color: isComplete ? colorScheme.surfaceContainerHighest : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(
                item.kind == AgendaItemKind.routine
                    ? Icons.repeat
                    : Icons.task_alt_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    decoration: item.status == TaskStatus.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(timeLabel, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekGridDayHeader extends StatelessWidget {
  const _WeekGridDayHeader({
    required this.date,
    required this.itemCount,
    required this.onTap,
  });

  final LocalDate date;
  final int itemCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime(date.year, date.month, date.day);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              DateFormat('EEE', 'en_US').format(dateTime),
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text('${date.day}', style: Theme.of(context).textTheme.titleSmall),
            Text(
              '$itemCount items',
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekGridAllDayRow extends StatelessWidget {
  const _WeekGridAllDayRow({
    required this.schedules,
    required this.items,
    required this.onAdd,
    required this.onOpenItem,
  });

  final List<_DaySchedule> schedules;
  final List<AgendaItem> items;
  final ValueChanged<LocalDate> onAdd;
  final ValueChanged<AgendaItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final itemsByDay = [
      for (final schedule in schedules)
        items
            .where((item) => item.scheduledDate == schedule.date)
            .toList(growable: false),
    ];
    final maximumItemCount = itemsByDay
        .map((dayItems) => dayItems.length)
        .fold<int>(0, (current, count) => count > current ? count : current);
    final rowHeight = maximumItemCount == 0
        ? 52.0
        : (maximumItemCount * 32 + 22).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border.symmetric(
          horizontal: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            height: rowHeight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'All day',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          for (var index = 0; index < schedules.length; index++)
            Expanded(
              child: SizedBox(
                height: rowHeight,
                child: _WeekGridCell(
                  items: itemsByDay[index],
                  onAdd: () => onAdd(schedules[index].date),
                  onOpenItem: onOpenItem,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekGridCell extends StatelessWidget {
  const _WeekGridCell({
    required this.items,
    required this.onAdd,
    required this.onOpenItem,
  });

  final List<AgendaItem> items;
  final VoidCallback onAdd;
  final ValueChanged<AgendaItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return InkWell(
        onTap: onAdd,
        child: Center(
          child: Icon(
            Icons.add,
            size: 16,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final item in items)
          SizedBox(
            height: 32,
            child: Tooltip(
              message:
                  '${item.title} - ${item.kind == AgendaItemKind.routine ? 'Routine' : 'Task'}',
              child: InkWell(
                onTap: () => onOpenItem(item),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: item.status == TaskStatus.pending
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _gridEventLabel(context, item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: 'Add at this time',
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 14),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 20, height: 18),
          ),
        ),
      ],
    );
  }

  static String _gridEventLabel(BuildContext context, AgendaItem item) {
    final time = item.scheduledTime;
    final timeLabel = time == null
        ? ''
        : TimeOfDay(hour: time.hour, minute: time.minute).format(context);
    return timeLabel.isEmpty ? item.title : '$timeLabel ${item.title}';
  }
}

class _CalendarErrorView extends StatelessWidget {
  const _CalendarErrorView({required this.onRetry});

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
              'The weekly calendar could not be loaded.',
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

enum _CalendarItemAction { edit, complete, skip, snooze, undo, delete }
