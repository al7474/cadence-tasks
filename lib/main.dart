import 'package:cadence_tasks/app/cadence_app.dart';
import 'package:cadence_tasks/app/providers.dart';
import 'package:cadence_tasks/infrastructure/background/background_sync_worker.dart';
import 'package:cadence_tasks/infrastructure/firebase/firebase_bootstrap.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseState = await initializeFirebase();
  await scheduleBackgroundCloudSync(firebaseState);

  runApp(
    ProviderScope(
      overrides: [
        firebaseBootstrapStateProvider.overrideWithValue(firebaseState),
      ],
      child: const CadenceApp(),
    ),
  );
}
