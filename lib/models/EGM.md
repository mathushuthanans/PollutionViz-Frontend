# models

## Overview
Placeholder directory for data models. It currently contains a single zero-byte Dart file, `pollutant_model.dart`, so it defines no code. No other file in `lib/` imports it. The data models the app actually uses (`DashboardData`, `TrendsData`, `TrendsMeasurement`) live in `../datamodels.dart` (see the [parent contract](../EGM.md)), not here.

## Interface
- `pollutant_model.dart`: empty file (0 bytes). It declares no classes, functions, or constants.

## Invariants
- None. The directory has no code, so there are no contracts to preserve.
- Any symbol added here is new public surface. Document it in this file when you add it.

## Side Effects
- None. The directory has no code.

## Verification
- Run: `flutter analyze` (from `PollutionViz-Frontend/`)
- Run: `flutter test` (from `PollutionViz-Frontend/`)
