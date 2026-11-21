import 'dart:async';

import 'package:cadence_tasks/core/application/ports/notification_scheduler.dart';
import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_daily_agenda_repository.dart';
import 'package:cadence_tasks/data/local/drift/drift_one_off_task_repository.dart';
import 'package:cadence_tasks/data/local/drift/drift_routine_repository.dart';
import 'package:cadence_tasks/data/local/drift/drift_sync_repository.dart';
import 'package:cadence_tasks/data/remote/firebase/firebase_authentication_repository.dart';
import 'package:cadence_tasks/data/remote/firebase/firebase_sync_coordinator.dart';
import 'package:cadence_tasks/features/agenda/domain/daily_agenda.dart';
import 'package:cadence_tasks/features/agenda/domain/repositories/daily_agenda_repository.dart';
import 'package:cadence_tasks/features/agenda/domain/use_cases/get_daily_agenda.dart';
import 'package:cadence_tasks/features/agenda/presentation/controllers/agenda_actions_controller.dart';
import 'package:cadence_tasks/features/authentication/domain/auth_user.dart';
import 'package:cadence_tasks/features/authentication/domain/authentication_repository.dart';
import 'package:cadence_tasks/features/routines/domain/repositories/routine_repository.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/synchronization/domain/sync_coordinator.dart';
import 'package:cadence_tasks/features/tasks/domain/repositories/one_off_task_repository.dart';
import 'package:cadence_tasks/infrastructure/firebase/firebase_bootstrap.dart';
import 'package:cadence_tasks/infrastructure/notifications/local_notification_scheduler.dart';
import 'package:cadence_tasks/infrastructure/notifications/reminder_reconciler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseBootstrapStateProvider = Provider<FirebaseBootstrapState>(
  (ref) => const FirebaseOfflineMode(),
);

final authenticationRepositoryProvider = Provider<AuthenticationRepository?>((
  ref,
) {
  final state = ref.watch(firebaseBootstrapStateProvider);
  return switch (state) {
    FirebaseReady(:final config) => FirebaseAuthenticationRepository(
      firebaseAuth: firebase_auth.FirebaseAuth.instance,
      config: config,
    ),
    FirebaseOfflineMode() || FirebaseStartupFailure() => null,
  };
});

final localSyncRepositoryProvider = Provider<DriftSyncRepository>((ref) {
  return DriftSyncRepository(ref.watch(appDatabaseProvider));
});

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final repository = ref.watch(authenticationRepositoryProvider);
  if (repository == null) {
    return Stream<AuthUser?>.value(null);
  }
  return repository.authStateChanges().asyncMap((user) async {
    if (user != null) {
      await ref.read(localSyncRepositoryProvider).claimGuestData(user.id);
    }
    return user;
  });
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final activeUserIdProvider = Provider<String>((ref) {
  return ref
      .watch(authStateProvider)
      .when(
        data: (user) => user?.id ?? DriftSyncRepository.guestUserId,
        loading: () => DriftSyncRepository.guestUserId,
        error: (error, stackTrace) => DriftSyncRepository.guestUserId,
      );
});

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return DriftRoutineRepository(
    ref.watch(appDatabaseProvider),
    userId: ref.watch(activeUserIdProvider),
  );
});

final oneOffTaskRepositoryProvider = Provider<OneOffTaskRepository>((ref) {
  return DriftOneOffTaskRepository(
    ref.watch(appDatabaseProvider),
    userId: ref.watch(activeUserIdProvider),
  );
});

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return LocalNotificationScheduler();
});

final reminderReconcilerProvider = Provider<ReminderReconciler>((ref) {
  return ReminderReconciler(
    routines: ref.watch(routineRepositoryProvider),
    repository: ref.watch(dailyAgendaRepositoryProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
  );
});

final notificationSetupErrorProvider = StateProvider<String?>((ref) => null);

final syncStatusProvider = StateProvider<String?>((ref) => null);

final dailyAgendaRepositoryProvider = Provider<DailyAgendaRepository>((ref) {
  return DriftDailyAgendaRepository(
    routines: ref.watch(routineRepositoryProvider),
    oneOffTasks: ref.watch(oneOffTaskRepositoryProvider),
  );
});

final agendaActionsControllerProvider = Provider<AgendaActionsController>((
  ref,
) {
  return AgendaActionsController(
    routines: ref.watch(routineRepositoryProvider),
    oneOffTasks: ref.watch(oneOffTaskRepositoryProvider),
    notifications: ref.watch(notificationSchedulerProvider),
  );
});

final dailyAgendaProvider = FutureProvider.family<DailyAgenda, LocalDate>((
  ref,
  date,
) async {
  final now = DateTime.now();
  final nowTimeResult = LocalTime.fromMinutesSinceMidnight(
    now.hour * 60 + now.minute,
  );
  final nowTime = switch (nowTimeResult) {
    Success<LocalTime>(:final value) => value,
    FailureResult<LocalTime>(:final failure) => throw StateError(
      failure.message,
    ),
  };
  final result = await GetDailyAgenda(
    repository: ref.watch(dailyAgendaRepositoryProvider),
  ).execute(date: date, nowDate: LocalDate.fromDateTime(now), nowTime: nowTime);

  return switch (result) {
    Success<DailyAgenda>(:final value) => value,
    FailureResult<DailyAgenda>(:final failure) => throw StateError(
      failure.message,
    ),
  };
});

final routinesProvider = FutureProvider<List<RoutineTemplate>>((ref) async {
  final result = await ref.watch(routineRepositoryProvider).getAllRoutines();

  return switch (result) {
    Success<List<RoutineTemplate>>(:final value) => value,
    FailureResult<List<RoutineTemplate>>(:final failure) => throw StateError(
      failure.message,
    ),
  };
});

final syncCoordinatorProvider = Provider<SyncCoordinator?>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  final firebaseState = ref.watch(firebaseBootstrapStateProvider);
  if (user == null || firebaseState is! FirebaseReady) {
    return null;
  }

  return FirebaseSyncCoordinator(
    firestore: FirebaseFirestore.instance,
    database: ref.watch(appDatabaseProvider),
    userId: user.id,
  );
});
