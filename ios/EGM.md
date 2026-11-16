# ios Blueprint

## System Overview
The iOS platform host for the `PollutionViz-Frontend` Flutter app. It is generated Flutter
boilerplate (Xcode project, workspace, xcconfig files) plus one native app target, `Runner`,
that launches the Flutter engine and registers plugins. Application logic lives in the Dart
code under `../lib`, not here.

## Subdirectories & System Boundaries
- Runner: [./Runner/EGM.md](./Runner/EGM.md) - app target: `AppDelegate`, plugin registrant,
  `Info.plist`, storyboards, asset catalogs.
- Flutter: no contract file (no source files besides generated artifacts). Holds
  `AppFrameworkInfo.plist` (`MinimumOSVersion` 12.0), `Debug.xcconfig` and `Release.xcconfig`
  (each `#include "Generated.xcconfig"`). `Generated.xcconfig`, `flutter_export_environment.sh`
  and `ephemeral/` are generated and gitignored; `ephemeral/` is intentionally not documented.
- Runner.xcodeproj / Runner.xcworkspace: no contract file. Xcode project definition
  (`project.pbxproj`, shared `Runner` scheme) and workspace metadata.
- RunnerTests: no contract file (test-only). Contains `RunnerTests.swift` with an empty
  `testExample`.

## Global Invariants
- `ios/.gitignore` excludes `Flutter/Generated.xcconfig`, `Flutter/flutter_export_environment.sh`,
  `Flutter/ephemeral/`, `Runner/GeneratedPluginRegistrant.*`, `Pods/` and `.symlinks/`; these are
  produced by the Flutter tool and must not be hand-edited.
- iOS deployment target is 12.0 (`IPHONEOS_DEPLOYMENT_TARGET` in `Runner.xcodeproj/project.pbxproj`,
  `MinimumOSVersion` in `Flutter/AppFrameworkInfo.plist`); keep them in step.

## Global Side Effects
- Builds depend on Flutter-tool-generated files (`Generated.xcconfig`, plugin registrant), which
  are rewritten by `flutter pub get` / `flutter build ios`.
- The app requests location permission (`NSLocationWhenInUseUsageDescription` in `Runner/Info.plist`).

## System Verification
- Run: `flutter analyze` and `flutter build ios` from the Flutter project root
  (`PollutionViz-Frontend`); `flutter build ios` requires macOS with Xcode.
