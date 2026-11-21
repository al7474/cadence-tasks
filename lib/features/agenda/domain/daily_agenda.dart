import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';

final class DailyAgenda {
  DailyAgenda({
    required List<AgendaItem> overdue,
    required List<AgendaItem> upcoming,
    required List<AgendaItem> completed,
  })  : overdue = List<AgendaItem>.unmodifiable(overdue),
        upcoming = List<AgendaItem>.unmodifiable(upcoming),
        completed = List<AgendaItem>.unmodifiable(completed);

  final List<AgendaItem> overdue;
  final List<AgendaItem> upcoming;
  final List<AgendaItem> completed;

  bool get isEmpty => overdue.isEmpty && upcoming.isEmpty && completed.isEmpty;
}
