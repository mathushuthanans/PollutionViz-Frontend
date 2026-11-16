# pollution_new Blueprint

## System Overview
`pollution_new` is an unused Flutter platform-folder scaffold. It has the platform directories `android/`, `ios/`, `linux/`, `macos/`, and `windows/`, but no `lib/`, `pubspec.yaml`, `test/`, or hand-written application code. Every source file in it is Flutter-tool generated (headed "Generated file. Do not edit."). The app is the parent directory `../` (`pubspec.yaml` name `ver2_app`, with its own `lib/`). No file outside this folder references the name `pollution_new` (text search of the parent, excluding build output).

Generated config records a different machine: `android/local.properties` and `ios/Flutter/Generated.xcconfig` point to `/home/mathushuthanans/...`, and the xcconfig sets `FLUTTER_TARGET=lib/main.dart`, a file that does not exist here.

## Subdirectories & System Boundaries
- android: [./android/EGM.md](./android/EGM.md) - Gradle wrapper files plus generated `GeneratedPluginRegistrant.java`.
- ios: [./ios/EGM.md](./ios/EGM.md) - Generated Objective-C plugin registrant and LLDB helper.
- linux, macos, windows: not documented (no source files). They contain only generated `ephemeral/` artifacts (`path_provider_linux` and `path_provider_windows` marker files, macOS `Flutter-Generated.xcconfig` and `flutter_export_environment.sh`).

## Global Invariants
- All code here is generated from the plugin set `path_provider` and `webview_flutter` (Android and iOS registrants); regenerate with the Flutter tool instead of editing.
- No Dart code exists in this directory.

## Global Side Effects
- None at runtime: the folder has no build manifest of its own, so nothing here is built by itself.

## System Verification
- None: no `pubspec.yaml` or tests exist here. For the real app, run `flutter test` from the parent directory.
