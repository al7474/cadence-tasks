import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';

enum AgendaItemKind { routine, oneOff }

final class AgendaItem {
  const AgendaItem({
    required this.id,
    required this.sourceId,
    required this.sourceDate,
    required this.title,
    required this.kind,
    required this.scheduledDate,
    required this.status,
    required this.reminderEnabled,
    this.scheduledTime,
    this.durationMinutes,
    this.completedAtUtc,
    this.snoozedUntilUtc,
  });

  final String id;
  final String sourceId;
  final LocalDate sourceDate;
  final String title;
  final AgendaItemKind kind;
  final LocalDate scheduledDate;
  final LocalTime? scheduledTime;
  final int? durationMinutes;
  final DateTime? completedAtUtc;
  final TaskStatus status;
  final bool reminderEnabled;
  final DateTime? snoozedUntilUtc;
}
