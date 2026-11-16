# runner

## Overview
Native GTK3 host for the Flutter Linux embedder. This is standard generated Flutter platform boilerplate. It creates a `GtkApplication`, opens a 1280x720 window, and embeds an `FlView` that runs the Dart app. The binary name is `ver2_app` and the application ID is `com.example.ver2_app`, both set in [`../CMakeLists.txt`](../CMakeLists.txt).

## Interface
- `main.cc:main` creates the app with `my_application_new()` and runs it with `g_application_run`.
- `my_application.h:MyApplication` is a final GObject type declared with `G_DECLARE_FINAL_TYPE` and derived from `GtkApplication`.
- `my_application.h:my_application_new()` returns a new `MyApplication`.
- `my_application.cc` overrides these `GApplication` virtual methods:
  - `activate` builds the window, header bar or title bar, `FlDartProject` and `FlView`.
  - `local_command_line` stores the argv tail as the Dart entrypoint arguments.
  - `startup` and `shutdown` only chain up to the parent class.
- `CMakeLists.txt` defines the executable target `${BINARY_NAME}` from `main.cc`, `my_application.cc` and `../flutter/generated_plugin_registrant.cc`.

## Invariants
- `my_application.cc:my_application_activate` uses a GTK header bar by default. On X11 with a window manager other than "GNOME Shell", it uses a plain title bar.
- The window title is the literal `"ver2_app"` in two places in `my_application.cc`. It does not follow `BINARY_NAME` automatically.
- `my_application.cc:my_application_activate` calls `fl_register_plugins` on the `FlView` after the view is created.
- `my_application_new` sets the program name to `APPLICATION_ID` and uses the `G_APPLICATION_NON_UNIQUE` flag, so multiple instances can run.
- `my_application_dispose` frees `dart_entrypoint_arguments` with `g_strfreev`.
- `CMakeLists.txt` says the target name must be changed through `BINARY_NAME` in the top-level `CMakeLists.txt`, not here. Otherwise `flutter run` stops working.
- `apply_standard_settings` (defined in the parent `CMakeLists.txt`) enables `-Wall -Werror`, so compiler warnings fail the build.
- New C++ source files must be added to the `add_executable` list in `CMakeLists.txt`.

## Side Effects
- Opens a GTK window on the display server.
- `my_application_local_command_line` calls `g_application_register` and logs a `g_warning` if registration fails. It then sets exit status 1.
- Starts the Flutter engine and Dart isolate through `fl_view_new`.
- Defines the compile-time macro `APPLICATION_ID` through `add_definitions`.

## Verification
- Run from `PollutionViz-Frontend/`: `flutter build linux` and `flutter analyze`. The latter only checks Dart code, not this directory.
