import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/data/local/drift/app_database.dart';
import 'package:cadence_tasks/data/local/drift/drift_sync_repository.dart';
import 'package:cadence_tasks/data/remote/firebase/firebase_sync_coordinator.dart';
import 'package:cadence_tasks/features/synchronization/domain/sync_coordinator.dart';
import 'package:cadence_tasks/infrastructure/firebase/firebase_bootstrap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

const cloudSyncTaskName = 'cadenceCloudSync';
const cloudSyncUniqueName = 'cadence-cloud-sync';

Future<void> scheduleBackgroundCloudSync(
  FirebaseBootstrapState firebaseState,
) async {
  if (kIsWeb ||
      defaultTargetPlatform != TargetPlatform.android ||
      firebaseState is! FirebaseReady) {
    return;
  }

  await Workmanager().initialize(cadenceBackgroundDispatcher);
  await Workmanager().registerPeriodicTask(
    cloudSyncUniqueName,
    cloudSyncTaskName,
    frequency: const Duration(hours: 6),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    backoffPolicy: BackoffPolicy.exponential,
  );
}

@pragma('vm:entry-point')
void cadenceBackgroundDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != cloudSyncTaskName) {
      return true;
    }

    WidgetsFlutterBinding.ensureInitialized();
    final firebaseState = await initializeFirebase();
    if (firebaseState is! FirebaseReady) {
      return true;
    }

    final user = await firebase_auth.FirebaseAuth.instance
        .authStateChanges()
        .first;
    if (user == null) {
      return true;
    }

    final database = AppDatabase();
    try {
      final localSyncRepository = DriftSyncRepository(database);
      await localSyncRepository.claimGuestData(user.uid);
      final result = await FirebaseSyncCoordinator(
        firestore: FirebaseFirestore.instance,
        database: database,
        userId: user.uid,
      ).synchronize();
      return result is Success<SyncSummary>;
    } finally {
      await database.close();
    }
  });
}
