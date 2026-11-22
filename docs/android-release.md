# Android Release Procedure

The Android release workflow publishes only the ARM64 APK after a new
`vMAJOR.MINOR.PATCH` tag is pushed. It verifies the tag against `pubspec.yaml`,
requires an increasing Android build number, runs analysis and tests, and
creates a GitHub Release. It does not publish on ordinary branch pushes. The
build may produce local APK variants for other ABIs, but they are not attached
to the release.

## One-time setup

1. Generate a dedicated upload keystore on a trusted computer. Run `keytool`
   without password command-line options so it prompts for passwords:

   ```powershell
   $keystore = "$env:USERPROFILE\.android\cadence-tasks-upload.jks"
   keytool -genkeypair -v -keystore $keystore -alias cadence-tasks-upload `
     -keyalg RSA -keysize 2048 -validity 10000
   ```

   Keep a secure backup of the keystore and its passwords. Losing this key
   prevents publishing updates signed as the same Android app. Never commit the
   keystore or its passwords.

2. Read the keystore certificate's SHA-1:

   ```powershell
   keytool -list -v -keystore $keystore -alias cadence-tasks-upload
   ```

   Add that SHA-1 fingerprint to the `com.al7474.cadence_tasks` Android app in
   Firebase. Add the same fingerprint without colons as the
   `ANDROID_RELEASE_SHA1` GitHub Actions secret. Keep the existing debug
   fingerprint for emulator builds.

3. In the GitHub repository, open **Settings > Secrets and variables >
   Actions** and add these repository secrets:

   - `ANDROID_KEYSTORE_BASE64`: Base64-encoded keystore file.
   - `ANDROID_KEYSTORE_PASSWORD`: Keystore password.
   - `ANDROID_KEY_ALIAS`: `cadence-tasks-upload`.
   - `ANDROID_KEY_PASSWORD`: Key password.
   - `ANDROID_RELEASE_SHA1`: Release certificate SHA-1 without colons.
   - `FIREBASE_API_KEY`
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_MESSAGING_SENDER_ID`
   - `FIREBASE_ANDROID_APP_ID`
   - `FIREBASE_WEB_APP_ID`
   - `FIREBASE_AUTH_DOMAIN`
   - `FIREBASE_STORAGE_BUCKET`
   - `GOOGLE_SERVER_CLIENT_ID`

   The Firebase values are the client configuration used by the app. Copy them
   from the local `.env` file; do not paste them into issues or commit `.env`.

To copy the keystore as Base64 to the local clipboard without printing it:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes($keystore)) | Set-Clipboard
```

## Publishing a version

1. Choose the next user-facing version and increase the Android build number in
   `pubspec.yaml`, for example `1.0.0+1`.
2. Commit and push that change to `main`.
3. Create and push a matching tag:

   ```powershell
   git tag v1.0.0
   git push origin v1.0.0
   ```

GitHub Actions runs checks and creates a release containing
`cadence-tasks-1.0.0-android-arm64.apk`. If the tag, app version, build number,
or required secrets are invalid, no APK is published.
