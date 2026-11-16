# PollutionViz-Frontend Blueprint

## System Overview

Flutter client (package `ver2_app`, `pubspec.yaml`) for PollutionViz. The Dart application lives in `lib/` and talks to the deployed backend over REST. The `android`, `ios`, `macos`, `linux` and `windows` directories are generated Flutter platform hosts with no application logic. `pollution_new` is a separate, unused platform-folder scaffold with no `lib/` or `pubspec.yaml` of its own.

## Subdirectories & System Boundaries

- lib: [./lib/EGM.md](./lib/EGM.md) - All application code: four-tab shell, location resolution, API helpers, pages, chatbot.
- android: [./android/EGM.md](./android/EGM.md) - Generated Android host (Gradle Kotlin DSL, `MainActivity`, manifest permissions).
- ios: [./ios/EGM.md](./ios/EGM.md) - Generated iOS host (`AppDelegate`, `Info.plist`).
- macos: [./macos/EGM.md](./macos/EGM.md) - Generated macOS host (sandboxed Cocoa app).
- linux: [./linux/EGM.md](./linux/EGM.md) - Generated GTK3 host and CMake glue.
- windows: [./windows/EGM.md](./windows/EGM.md) - Generated Win32 host and CMake glue.
- pollution_new: [./pollution_new/EGM.md](./pollution_new/EGM.md) - Unused scaffold of generated platform files.
- assets, web, test, pollution-frontend (a stray 0-byte file): not documented. `assets` holds the five images declared in `pubspec.yaml` plus an undeclared `models/PM 2.5.glb`; `web` and `test` contain no contract-bearing source (`test/widget_test.dart` is the default Flutter counter smoke test).

## Global Invariants

- All backend traffic goes through the helpers in `lib/backend_url.dart` to the single `baseURL` constant; helpers take required `lat`/`lon` and have no default coordinates.
- The user location is resolved once in `MainNavigation` (`lib/main.dart`) via `LocationService` and passed down; the Nagpur coordinates exist only as the last-resort fallback in `lib/location_service.dart`.
- Files named `GeneratedPluginRegistrant.*`, `generated_plugin_registrant.*` and `generated_plugins.cmake` under the platform directories are tool-generated and must not be hand-edited.
- The platform directories do not contain application logic; behavior changes belong in `lib/`.

## Global Side Effects

- HTTPS requests to the PollutionViz backend (`baseURL` in `lib/backend_url.dart`).
- Location permission prompts and GPS access (`geolocator`); Android manifest and iOS `Info.plist` declare the location permissions.
- Persists `manual_lat`, `manual_lon` and `manual_label` with `shared_preferences`.
- Runtime font fetch via `google_fonts`; an embedded WebView via `webview_flutter`.

## System Verification

- Run: `flutter pub get && flutter analyze` from this directory.
- `flutter test` runs only `test/widget_test.dart`, the default counter test; it has not been verified to pass against this app.
