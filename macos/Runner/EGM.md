# Runner (macOS)

## Overview
Native macOS host application for the Flutter frontend. It is standard `flutter create` boilerplate: a Cocoa app that embeds a `FlutterViewController` in its main window and registers the generated plugins. It contains no application logic; all UI lives in the Dart code under `lib/`.

## Interface
- `AppDelegate.swift:AppDelegate` - `@main` class extending `FlutterAppDelegate`. Overrides `applicationShouldTerminateAfterLastWindowClosed` (returns `true`) and `applicationSupportsSecureRestorableState` (returns `true`).
- `MainFlutterWindow.swift:MainFlutterWindow` - `NSWindow` subclass. In `awakeFromNib` it creates a `FlutterViewController`, sets it as `contentViewController`, restores the original window frame, and calls `RegisterGeneratedPlugins(registry:)`.
- `Info.plist` - bundle metadata; values come from build settings (`$(PRODUCT_NAME)`, `$(PRODUCT_BUNDLE_IDENTIFIER)`, `$(FLUTTER_BUILD_NAME)`, `$(FLUTTER_BUILD_NUMBER)`, `$(MACOSX_DEPLOYMENT_TARGET)`); `NSMainNibFile` is `MainMenu`.
- `Base.lproj/MainMenu.xib` - main menu and window nib.
- `Assets.xcassets/AppIcon.appiconset` - app icon assets.
- `Configs/AppInfo.xcconfig` - `PRODUCT_NAME = ver2_app`, `PRODUCT_BUNDLE_IDENTIFIER = com.example.ver2App`, `PRODUCT_COPYRIGHT`.
- `Configs/Debug.xcconfig` and `Configs/Release.xcconfig` - include `../../Flutter/Flutter-Debug.xcconfig` or `Flutter-Release.xcconfig`, plus `Warnings.xcconfig`.
- `Configs/Warnings.xcconfig` - compiler warning flags (`WARNING_CFLAGS`, `CLANG_WARN_*`, `GCC_WARN_*`).
- `DebugProfile.entitlements` - `com.apple.security.app-sandbox`, `com.apple.security.cs.allow-jit`, `com.apple.security.network.server`.
- `Release.entitlements` - `com.apple.security.app-sandbox` only.

## Invariants
- `MainFlutterWindow.awakeFromNib` must call `RegisterGeneratedPlugins` on the `FlutterViewController` before `super.awakeFromNib()`; otherwise plugins are not registered.
- The app quits when its last window closes (`AppDelegate.swift:applicationShouldTerminateAfterLastWindowClosed`).
- The app is sandboxed in both configurations. Neither entitlements file grants `com.apple.security.network.client`, so outbound network access from the sandboxed app is not entitled by these files. Only `DebugProfile.entitlements` grants `network.server` (and JIT, used by Flutter debug/profile builds).
- `PRODUCT_BUNDLE_IDENTIFIER` is still the template placeholder `com.example.ver2App`.

## Side Effects
- Creates the native macOS window and the Flutter engine view at launch.
- Registers native plugin handlers for the Flutter app via `RegisterGeneratedPlugins`.
- No direct disk, network, or database access in the Swift sources.

## Verification
- Run: `flutter build macos` (or `flutter analyze` for Dart code) from the Flutter project root, `PollutionViz-Frontend/`.
