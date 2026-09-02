# Billi Billi — Build Ready

This package contains the prepared Billi Billi Flutter application source and the GitHub Actions Android build workflow.

## Included
- `lib/main.dart` — prepared Billi Billi application source
- `pubspec.yaml` — required Flutter dependencies
- `.github/workflows/build-apk.yml` — Android APK build workflow
- `assets/billi_billi_logo.png` — Billi Billi logo asset

## Important
The GitHub workflow intentionally generates the Android platform project with Flutter before building. Therefore the repository does not need a checked-in `android/` directory for the supplied CI build workflow.

## Build
Upload the contents of this package to the repository root, then run the workflow from GitHub Actions.
