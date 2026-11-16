# Runner (iOS GeneratedPluginRegistrant)

## Overview
Contains the Flutter-tool-generated iOS plugin registrant (Objective-C). Both files are headed "Generated file. Do not edit." There is no `AppDelegate`, `Info.plist`, or Xcode project in this directory.

## Interface
- `GeneratedPluginRegistrant.h`: `@interface GeneratedPluginRegistrant : NSObject` with `+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry;`.
- `GeneratedPluginRegistrant.m`: implements `registerWithRegistry:`, registering `PathProviderPlugin` (`path_provider_foundation`) and `WebViewFlutterPlugin` (`webview_flutter_wkwebview`) through `[registry registrarForPlugin:...]`.

## Invariants
- Plugin imports use `__has_include(<pkg/Plugin.h>)` with an `@import pkg;` fallback.
- The file set is generated from the app's plugin dependencies; regenerate with the Flutter tool rather than editing.

## Side Effects
- Registers plugin registrars on the supplied `FlutterPluginRegistry`.

## Verification
- Run: `flutter build ios` (from a Flutter app root that contains a `pubspec.yaml`; this scaffold has none).
