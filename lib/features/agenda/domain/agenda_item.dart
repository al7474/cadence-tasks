import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';

enum AgendaItemKind {
  routine,
  oneOff,
}

final class AgendaItem {
  const AgendaItem({
    required this.id,
    required this.title,
    required this.kind,
    required this.scheduledDate,
    required this.status,
    this.scheduledTime,
    this.snoozedUntilUtc,
  });

  final String id;
  final String title;
  final AgendaItemKind kind;
  final LocalDate scheduledDate;
  final LocalTime? scheduledTime;
  final TaskStatus status;
  final DateTime? snoozedUntilUtc;
}
