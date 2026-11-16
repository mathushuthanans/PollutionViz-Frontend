# flutter (Linux managed build)

## Overview
Flutter-tool-managed CMake glue for the Linux build. It is generated platform boilerplate, and the files carry "do not edit" headers. It builds the Flutter library target, runs the Flutter tool backend, and registers plugins. `ephemeral/` is gitignored (see `../.gitignore`) and is not documented here. The Flutter tool regenerates it, and `CMakeLists.txt` includes `ephemeral/generated_config.cmake` from it.

## Interface
- `CMakeLists.txt` defines:
  - the `flutter` INTERFACE library, which links `libflutter_linux_gtk.so`, GTK, GLib and GIO;
  - the `flutter_assemble` custom target, which runs `${FLUTTER_ROOT}/packages/flutter_tools/bin/tool_backend.sh`;
  - the helper function `list_prepend`.
- `CMakeLists.txt` publishes `FLUTTER_LIBRARY`, `FLUTTER_ICU_DATA_FILE`, `PROJECT_BUILD_DIR` and `AOT_LIBRARY` to the parent scope for the install step.
- `generated_plugin_registrant.h:fl_register_plugins(FlPluginRegistry*)` is called from [`../runner`](../runner/EGM.md). Its body in `generated_plugin_registrant.cc` is currently empty, because no native Linux plugins are registered.
- `generated_plugins.cmake` has an empty `FLUTTER_PLUGIN_LIST` and `FLUTTER_FFI_PLUGIN_LIST` set to `jni`. It adds each FFI plugin's `linux` subdirectory from `ephemeral/.plugin_symlinks/` and collects `PLUGIN_BUNDLED_LIBRARIES`.

## Invariants
- `generated_plugin_registrant.*` and `generated_plugins.cmake` are generated ("Generated file. Do not edit"). Regenerate them with `flutter pub get` or a build, not by hand.
- `flutter_assemble` uses a `_phony_` output so the Flutter tool runs on every build.
- `FLUTTER_LIBRARY_HEADERS` is an explicit list of the `flutter_linux/*.h` headers expected in `ephemeral/`.
- `CMakeLists.txt` requires GTK 3.0, GLib 2.0 and GIO 2.0 through `pkg_check_modules`.

## Side Effects
- Building runs `tool_backend.sh`, which compiles the Dart app (AOT outside Debug) and produces the Flutter library and headers under `ephemeral/` and `build/`.
- Plugin directories are added to the build with `add_subdirectory`, and their libraries are bundled at install.

## Verification
- Run from `PollutionViz-Frontend/`: `flutter build linux`.
