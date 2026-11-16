# macOS Platform Blueprint

## System Overview
Generated Flutter platform boilerplate for building the frontend as a macOS desktop app. The Xcode project builds a thin Cocoa host (`Runner`) that embeds the Flutter engine; the Dart application code is outside this directory.

## Subdirectories & System Boundaries
- Runner: [./Runner/EGM.md](./Runner/EGM.md) - `AppDelegate`, `MainFlutterWindow`, `Info.plist`, entitlements, and build-setting xcconfigs.
- Flutter: [./Flutter/EGM.md](./Flutter/EGM.md) - Flutter-managed xcconfigs and the generated plugin registrant (geolocator, shared_preferences, webview_flutter).
- Runner.xcodeproj, Runner.xcworkspace - Xcode project and workspace files (no source code, no contract file).
- RunnerTests - XCTest stub (`RunnerTests.swift`); test-only, not documented.
- `Flutter/ephemeral/` - gitignored, intentionally skipped.

## Global Invariants
- `Flutter/GeneratedPluginRegistrant.swift` is tool-generated and must not be hand-edited.
- The app is sandboxed (`com.apple.security.app-sandbox`) in debug/profile and release.

## Global Side Effects
- Building produces a macOS `.app` bundle; at runtime it loads native plugins for location, shared preferences, and WebView.

## System Verification
- Run: `flutter build macos` and `flutter analyze` from the Flutter project root, `PollutionViz-Frontend/`.
