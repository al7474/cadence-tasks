import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

final class FirebaseRuntimeConfig {
  const FirebaseRuntimeConfig({
    required this.apiKey,
    required this.projectId,
    required this.messagingSenderId,
    required this.androidAppId,
    required this.webAppId,
    required this.authDomain,
    required this.storageBucket,
    required this.googleServerClientId,
  });

  static const fromEnvironment = FirebaseRuntimeConfig(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    androidAppId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    webAppId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    googleServerClientId: String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
  );

  final String apiKey;
  final String projectId;
  final String messagingSenderId;
  final String androidAppId;
  final String webAppId;
  final String authDomain;
  final String storageBucket;
  final String googleServerClientId;

  bool get isConfiguredForCurrentPlatform {
    final platformAppId = kIsWeb ? webAppId : androidAppId;
    return apiKey.isNotEmpty &&
        projectId.isNotEmpty &&
        messagingSenderId.isNotEmpty &&
        platformAppId.isNotEmpty &&
        (!kIsWeb || authDomain.isNotEmpty);
  }

  FirebaseOptions get currentPlatformOptions {
    if (!isConfiguredForCurrentPlatform) {
      throw StateError('Firebase is not configured for this platform.');
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: kIsWeb ? webAppId : androidAppId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: kIsWeb ? authDomain : null,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
    );
  }
}
