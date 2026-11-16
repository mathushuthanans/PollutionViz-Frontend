# runner

## Overview
Generated Flutter Windows desktop host (target `ver2_app`, see `BINARY_NAME` in `../CMakeLists.txt`). It creates a Win32 top-level window, embeds a `flutter::FlutterViewController` in it, registers plugins, and runs the Win32 message loop. This is Flutter platform boilerplate; changes are normally limited to window title, size, and icon.

## Interface
- `main.cpp:wWinMain` - process entry point. Attaches to the parent console (or creates one when a debugger is present), initializes COM, builds `flutter::DartProject(L"data")`, forwards command-line arguments as Dart entrypoint arguments, creates the window titled `ver2_app` at origin (10, 10) with size 1280x720, and pumps messages.
- `win32_window.h:Win32Window` - DPI-aware Win32 window base class. Public: `Create(title, origin, size)`, `Show()`, `Destroy()`, `SetChildContent(HWND)`, `GetHandle()`, `SetQuitOnClose(bool)`, `GetClientArea()`, nested `Point` and `Size`. Protected virtuals: `MessageHandler`, `OnCreate`, `OnDestroy`.
- `flutter_window.h:FlutterWindow` - `Win32Window` subclass hosting the Flutter view. Constructor takes `const flutter::DartProject&`. Overrides `OnCreate`, `OnDestroy`, `MessageHandler`.
- `utils.h` - `CreateAndAttachConsole()`, `Utf8FromUtf16(const wchar_t*)`, `GetCommandLineArguments()`.
- `resource.h:IDI_APP_ICON` (101) - icon resource id used by `Runner.rc` and `win32_window.cpp`.
- `Runner.rc` - version resource and icon; `VERSION_AS_NUMBER` / `VERSION_AS_STRING` come from `FLUTTER_VERSION*` definitions, with fallbacks `1,0,0,0` / `"1.0.0"`. Strings (CompanyName `com.example`, FileDescription, InternalName, ProductName `ver2_app`, OriginalFilename `ver2_app.exe`) are hard-coded.
- `runner.exe.manifest` - declares `PerMonitorV2` DPI awareness and Windows 10/11 `supportedOS`.
- `resources/app_icon.ico` - application icon (no source code in this subdirectory, so it has no contract file).
- `CMakeLists.txt` - defines the `WIN32` executable `${BINARY_NAME}` from `flutter_window.cpp`, `main.cpp`, `utils.cpp`, `win32_window.cpp`, `../flutter/generated_plugin_registrant.cc`, `Runner.rc`, and `runner.exe.manifest`. New source files must be added here.

## Invariants
- `FlutterWindow::OnCreate` returns false if the Flutter engine or view fails to initialize; `main.cpp` then exits with `EXIT_FAILURE`.
- The Flutter view is created at the window's client-area size, and `RegisterPlugins` is called with the engine before the view is attached.
- The window stays hidden until the first Flutter frame (`SetNextFrameCallback` calls `Show()`); `ForceRedraw()` guards against the frame completing before registration.
- `FlutterWindow::MessageHandler` lets Flutter (`HandleTopLevelWindowProc`) handle messages before falling back to `Win32Window::MessageHandler`.
- `Win32Window::Create` scales the requested size by the monitor DPI (`FlutterDesktopGetDpiForMonitor`).
- The target compiles with `/W4 /WX` (via `apply_standard_settings` in `../CMakeLists.txt`), so warnings are errors.
- `flutter_assemble` is a build dependency of the runner and must not be removed (`CMakeLists.txt`).
- The target name must be changed in `../CMakeLists.txt` (`BINARY_NAME`), not here, or `flutter run` stops working (comment in `CMakeLists.txt`).

## Side Effects
- `AttachConsole` / `AllocConsole` and `freopen_s` redirect stdout and stderr to a console; calls `FlutterDesktopResyncOutputStreams`.
- `CoInitializeEx` (apartment threaded) on startup and `CoUninitialize` on exit.
- Registers (and on last window destruction unregisters) a Win32 window class; loads `IDI_APP_ICON`.
- Reads the `AppsUseLightTheme` registry value and calls `DwmSetWindowAttribute` (`DWMWA_USE_IMMERSIVE_DARK_MODE`) to match the system theme; links `dwmapi.lib`.
- `WM_FONTCHANGE` triggers `engine()->ReloadSystemFonts()`.

## Verification
- Run from the repo root (`PollutionViz-Frontend`): `flutter build windows` (Windows host required) and `flutter analyze`.
