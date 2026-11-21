import 'dart:convert';

import 'package:cadence_tasks/core/application/ports/notification_scheduler.dart';
import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/features/agenda/domain/agenda_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

final class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _notificationChannelId = 'cadence_task_reminders';
  static const _notificationChannelName = 'Task reminders';
  static const _notificationChannelDescription =
      'Reminders for routines and scheduled tasks.';
  static const _completeActionId = 'complete';
  static const _snoozeActionId = 'snooze';
  static const _skipActionId = 'skip';

  final FlutterLocalNotificationsPlugin _plugin;
  void Function(NotificationAction action)? _onAction;
  Future<Result<Unit>>? _initialization;
  bool _initialized = false;

  @override
  Future<Result<Unit>> initialize({
    required void Function(NotificationAction action) onAction,
  }) {
    _onAction = onAction;
    if (_initialized) {
      return Future<Result<Unit>>.value(const Success<Unit>(Unit.value));
    }
    return _initialization ??= _initializeOnce();
  }

  Future<Result<Unit>> _initializeOnce() async {
    try {
      if (!kIsWeb) {
        timezone_data.initializeTimeZones();
        final deviceTimezone = await FlutterTimezone.getLocalTimezone();
        timezone.setLocalLocation(
          timezone.getLocation(deviceTimezone.identifier),
        );
      }

      final initialized = await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
        ),
        onDidReceiveNotificationResponse: _handleResponse,
      );
      if (initialized != true) {
        return const FailureResult<Unit>(
          UnavailableFailure('Local notifications could not be initialized.'),
        );
      }

      _initialized = true;
      if (!kIsWeb) {
        final launchDetails = await _plugin.getNotificationAppLaunchDetails();
        final response = launchDetails?.notificationResponse;
        if (launchDetails?.didNotificationLaunchApp == true &&
            response != null) {
          _handleResponse(response);
        }
      }

      return const Success<Unit>(Unit.value);
    } on MissingPluginException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          'The notification plugin is unavailable: ${error.message ?? 'no platform handler'}',
        ),
      );
    } on PlatformException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          error.message ?? 'The notification platform is unavailable.',
        ),
      );
    } on ArgumentError catch (error) {
      return FailureResult<Unit>(UnavailableFailure(error.toString()));
    } on timezone.LocationNotFoundException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          'The device time zone is not available: ${error.msg}',
        ),
      );
    } finally {
      if (!_initialized) {
        _initialization = null;
      }
    }
  }

  @override
  Future<Result<Unit>> requestPermissions() async {
    if (kIsWeb) {
      return const FailureResult<Unit>(
        UnavailableFailure(
          'Scheduled reminders are only available on Android.',
        ),
      );
    }

    final initialization = await _ensureInitialized();
    if (initialization case FailureResult<Unit>()) {
      return initialization;
    }

    if (defaultTargetPlatform != TargetPlatform.android) {
      return const FailureResult<Unit>(
        UnavailableFailure(
          'Scheduled reminders are only supported on Android.',
        ),
      );
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return const FailureResult<Unit>(
        UnavailableFailure('The Android notification service is unavailable.'),
      );
    }

    try {
      final notificationsGranted = await android
          .requestNotificationsPermission();
      if (notificationsGranted != true) {
        return const FailureResult<Unit>(
          UnavailableFailure('Notification permission was not granted.'),
        );
      }

      final canScheduleExact = await android.canScheduleExactNotifications();
      if (canScheduleExact != true) {
        final exactAlarmGranted = await android.requestExactAlarmsPermission();
        if (exactAlarmGranted != true) {
          return const FailureResult<Unit>(
            UnavailableFailure(
              'Exact alarm permission is required for timed reminders.',
            ),
          );
        }
      }

      return const Success<Unit>(Unit.value);
    } on PlatformException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          error.message ?? 'Android notification permission could not be read.',
        ),
      );
    }
  }

  @override
  Future<Result<Unit>> scheduleReminder(AgendaItem item) async {
    if (item.scheduledTime == null) {
      return const FailureResult<Unit>(
        ValidationFailure('A reminder requires a scheduled time.'),
      );
    }
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const FailureResult<Unit>(
        UnavailableFailure(
          'Scheduled reminders are only available on Android.',
        ),
      );
    }

    final permissions = await requestPermissions();
    if (permissions case FailureResult<Unit>()) {
      return permissions;
    }

    return _scheduleInitialized(item);
  }

  @override
  Future<Result<Unit>> cancelReminder(String itemId) async {
    final initialization = await _ensureInitialized();
    if (initialization case FailureResult<Unit>()) {
      return initialization;
    }

    try {
      await _plugin.cancel(id: _notificationIdFor(itemId));
      return const Success<Unit>(Unit.value);
    } on PlatformException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          error.message ?? 'The reminder could not be cancelled.',
        ),
      );
    }
  }

  @override
  Future<Result<Unit>> cancelRoutineReminders(String routineId) async {
    if (kIsWeb) {
      return const Success<Unit>(Unit.value);
    }
    final initialization = await _ensureInitialized();
    if (initialization case FailureResult<Unit>()) {
      return initialization;
    }

    try {
      final pending = await _plugin.pendingNotificationRequests();
      for (final request in pending) {
        final payload = request.payload;
        if (payload == null) {
          continue;
        }
        final decoded = jsonDecode(payload);
        if (decoded is Map<String, dynamic> &&
            decoded['kind'] == AgendaItemKind.routine.name &&
            decoded['sourceId'] == routineId) {
          await _plugin.cancel(id: request.id);
        }
      }
      return const Success<Unit>(Unit.value);
    } on FormatException {
      return const FailureResult<Unit>(
        UnavailableFailure('A stored notification payload is invalid.'),
      );
    } on MissingPluginException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          'The notification plugin is unavailable: ${error.message ?? 'no platform handler'}',
        ),
      );
    } on PlatformException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          error.message ?? 'Routine reminders could not be cancelled.',
        ),
      );
    }
  }

  Future<Result<Unit>> _scheduleInitialized(AgendaItem item) async {
    final scheduledTime = item.scheduledTime;
    if (scheduledTime == null) {
      return const FailureResult<Unit>(
        ValidationFailure('A reminder requires a scheduled time.'),
      );
    }

    final localDateTime = DateTime(
      item.scheduledDate.year,
      item.scheduledDate.month,
      item.scheduledDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    final scheduledDate = timezone.TZDateTime.from(
      localDateTime,
      timezone.local,
    );
    if (!scheduledDate.isAfter(timezone.TZDateTime.now(timezone.local))) {
      return const FailureResult<Unit>(
        ValidationFailure('The reminder time must be in the future.'),
      );
    }

    try {
      await _plugin.zonedSchedule(
        id: _notificationIdFor(item.id),
        title: item.title,
        body: _notificationBody(item),
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _notificationChannelId,
            _notificationChannelName,
            channelDescription: _notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            actions: [
              AndroidNotificationAction(
                _completeActionId,
                'Complete',
                showsUserInterface: true,
              ),
              AndroidNotificationAction(
                _snoozeActionId,
                'Snooze 10 min',
                showsUserInterface: true,
              ),
              AndroidNotificationAction(
                _skipActionId,
                'Skip',
                showsUserInterface: true,
              ),
            ],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: _encodePayload(item),
      );
      return const Success<Unit>(Unit.value);
    } on MissingPluginException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          'The notification plugin is unavailable: ${error.message ?? 'no platform handler'}',
        ),
      );
    } on PlatformException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          error.message ?? 'The reminder could not be scheduled.',
        ),
      );
    }
  }

  Future<Result<Unit>> _ensureInitialized() async {
    if (_initialized) {
      return const Success<Unit>(Unit.value);
    }

    return initialize(onAction: _onAction ?? (_) {});
  }

  void _handleResponse(NotificationResponse response) {
    _onAction?.call(
      NotificationAction(
        actionId: response.actionId,
        payload: response.payload,
      ),
    );
  }

  static String _encodePayload(AgendaItem item) {
    return jsonEncode({
      'id': item.id,
      'kind': item.kind.name,
      'sourceId': item.sourceId,
      'sourceDate': item.sourceDate.iso8601,
      'scheduledDate': item.scheduledDate.iso8601,
      'scheduledTimeMinutes': item.scheduledTime?.minutesSinceMidnight,
      'title': item.title,
      'reminderEnabled': item.reminderEnabled,
    });
  }

  static String _notificationBody(AgendaItem item) {
    final time = item.scheduledTime;
    return time == null ? item.title : 'Scheduled for $time';
  }

  static int _notificationIdFor(String key) {
    var hash = 0x811c9dc5;
    for (final unit in key.codeUnits) {
      hash = (hash ^ unit) * 0x01000193;
      hash &= 0x7fffffff;
    }
    return hash;
  }
}
