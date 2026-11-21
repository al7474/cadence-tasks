import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';

final class NotificationAction {
  const NotificationAction({required this.actionId, required this.payload});

  final String? actionId;
  final String? payload;
}

abstract interface class NotificationScheduler {
  Future<Result<Unit>> initialize({
    required void Function(NotificationAction action) onAction,
  });

  Future<Result<Unit>> requestPermissions();

  Future<Result<Unit>> scheduleReminder(AgendaItem item);

  Future<Result<Unit>> cancelReminder(String itemId);

  Future<Result<Unit>> cancelRoutineReminders(String routineId);
}
