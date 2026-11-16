# Android Host Project Blueprint

## System Overview
Generated Flutter Android platform project (Gradle, Kotlin DSL) for the app `ver2_app`. It wraps the Dart app in a native `FlutterActivity` and holds the Gradle, manifest and resource configuration needed to build the APK. This is platform boilerplate; there is no application logic here.

## Local Interface & Invariants
- `settings.gradle.kts`: reads `flutter.sdk` from `local.properties` (fails with "flutter.sdk not set in local.properties" if absent), includes the Flutter Gradle tooling, declares plugins `com.android.application` 8.11.1 and `org.jetbrains.kotlin.android` 2.2.20, and includes module `:app`.
- `build.gradle.kts`: configures `google()` and `mavenCentral()` repositories, redirects build output to `../../build` (the Flutter project's `build/`), and registers a `clean` task.
- `gradle.properties`: JVM args `-Xmx8G`, `android.useAndroidX=true`, `android.enableJetifier=true`, `android.builtInKotlin=false`, `android.newDsl=false`.
- `gradle/wrapper/gradle-wrapper.properties`: Gradle distribution `gradle-8.14.5-all.zip`.
- `app/build.gradle.kts`: namespace and `applicationId` `com.example.ver2_app`; Java/Kotlin target 11; SDK versions and version code/name come from the `flutter` extension; `flutter { source = "../.." }`. The release build type is signed with the debug signing config (marked TODO in the file).
- `app/src/main/AndroidManifest.xml`: declares permissions `INTERNET`, `CAMERA`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`. Declares features `android.hardware.camera`, `camera.ar`, `camera.autofocus` and `glEsVersion 0x00020000` (required). `com.google.ar.core` is marked `optional`. The launcher activity is `.MainActivity` with `flutterEmbedding` = 2.
- `app/src/debug/AndroidManifest.xml` and `app/src/profile/AndroidManifest.xml`: each adds only `INTERNET` (used by the Flutter tool for hot reload and debugging).
- `app/src/main/res/`: launcher icons (`mipmap-*/ic_launcher.png`), `launch_background.xml` (`drawable`, `drawable-v21`) and `LaunchTheme`/`NormalTheme` styles (`values`, `values-night`).
- Gitignored and not documented: `local.properties`, `gradlew`, `gradlew.bat`, `.gradle/`, `captures/`, `GeneratedPluginRegistrant.java`, keystores and `key.properties`.

Invariants:
- `local.properties` must define `flutter.sdk`; it is machine-local and gitignored.
- The package name `com.example.ver2_app` must stay consistent across `app/build.gradle.kts`, the manifest and `MainActivity.kt`.
- `dev.flutter.flutter-gradle-plugin` must be applied after the Android and Kotlin plugins in `app/build.gradle.kts`.

## Subdirectories & System Boundaries
- `app/src/main/kotlin/com/example/ver2_app`: [./app/src/main/kotlin/com/example/ver2_app/EGM.md](./app/src/main/kotlin/com/example/ver2_app/EGM.md) - `MainActivity`, an empty `FlutterActivity` subclass, the only hand-visible native source file.
- `app/`, `app/src/{debug,profile,main}`, `gradle/wrapper`: configuration and resources only (no source code), described above and without separate contracts.
- `build/`: Gradle build output, skipped.

## Global Invariants
- Build output is redirected to the Flutter project's top-level `build/` directory, not `android/build`, by `build.gradle.kts`.
- The app source root is `../..`, the Flutter project root (`flutter { source = "../.." }`).

## Global Side Effects
- Manifest requests runtime-sensitive permissions (camera, coarse/fine location) and network access.
- Builds download Gradle 8.14.5 and Android/Kotlin plugins from `google()`, `mavenCentral()` and the Gradle plugin portal.

## System Verification
- Run: `flutter analyze` and `flutter build apk` from the Flutter project root (`PollutionViz-Frontend`).
