# Cadence Tasks

Cadence Tasks is an Android-first daily routine and task manager with a Web
companion. Its architecture is designed around local-first reads and writes,
with optional account-scoped cloud synchronization when Firebase is configured.

## Requirements

- Flutter 3.38.1 or newer
- Dart 3.10 or newer

## Getting started

```shell
flutter pub get
flutter analyze
flutter test
```

After adding or changing Drift tables, generate their source with:

```shell
dart run build_runner build
```

Android and Web platform runners are included. Run `flutter devices` to list
available targets, then `flutter run -d <device-id>` to launch the app. For a
Web preview, use `flutter run -d web-server` and open the printed URL in a
browser.

## MVP features

- Today agenda combines recurring routine occurrences and one-off tasks, with
  complete, skip, snooze, reschedule, and delete actions where applicable.
- Routines support daily, selected-weekday, and custom-interval recurrence.
- Drift is the local source of truth on Android and Web, so agenda reads and
  writes work without a network connection.
- Android reminders use local notifications with Complete, Snooze, and Skip
  actions. Notification and exact-alarm permissions must be granted on-device.
- Google sign-in and Firestore synchronization are optional. Without Firebase
  client configuration, the app clearly runs in local-only mode.

## Synchronization and scheduling

Local mutations are queued for synchronization and use soft deletes. When
Firebase is configured, synchronization runs on sign-in and app resume; Android
also requests a best-effort WorkManager sync every six hours when network access
is available. Web synchronization runs while the app is open. WorkManager is not
an exact-time scheduler, and background execution can be deferred by the OS.

Android notification alarms are scheduled locally and are independent of cloud
sync. The app reconciles pending reminders on startup and resume and handles
device reboot. Web does not schedule local notifications.

## Architecture

- `lib/core/domain/` contains framework-independent result types and value objects.
- `lib/features/` contains feature domain, data, and presentation layers.
- `lib/data/local/drift/` contains the offline-first database, repositories, and
  sync outbox.
- `lib/data/remote/firebase/` contains Firebase Authentication and Firestore
  adapters.
- `lib/infrastructure/notifications/` contains Android local notification
  scheduling.

Domain code does not import Flutter, Firebase, or persistence packages. Riverpod
is used for typed dependency injection and presentation state.

## Firebase setup

The app runs offline without Firebase configuration. To enable account sync:

1. Create a Firebase project on the Spark plan, enable Google Authentication,
   and create a Cloud Firestore database.
2. Copy `.env.example` to `.env` and fill in the Firebase client options and
   Google server client ID from your Firebase and Google Cloud consoles.
3. Add the Android app's SHA-1 fingerprint to the Firebase Android app and add
   `localhost` to the authorized domains for the Web app.
4. Deploy the user-scoped rules with `firebase deploy --only firestore:rules`.
5. Run with `flutter run --dart-define-from-file=.env`.

The options in `.env` are public client configuration, not service-account
secrets. Never add private keys or service-account credentials to the Flutter
application. Firestore Security Rules restrict all task documents to the
authenticated user's UID.
