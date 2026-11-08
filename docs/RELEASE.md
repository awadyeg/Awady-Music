# Building and publishing Awady Music

Application id: `com.awady.awady_music`. Version name and version code come from `pubspec.yaml` (`version: x.y.z+code`) and must match `UpdateChecker.currentVersion` / `UpdateChecker.currentBuild`.

## Local release build

```bash
flutter pub get
flutter gen-l10n
flutter test
flutter build apk --release --split-per-abi
```

Outputs:

- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-release.apk`

Modern phones use the arm64 APK. The in-app updater looks for an asset whose name contains `arm64` and ends in `.apk`.

## Signing

`android/key.properties` and `*.jks` / `*.keystore` are gitignored. Do not commit them.

If `android/key.properties` exists, `android/app/build.gradle.kts` signs release builds with that upload key. If it does not exist, Gradle falls back to the **debug** keystore. That debug certificate is created per machine (and per GitHub-hosted runner). It is not an upload key.

An APK can replace an installed copy only when `apksigner verify --print-certs` shows the same certificate. A debug-signed APK must be labeled as a test build. Installing it over a copy signed with a different key fails until the old app is uninstalled, which deletes local playlists and downloads.

To keep upgrade continuity, create one upload keystore once and reuse it:

```bash
keytool -genkeypair -v \
  -keystore upload-keystore.jks \
  -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

`android/key.properties` (paths are relative to `android/app/`):

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=upload-keystore.jks
```

Place `upload-keystore.jks` in `android/app/` or use an absolute `storeFile` path. Never put the passwords or the keystore in git.

CI can use the same identity when these repository secrets are set:

- `ANDROID_KEYSTORE_BASE64` (base64 of the keystore file)
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_STORE_PASSWORD`

The workflow writes them into `android/key.properties` only inside the job. It does not print them. Tag-triggered GitHub Releases from CI stay off unless the repository variable `PUBLISH_RELEASE_FROM_CI` is `true`, so an ephemeral debug signature cannot overwrite a published APK.

## Publishing a GitHub Release

Releases belong on this repository. From the commit that should be installed:

```bash
gh release create vX.Y.Z \
  --target <commit-sha> \
  --title "Awady Music vX.Y.Z" \
  --notes-file notes.md \
  build/app/outputs/flutter-apk/*-release.apk
```

If the commit is not on `main`, mark the release `--prerelease` and name the commit in the notes. A prerelease is not returned by GitHub's `/releases/latest`, so the in-app updater will not offer it. Use a stable release only when the APK certificate matches the certificate of the build users already have.
