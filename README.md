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

The Firestore rules test suite uses the Firebase Emulator:

```shell
npm ci --prefix tool/firestore-rules-tests
npm test --prefix tool/firestore-rules-tests
```

Android and Web platform runners are included. Run `flutter devices` to list
available targets, then `flutter run -d <device-id>` to launch the app. For a
Web preview, use `flutter run -d web-server` and open the printed URL in a
browser.

## Features

- Today agenda combines recurring routine occurrences and one-off tasks, with
  complete, skip, snooze, reschedule, and delete actions where applicable.
- Calendar provides a Monday-to-Sunday schedule with configurable visible
  hours, defaulting to 6:00 AM through 10:00 PM. Change the range in Settings;
  it is saved to the signed-in account and syncs across that account's devices.
  On phones, select a day to see its schedule; on wider screens, view the full
  week. Add a task or recurring routine from a date or time slot to prefill it.
- Routines support daily, selected-weekday, and custom-interval recurrence.
- Drift is the local source of truth on Android and Web, so agenda reads and
  writes work without a network connection.
- Android reminders use local notifications with Complete, Snooze, and Skip
  actions. Notification and exact-alarm permissions must be granted on-device.
- Google sign-in and Firestore synchronization are optional. Without Firebase
  client configuration, the app clearly runs in local-only mode.

## Synchronization and scheduling

Local mutations are queued for synchronization and use soft deletes. When
Firebase is configured, local changes trigger a debounced upload and open,
connected clients listen for remote changes. Synchronization also runs on
sign-in and app resume; Android requests a best-effort WorkManager sync every
six hours when network access is available. Web listeners run while the app is
open. Offline changes remain queued until connectivity returns or the app
resumes. Neither Web nor Android can guarantee immediate synchronization while
the app is closed or suspended, and Android background execution can be
deferred by the OS.

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
4. Deploy the user-scoped rules and indexes with
   `firebase deploy --only firestore`.
5. Run with `flutter run --dart-define-from-file=.env`.

The options in `.env` are public client configuration, not service-account
secrets. Never add private keys or service-account credentials to the Flutter
application. Firestore Security Rules restrict task documents and calendar
display preferences to the authenticated user's UID. Signed-in users can
permanently delete their Cadence Tasks account and synced records from Settings.

## Vercel Web deployment

The Web companion is a static Flutter build hosted on Vercel; Firebase
Authentication and Firestore remain the backend. The root `vercel.json` selects
the Flutter build script and publishes only `build/web`.

1. Import `al7474/pulse-routines` into Vercel and keep the repository root as
   the Root Directory. Vercel detects the custom `vercel.json` build command.
2. In **Project Settings > Environment Variables**, add the Firebase Web values
   from the local `.env` file:
   `FIREBASE_API_KEY`, `FIREBASE_PROJECT_ID`,
   `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_WEB_APP_ID`, and
   `FIREBASE_AUTH_DOMAIN`. `FIREBASE_STORAGE_BUCKET` is optional. The Android
   app ID and Google server client ID are not required by the Web sign-in flow.
3. Assign the values to the Production and Preview environments. Flutter reads
   them at build time; `tool/vercel/build_web.sh` writes a temporary Dart-define
   JSON file and removes it when the build ends.
4. Deploy the project. Each push to the production branch creates a production
   deployment; pull requests can create preview deployments.
5. Add the production `*.vercel.app` hostname, or your custom hostname, to
   **Firebase Console > Authentication > Settings > Authorized domains**.
   The existing Firebase `authDomain` remains
   `cadence-tasks-f2639.firebaseapp.com`.

The Firebase Web configuration is public client configuration and will be
embedded in the generated JavaScript. Never add a service-account key,
keystore, or private credentials to Vercel environment variables for this Web
build. Exact local notifications are available only in the Android app.

## Android releases

The permanent Android application ID is `com.al7474.cadence_tasks`. Do not
change it after distributing a release; Android treats a different ID as a
separate app.

GitHub Actions runs checks on pushes and pull requests to `main`. An Android
release is created only when a new `vMAJOR.MINOR.PATCH` tag is pushed. Before
tagging a release:

1. Manually update `version` in `pubspec.yaml`, for example `1.0.0+1`.
   The semantic version must match the tag, and the build number after `+` must
   increase for every Android release.
2. Push the version change to `main`.
3. Create and push the matching tag, for example `git tag v1.0.0` followed by
   `git push origin v1.0.0`.

The release workflow verifies the tag, version, and build number; runs
`flutter analyze` and `flutter test`; builds only the ARM64 APK; and creates a
GitHub Release containing only the ARM64 APK. It will not replace an existing
release.

Follow [the Android release procedure](./docs/android-release.md) once to create
and back up the signing key and configure GitHub Actions secrets. The release
workflow intentionally produces no publishable APK until all signing and
Firebase values are configured.
