# Cadence Tasks

Cadence Tasks is an Android-first daily routine and task manager with a Web
companion. Its architecture is designed around local-first reads and writes,
with account-scoped cloud synchronization added in a later phase.

## Requirements

- Flutter 3.27 or newer
- Dart 3.6 or newer

## Getting started

```shell
flutter pub get
flutter analyze
flutter test
```

After adding annotated Riverpod providers, generate their source with:

```shell
dart run build_runner build --delete-conflicting-outputs
```

Android and Web platform runners are included. Run `flutter devices` to list
available targets, then `flutter run -d <device-id>` to launch the app. For a
Web preview, use `flutter run -d web-server` and open the printed URL in a
browser.

## Architecture

- `lib/core/domain/` contains framework-independent result types and value objects.
- `lib/features/` contains feature domain, data, and presentation layers.
- `lib/data/` will contain shared Drift, Firestore, and synchronization adapters.
- `lib/infrastructure/` will contain platform integrations such as notifications.

Domain code does not import Flutter, Firebase, or persistence packages. Riverpod
is used for typed dependency injection and presentation state.

## Firebase setup

Firebase integration is introduced in a later phase. Generate platform client
configuration with `flutterfire configure`; do not add service-account
credentials to the Flutter application. Firebase client configuration is not a
server secret and must be protected by Authentication and Firestore Security
Rules. The `.env.example` file documents that no runtime secrets are required
for the current scaffold.
