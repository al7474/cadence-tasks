import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
import 'package:cadence_tasks/features/agenda/domain/daily_agenda.dart';
import 'package:cadence_tasks/features/calendar/domain/calendar_display_settings.dart';
import 'package:cadence_tasks/features/routines/presentation/widgets/routine_editor_sheet.dart';
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
    final schedules = <_DaySchedule>[];
    for (final date in dates) {
      final agendaState = ref.watch(dailyAgendaProvider(date));
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
      body: Column(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOptions(date: _selectedDate),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      children: [
        _AllDaySection(
          items: allDayItems,
          onAdd: () => _showCreateOptions(date: schedule.date),
          onOpenItem: _openItemActions,
        ),
        for (
          var hour = displaySettings.startHour;
          hour <= displaySettings.endHour;
          hour++
        )
          _HourTimelineRow(
            hour: hour,
            items: schedule.items
                .where((item) => item.scheduledTime?.hour == hour)
                .toList(growable: false),
            onAdd: () => _showCreateOptions(
              date: schedule.date,
              time: _timeAtHour(hour),
            ),
            onOpenItem: _openItemActions,
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
                    onTap: () => _showCreateOptions(date: schedule.date),
                  ),
                ),
            ],
          ),
          _WeekGridAllDayRow(
            schedules: schedules,
            items: allDayItems,
            onAdd: (date) => _showCreateOptions(date: date),
            onOpenItem: _openItemActions,
          ),
          for (
            var hour = displaySettings.startHour;
            hour <= displaySettings.endHour;
            hour++
          )
            _WeekGridHourRow(
              hour: hour,
              schedules: schedules,
              itemsForDay: (schedule) => schedule.items
                  .where((item) => item.scheduledTime?.hour == hour)
                  .toList(growable: false),
              onAdd: (date) =>
                  _showCreateOptions(date: date, time: _timeAtHour(hour)),
              onOpenItem: _openItemActions,
            ),
        ],
      ),
    );
  }

  Future<void> _showCreateOptions({
    required LocalDate date,
    LocalTime? time,
  }) async {
    final selection = await showModalBottomSheet<_CreateCalendarEntry>(
      context: context,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.task_alt_outlined),
              title: const Text('One-time task'),
              subtitle: Text(
                time == null
                    ? _formatFullDate(date)
                    : '${_formatFullDate(date)} at ${_formatTime(context, time)}',
              ),
              onTap: () => Navigator.of(context).pop(_CreateCalendarEntry.task),
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Repeating routine'),
              subtitle: const Text('Choose daily, weekdays, or an interval'),
              onTap: () =>
                  Navigator.of(context).pop(_CreateCalendarEntry.routine),
            ),
          ],
        ),
      ),
    );
    if (selection == null || !mounted) {
      return;
    }

    final bool? saved;
    switch (selection) {
      case _CreateCalendarEntry.task:
        saved = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => TaskEditorSheet(initialDate: date, initialTime: time),
        );
      case _CreateCalendarEntry.routine:
        saved = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) =>
              RoutineEditorSheet(initialDate: date, initialTime: time),
        );
    }

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

class _HourTimelineRow extends StatelessWidget {
  const _HourTimelineRow({
    required this.hour,
    required this.items,
    required this.onAdd,
    required this.onOpenItem,
  });

  final int hour;
  final List<AgendaItem> items;
  final VoidCallback onAdd;
  final ValueChanged<AgendaItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(hour: hour, minute: 0).format(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            height: items.isEmpty ? 54 : null,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(time, style: Theme.of(context).textTheme.labelSmall),
            ),
          ),
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: items.isEmpty ? 54 : 0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: items.isEmpty
                  ? InkWell(
                      onTap: onAdd,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          tooltip: 'Add at $time',
                          onPressed: onAdd,
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          for (final item in items)
                            _MobileEventCard(
                              item: item,
                              onTap: () => onOpenItem(item),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              tooltip: 'Add at $time',
                              onPressed: onAdd,
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 18,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
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

class _WeekGridHourRow extends StatelessWidget {
  const _WeekGridHourRow({
    required this.hour,
    required this.schedules,
    required this.itemsForDay,
    required this.onAdd,
    required this.onOpenItem,
  });

  final int hour;
  final List<_DaySchedule> schedules;
  final List<AgendaItem> Function(_DaySchedule schedule) itemsForDay;
  final ValueChanged<LocalDate> onAdd;
  final ValueChanged<AgendaItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final itemsByDay = schedules.map(itemsForDay).toList(growable: false);
    final maximumItemCount = itemsByDay
        .map((items) => items.length)
        .fold<int>(0, (current, count) => count > current ? count : current);
    final rowHeight = maximumItemCount == 0
        ? 48.0
        : (maximumItemCount * 32 + 22).toDouble();

    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                TimeOfDay(hour: hour, minute: 0).format(context),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          for (var index = 0; index < schedules.length; index++)
            Expanded(
              child: Container(
                height: rowHeight,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                    left: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
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

enum _CreateCalendarEntry { task, routine }

enum _CalendarItemAction { complete, skip, snooze, undo, delete }
