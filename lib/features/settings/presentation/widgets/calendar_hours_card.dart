import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/calendar/domain/calendar_display_settings.dart';
// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarHoursCard extends ConsumerWidget {
  const CalendarHoursCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(calendarDisplaySettingsProvider)
        .when(
          loading: () => const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Calendar hours'),
              subtitle: Text('Loading your display preferences.'),
            ),
          ),
          error: (error, stackTrace) => Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: const Text('Calendar hours unavailable'),
              subtitle: Text(error.toString()),
            ),
          ),
          data: (settings) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calendar hours',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'This range is saved to your account and syncs across devices.',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _CalendarHourDropdown(
                          label: 'Day starts',
                          hour: settings.startHour,
                          hours: [
                            for (var hour = 0; hour < settings.endHour; hour++)
                              hour,
                          ],
                          onChanged: (hour) => _save(
                            context,
                            ref,
                            startHour: hour,
                            endHour: settings.endHour,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CalendarHourDropdown(
                          label: 'Day ends',
                          hour: settings.endHour,
                          hours: [
                            for (
                              var hour = settings.startHour + 1;
                              hour < 24;
                              hour++
                            )
                              hour,
                          ],
                          onChanged: (hour) => _save(
                            context,
                            ref,
                            startHour: settings.startHour,
                            endHour: hour,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref, {
    required int startHour,
    required int endHour,
  }) async {
    final settingsResult = CalendarDisplaySettings.create(
      startHour: startHour,
      endHour: endHour,
    );
    switch (settingsResult) {
      case FailureResult<CalendarDisplaySettings>(:final failure):
        _showError(context, failure.message);
        return;
      case Success<CalendarDisplaySettings>(:final value):
        final result = await ref
            .read(calendarDisplaySettingsRepositoryProvider)
            .saveSettings(value);
        if (!context.mounted) {
          return;
        }
        if (result case FailureResult<Unit>(:final failure)) {
          _showError(context, failure.message);
        }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CalendarHourDropdown extends StatelessWidget {
  const _CalendarHourDropdown({
    required this.label,
    required this.hour,
    required this.hours,
    required this.onChanged,
  });

  final String label;
  final int hour;
  final List<int> hours;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: hour,
          isExpanded: true,
          items: [
            for (final item in hours)
              DropdownMenuItem<int>(
                value: item,
                child: Text(TimeOfDay(hour: item, minute: 0).format(context)),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}
