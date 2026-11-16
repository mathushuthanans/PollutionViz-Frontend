# widgets

## Overview
Placeholder directory for shared widgets. It currently contains a single zero-byte Dart file, `pm25_info_panel.dart`, so it defines no code. No other file in `lib/` imports it. The widgets the app actually uses are defined inline in the page files in `lib/` (for example `BgWrapper` in `bg_wrapper.dart` and the cards in `insights_page.dart`).

## Interface
- `pm25_info_panel.dart`: empty file (0 bytes). It declares no classes, functions, or constants.

## Invariants
- None. The directory has no code, so there are no contracts to preserve.
- Any symbol added here is new public surface. Document it in this file when you add it.

## Side Effects
- None. The directory has no code.

## Verification
- Run: `flutter analyze` (from `PollutionViz-Frontend/`)
- Run: `flutter test` (from `PollutionViz-Frontend/`)
