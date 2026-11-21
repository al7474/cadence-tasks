import 'package:cadence_tasks/infrastructure/firebase/firebase_runtime_config.dart';
import 'package:firebase_core/firebase_core.dart';

sealed class FirebaseBootstrapState {
  const FirebaseBootstrapState();
}

final class FirebaseOfflineMode extends FirebaseBootstrapState {
  const FirebaseOfflineMode();
}

final class FirebaseReady extends FirebaseBootstrapState {
  const FirebaseReady(this.config);

  final FirebaseRuntimeConfig config;
}

final class FirebaseStartupFailure extends FirebaseBootstrapState {
  const FirebaseStartupFailure(this.message);

  final String message;
}

Future<FirebaseBootstrapState> initializeFirebase({
  FirebaseRuntimeConfig config = FirebaseRuntimeConfig.fromEnvironment,
}) async {
  if (!config.isConfiguredForCurrentPlatform) {
    return const FirebaseOfflineMode();
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: config.currentPlatformOptions);
    }
    return FirebaseReady(config);
  } on FirebaseException catch (error) {
    return FirebaseStartupFailure(
      error.message ?? 'Firebase initialization failed (${error.code}).',
    );
  }
}
