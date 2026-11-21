import 'dart:async';
import 'dart:convert';

import 'package:cadence_tasks/app/home_shell.dart';
import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/core/application/ports/notification_scheduler.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/core/domain/task_status.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CadenceApp extends ConsumerStatefulWidget {
  const CadenceApp({super.key});

  @override
  ConsumerState<CadenceApp> createState() => _CadenceAppState();
}

class _CadenceAppState extends ConsumerState<CadenceApp> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeNotifications());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadence Tasks',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF456B5B)),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }

  Future<void> _initializeNotifications() async {
    final result = await ref
        .read(notificationSchedulerProvider)
        .initialize(onAction: _handleNotificationAction);
    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<Unit>():
        ref.read(notificationSetupErrorProvider.notifier).state = null;
      case FailureResult<Unit>(:final failure):
        ref.read(notificationSetupErrorProvider.notifier).state =
            failure.message;
    }
  }

  void _handleNotificationAction(NotificationAction action) {
    final payload = action.payload;
    final actionId = action.actionId;
    if (payload == null || actionId == null) {
      return;
    }

    try {
      final item = _agendaItemFromPayload(payload);
      final controller = ref.read(agendaActionsControllerProvider);
      final operation = switch (actionId) {
        'complete' => controller.setStatus(item, TaskStatus.completed),
        'skip' => controller.setStatus(item, TaskStatus.skipped),
        'snooze' => controller.snooze(item),
        _ => throw FormatException('Unknown notification action: $actionId.'),
      };
      unawaited(_finishNotificationAction(operation, item));
    } on FormatException catch (error) {
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('The notification action failed: $error')),
      );
    }
  }

  Future<void> _finishNotificationAction(
    Future<Result<Unit>> operation,
    AgendaItem item,
  ) async {
    final result = await operation;
    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<Unit>():
        ref.invalidate(dailyAgendaProvider(item.scheduledDate));
      case FailureResult<Unit>(:final failure):
        ref.invalidate(dailyAgendaProvider(item.scheduledDate));
        _messengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  static AgendaItem _agendaItemFromPayload(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Notification payload must be an object.');
    }

    final Object? id = decoded['id'];
    final Object? sourceId = decoded['sourceId'];
    final Object? sourceDateValue = decoded['sourceDate'];
    final Object? scheduledDateValue = decoded['scheduledDate'];
    final Object? title = decoded['title'];
    final Object? kindValue = decoded['kind'];
    if (id is! String ||
        sourceId is! String ||
        sourceDateValue is! String ||
        scheduledDateValue is! String ||
        title is! String ||
        kindValue is! String) {
      throw const FormatException('Notification payload is missing task data.');
    }

    final sourceDate = _dateFromPayload(sourceDateValue);
    final scheduledDate = _dateFromPayload(scheduledDateValue);
    final kind = switch (kindValue) {
      'routine' => AgendaItemKind.routine,
      'oneOff' => AgendaItemKind.oneOff,
      _ => throw FormatException('Unknown notification item kind: $kindValue.'),
    };
    final Object? scheduledTimeValue = decoded['scheduledTimeMinutes'];
    final scheduledTime = scheduledTimeValue == null
        ? null
        : _timeFromPayload(scheduledTimeValue);
    final Object? reminderEnabled = decoded['reminderEnabled'];
    if (reminderEnabled is! bool) {
      throw const FormatException(
        'Notification payload is missing reminder state.',
      );
    }

    return AgendaItem(
      id: id,
      sourceId: sourceId,
      sourceDate: sourceDate,
      title: title,
      kind: kind,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      status: TaskStatus.pending,
      reminderEnabled: reminderEnabled,
    );
  }

  static LocalDate _dateFromPayload(String value) {
    return switch (LocalDate.parse(value)) {
      Success<LocalDate>(:final value) => value,
      FailureResult<LocalDate>(:final failure) => throw FormatException(
        failure.message,
      ),
    };
  }

  static LocalTime _timeFromPayload(Object value) {
    if (value is! int) {
      throw const FormatException('Notification time must be an integer.');
    }

    return switch (LocalTime.fromMinutesSinceMidnight(value)) {
      Success<LocalTime>(:final value) => value,
      FailureResult<LocalTime>(:final failure) => throw FormatException(
        failure.message,
      ),
    };
  }
}
