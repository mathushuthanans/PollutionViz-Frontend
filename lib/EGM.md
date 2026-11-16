# lib

## Overview
Dart source for the PollutionVIZ Flutter app (package `ver2_app`). `main.dart` hosts a four-tab shell (Home, Insights, Scenarios, Profile) plus a draggable chatbot bubble that opens `ChatbotPage`. All network access goes through the free functions in `backend_url.dart`, which call one REST backend (`baseURL`). `location_service.dart` resolves the coordinates that the Insights, Scenarios and Chatbot pages query with.

Most files are page-level widgets with their sub-widgets defined inline. The `controllers/`, `models/` and `widgets/` subdirectories each hold one empty (0-byte) file. The data classes actually used live in `datamodels.dart`.

## Interface

### Entry point and shell (`main.dart`)
- `main()` calls `runApp(const PollutionVIZApp())`.
- `PollutionVIZApp` is a `StatefulWidget` that owns the `ThemeMode` (light by default, toggled by `_toggleTheme`) and builds the `MaterialApp` with Montserrat fonts.
- `MainNavigation({onToggleTheme, isDarkMode})` is the shell.
  - Bottom tabs: Home (0), Insights (1, the initial tab), Scenarios (2), Profile (3).
  - AppBar actions: location picker, theme toggle, export dialog.
  - The export dialog's four tiles only close the dialog.
  - A `Draggable` chatbot bubble opens `ChatbotPage` as a full-screen route.
- `ProfilePageScreen` wraps `ProfilePage` with hard-coded sample data (user name, location, AQI, saved locations).
- `PlaceholderPage({title})` is defined in `main.dart` and is not referenced elsewhere.
- Private helpers: `_ChatbotBubble`, `_ExportTile`.

### Location (`location_service.dart`)
- Constants `defaultLatitude` = 21.1458 and `defaultLongitude` = 79.0882 (Nagpur).
- `enum LocationSource { device, manual, fallback }`.
- `AppLocation({lat, lon, source, label, fallbackReason})` and `const AppLocation.fallback([reason])`. Equality and `hashCode` use only `lat` and `lon`.
- `PresetCity(name, lat, lon).toLocation()` and `presetCities`. The list holds Delhi, Mumbai, Bengaluru, Chennai, Kolkata, Hyderabad, Pune and Nagpur.
- `LocationService` (all static):
  - `resolve({useSaved = true}) -> Future<AppLocation>`
  - `saveManual(AppLocation)`
  - `clearManual()`

### Backend client (`backend_url.dart`)
- `const String baseURL` is `https://pollutionviz-backend-services.onrender.com`.
- GET helpers:
  - `fetchDashboardData({lat, lon})` calls `/get_location`.
  - `fetchTrendsData({lat, lon, range = "weekly"})` calls `/get_trends`.
  - `fetchScenarioPresets({lat, lon})` calls `/get_scenario_presets`.
  - `fetchHealthImpact({lat, lon})` calls `/health_impact`.
  - `fetchClarityHelp()` calls `/help`.
  - `fetchExplainPollutant(pollutant)` calls `/explain`.
  - `fetchMythBuster(claim)` calls `/myth_buster`.
- POST helpers:
  - `fetchCitizenActions({lat, lon})` calls `/citizen_actions` with lat and lon as query parameters.
  - `predictHealthRisk({pm25, pm10, no2, o3, co, asthma = 0, heartDisease = 0})` calls `/predict_health_risk`.
  - `predictRegionClass({pm25, pm10, no2, o3, co})` calls `/predict_region_class`.
  - `compareLocations({location1, location2, pm25_1?, pm10_1?, pm25_2?, pm10_2?})` calls `/compare_locations`.
  - `fetchHealthRisks({pm25, pm10, no2, co, o3})` calls `/health_risks`.
  - `suggestPolicies({location, aqi, pm25, pm10, no2, co, o3})` calls `/suggest_policies`.
  - `reducePollutionPlan({goal, location})` calls `/reduce_pollution_plan`.
- `fetchHealthImpact`, `predictHealthRisk` and `predictRegionClass` are not called anywhere else in `lib/`.

### Data models (`datamodels.dart`)
- `DashboardData.fromJson` reads `location.city`, `location.coordinates`, `date`, `weather.temp`, `weather.description`, `pollution.aqi`, `pollution.aqi_status` and the five pollutant fields. Nothing in `lib/` calls it.
- `TrendsData.fromJson`, with `range`, `data`, `units` and an optional `improvement`.
- `TrendsMeasurement.fromJson(json, range)`:
  - Accepts either `pm25` or `avg_pm25` (and the same for the other pollutants).
  - Takes the date from `date` for `weekly`, `month` for `monthly`, and `year` otherwise.

### Pages
- `home_page.dart`: `HomePage({onTryAR, onSignInStudent, onSignInPolicyMaker, feedbackImages})`. It is a static landing page with a one-shot shine animation and the `assets/some.png` background.
- `insights_page.dart`: `InsightsPage({lat, lon})` plus the public widgets `CurrentAqiAdvisoryWidget`, `PollutionTrendsCard`, `PollutionTrendsGraph`, `RegionalComparisonCard`, `HealthImpactAnalysisCard` and the data class `RegionAqi`. Private helpers include `_TrendsGraphPainter` (a `CustomPainter`).
- `scenerios.dart` (the filename is spelled this way): `ScenariosPage({lat, lon})` and the fallback lists `doRecommendations`, `dontRecommendations` and `minimizeRecommendations`.
- `chatbot_page.dart`: `ChatbotPage({onToggleTheme, isDarkMode, location})`. It has six tabs: Help, Compare Locations, Health Risks, Policy Tips, Fun Facts, Myth Buster. The file also defines its own `main()` and `MyApp` for standalone runs.
- `profile_page.dart`: `ProfilePage(...)` plus the public `NotificationPrefs`, `NotificationPreferencesCard`, `SavedLocation`, `SavedLocationsCard`, `DottedBorderContainer` and `AccountSettingsCard`.
- `webview_flutter.dart`: `WebARView`, a `WebViewWidget` scaffold titled "WebAR Viewer". It is not referenced from any other file.
- `bg_wrapper.dart`: `BgWrapper({child, opacity = 0.6})` returns `child` unchanged. The `opacity` value is ignored.

### Subdirectories
- [controllers](./controllers/EGM.md): empty placeholder (`ar_controller.dart`, 0 bytes).
- [models](./models/EGM.md): empty placeholder (`pollutant_model.dart`, 0 bytes).
- [widgets](./widgets/EGM.md): empty placeholder (`pm25_info_panel.dart`, 0 bytes).

## Invariants
- Every backend helper in `backend_url.dart` builds URLs from `baseURL`. Changing the deployment target means editing only that constant.
- Error handling in `backend_url.dart` is split:
  - These helpers catch, `print` and return `null` on any non-200 status or exception: `fetchDashboardData`, `fetchTrendsData`, `fetchHealthImpact`, `predictHealthRisk`, `predictRegionClass`, `fetchClarityHelp`, `fetchExplainPollutant`, `fetchMythBuster`, `compareLocations`, `fetchHealthRisks`, `suggestPolicies` and `reducePollutionPlan`.
  - `fetchScenarioPresets` and `fetchCitizenActions` apply a 15 second timeout and `rethrow`, so callers must handle exceptions.
- `fetchDashboardData` returns the `data` sub-map when the response has a `data` key, and otherwise the whole body.
- `LocationService.resolve` never throws. It tries the saved manual choice (unless `useSaved` is false), then device GPS, then `AppLocation.fallback(reason)`. GPS uses `LocationAccuracy.low` with a 10 second limit.
- `AppLocation.fallback` is always Nagpur (`defaultLatitude` and `defaultLongitude`) with `label` `'Nagpur'`.
- `InsightsPage` and `ScenariosPage` are keyed in `MainNavigation` by `lat` and `lon`, so a location change rebuilds them and refetches. They read their coordinates only from `widget.lat` and `widget.lon`.
- The Insights and Scenarios tabs show a spinner until the first location lookup resolves. When the location source is `fallback`, they show a `MaterialBanner` with a CHOOSE action.
- `_fetchTrendsData` in `insights_page.dart` falls back to hard-coded sample `TrendsData` (weekly, monthly, yearly) when the backend returns `null` or throws.
- `ScenariosPage._fetchScenariosData` retries up to `_maxRetries` (3) times, one second apart. `_fetchRecommendedActions` falls back to `getRandomRecommendations()`, which draws three random items per category from the local lists.
- `insights_page.dart` excludes preset cities within 30 km of the user and compares against the three nearest of the rest.
- `HealthImpactAnalysisCard` takes no parameters and does not use backend data.
- `ProfilePageScreen` shows hard-coded sample data. The `onTryAR`, `onSignInStudent` and `onSignInPolicyMaker` callbacks are passed as empty closures in `main.dart`, and `onEditProfile`, `onViewFullReport` and `onAddLocation` are passed as empty closures inside `ProfilePageScreen`.
- `WebARView` loads the placeholder URL `https://your-webar-app-url.com`.

## Side Effects
- Network: HTTPS GET and POST requests to `baseURL` through the `http` package. `fetchScenarioPresets` and `fetchCitizenActions` apply a 15 second timeout.
- Disk: `LocationService.saveManual` and `clearManual` write and remove the `manual_lat`, `manual_lon` and `manual_label` keys in `shared_preferences`. `resolve` reads them. Storage errors are swallowed.
- Device: `LocationService.resolve` can trigger an OS location-permission prompt (`Geolocator.requestPermission`) and a GPS fix.
- Console: failed API calls `print` an `API Error (...)` line. Some page-level failures use `debugPrint`.
- Network (fonts): `google_fonts` can download Montserrat at runtime.
- WebView: `WebARView` enables unrestricted JavaScript and disables the media-playback user-gesture requirement on Android.
- Assets: `HomePage` loads `assets/some.png`. `main.dart` references `assets/feedback1.png`, `assets/feedback2.png` and `assets/feedback3.png`. `InsightsPage` loads `assets/map_placeholder.png`. All five images are declared in `pubspec.yaml`; `assets/models/PM 2.5.glb` exists but is not declared or referenced from `lib/`.
- Animation: `CurrentAqiAdvisoryWidget` runs a repeating `AnimationController` for the blink effect, and disposes it.

## Verification
- Run: `flutter analyze` (from `PollutionViz-Frontend/`)
- Run: `flutter test` (from `PollutionViz-Frontend/`). `test/widget_test.dart` is the default counter smoke test and asserts counter UI that `PollutionVIZApp` does not render, so treat its result accordingly.
