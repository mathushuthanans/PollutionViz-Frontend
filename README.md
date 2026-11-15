# PollutionViz — Flutter Frontend

<p align="center">
  <strong>Interactive Flutter frontend for PollutionViz</strong><br>
  Explore air quality, pollution trends, health impacts, scenarios, and AI-powered insights.
</p>

---

## Overview

PollutionViz is an air-pollution awareness and decision-support application designed to help users understand air quality and its potential impact on everyday life.

This repository contains the **Flutter frontend** of PollutionViz.

The frontend communicates with a FastAPI backend through REST APIs to retrieve:

- Air-quality and pollution data
- Weather information
- Location information
- Pollution trends
- Health-impact information
- Machine-learning predictions
- Policy recommendations
- Citizen actions
- AI-powered pollution insights

---

## Features

### 🏠 Dashboard

- Current air-quality information
- AQI display
- Pollutant measurements
- Weather information
- Location information
- Health-related pollution information

### 📈 Pollution Insights

- Weekly pollution trends
- Monthly pollution trends
- Yearly pollution trends
- Pollutant trend visualization
- Regional pollution comparison
- Health-impact analysis

### 🌍 Pollution Scenarios

- Pollution scenario presets
- Future pollution scenarios
- Pollutant-risk breakdown
- Main pollution sources
- Health risks associated with scenarios
- Recommended citizen actions

### 🧠 Machine Learning

The frontend integrates with backend ML services for:

- Health-risk prediction
- Region classification
- Pollution-related health analysis

### 🤖 Clarity AI

The application provides access to AI-assisted features including:

- Pollution explanations
- Pollution myth buster
- Policy suggestions
- Citizen recommendations
- Pollution-reduction planning

### 👤 Profile

- User profile interface
- Application-related user settings

---

## Application Structure

```text
PollutionViz-Frontend/
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
│
├── assets/
│
├── lib/
│   ├── backend_url.dart
│   ├── bg_wrapper.dart
│   ├── chatbot_page.dart
│   ├── datamodels.dart
│   ├── home_page.dart
│   ├── insights_page.dart
│   ├── main.dart
│   ├── profile_page.dart
│   ├── scenerios.dart
│   ├── webview_flutter.dart
│   │
│   ├── controllers/
│   ├── models/
│   └── widgets/
│
├── test/
│
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
````

---

## Important Files

| File                     | Purpose                                                  |
| ------------------------ | -------------------------------------------------------- |
| `lib/main.dart`          | Application entry point and main navigation              |
| `lib/backend_url.dart`   | Centralized backend URL configuration and REST API calls |
| `lib/home_page.dart`     | Main dashboard                                           |
| `lib/insights_page.dart` | Pollution trends and analytical views                    |
| `lib/scenerios.dart`     | Pollution scenario interface                             |
| `lib/chatbot_page.dart`  | Clarity AI / chatbot interface                           |
| `lib/profile_page.dart`  | User profile interface                                   |
| `lib/datamodels.dart`    | Data models used by the frontend                         |
| `lib/controllers/`       | Controller/application logic                             |
| `lib/models/`            | Supporting application models                            |
| `lib/widgets/`           | Reusable Flutter widgets                                 |

---

## Backend Integration

The frontend communicates with the PollutionViz FastAPI backend.

### Backend Repository

[https://github.com/mathushuthanans/PollutionViz-Backend](https://github.com/mathushuthanans/PollutionViz-Backend)

### API Configuration

Backend configuration is centralized in:

```text
lib/backend_url.dart
```

The current configuration supports three environments:

```text
Android Emulator
Physical Android Device
Deployed Production Backend
```

For Android Emulator development:

```dart
const String baseURL = 'http://10.0.2.2:8000';
```

For a physical device on the same Wi-Fi network:

```text
http://<YOUR_LOCAL_IP>:8000
```

For the deployed backend:

```text
https://pollutionviz-3hta.onrender.com
```

---

## API Integration

### Dashboard

```text
GET  /get_location
GET  /get_trends
GET  /get_scenario_presets
POST /citizen_actions
GET  /health_impact
```

Location-dependent requests use:

```text
lat
lon
```

Trend requests additionally support:

```text
range
```

with:

```text
weekly
monthly
yearly
```

### Machine Learning

```text
POST /predict_health_risk
POST /predict_region_class
```

### Clarity AI

```text
GET  /help
GET  /explain
POST /predict_policy
GET  /predict_policy
POST /compare_locations
POST /health_risks
POST /suggest_policies
GET  /myth_buster
POST /reduce_pollution_plan
```

---

## Location Handling

The frontend API layer is designed to work with latitude and longitude.

The current API client provides default development coordinates:

```text
Latitude:  21.1458
Longitude: 79.0882
```

These are used as fallback/testing coordinates when no coordinates are supplied.

The intended application flow is:

```text
Device Location
      ↓
Latitude + Longitude
      ↓
Flutter API Layer
      ↓
FastAPI Backend
      ↓
Pollution / Weather / AI / ML Services
      ↓
JSON Response
      ↓
Flutter UI
```

---

## Scenario Integration

Pollution scenarios are requested through:

```text
GET /get_scenario_presets?lat=<LAT>&lon=<LON>
```

The frontend expects scenario data containing fields such as:

```json
{
  "id": "scenario1",
  "name": "Winter Smog Trap",
  "description": "...",
  "top_pollutant_risks": [],
  "main_sources": [],
  "health_risks": [],
  "aqi_label": "Unhealthy"
}
```

The scenario screen displays:

* Scenario name
* Description
* Pollutant risks
* Main pollution sources
* Health risks
* AQI category

---

## Citizen Actions

Recommended citizen actions are retrieved through:

```text
POST /citizen_actions?lat=<LAT>&lon=<LON>
```

The frontend supports three recommendation categories:

```text
do
dont
minimize
```

If the backend request fails, the application contains a local fallback recommendation mechanism.

---

## Requirements

Install:

* Flutter SDK
* Dart SDK
* Android Studio
* Android SDK
* Android Emulator or Android device

Verify Flutter:

```bash
flutter doctor
```

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/mathushuthanans/PollutionViz-Frontend.git
cd PollutionViz-Frontend
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Check devices

```bash
flutter devices
```

### 4. List Android emulators

```bash
flutter emulators
```

### 5. Start the PollutionViz emulator

```bash
flutter emulators --launch PollutionViz
```

### 6. Run the application

```bash
flutter run -d emulator-5554
```

Replace `emulator-5554` with the device ID displayed by:

```bash
flutter devices
```

---

## Running on a Physical Android Device

Enable:

```text
Developer Options
USB Debugging
```

Connect the Android device to the development computer and verify:

```bash
flutter devices
```

Then:

```bash
flutter run -d <device-id>
```

For a physical device, the backend URL must use the development machine's local network IP rather than `10.0.2.2`.

---

## Running With the Local Backend

Start the FastAPI backend first:

```bash
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Then run the Flutter application.

For an Android Emulator, configure:

```dart
const String baseURL = 'http://10.0.2.2:8000';
```

---

## Development Workflow

```text
Flutter UI
    ↓
backend_url.dart
    ↓
HTTP / REST request
    ↓
FastAPI Backend
    ↓
OpenWeather / ML / AI services
    ↓
JSON response
    ↓
Flutter widgets
```

---

## Dependencies

The project uses Flutter packages including:

* `google_fonts`
* `http`
* `webview_flutter`
* `webview_flutter_android`
* `webview_flutter_wkwebview`

---

## Supported Platforms

The Flutter project contains platform projects for:

```text
Android
iOS
Linux
macOS
Web
Windows
```

The primary development target for the PollutionViz application is Android.

---

## Project Status

The frontend contains the primary PollutionViz application screens and backend integration layer.

Current development work includes:

* Backend API alignment
* Location-aware API requests
* Dynamic device location integration
* Frontend/backend response validation
* Scenario and citizen-action integration
* ML and Clarity AI integration

---

## Related Repository

### Backend

[https://github.com/mathushuthanans/PollutionViz-Backend](https://github.com/mathushuthanans/PollutionViz-Backend)

### Frontend

[https://github.com/mathushuthanans/PollutionViz-Frontend](https://github.com/mathushuthanans/PollutionViz-Frontend)

---

## Technology Stack

* **Flutter**
* **Dart**
* **FastAPI**
* **REST APIs**
* **OpenWeather**
* **Machine Learning**
* **Generative AI**
* **Android**

---

## License

This project is currently under development as part of the PollutionViz platform.

```

This version deliberately describes the **actual state of that commit**, rather than pretending dynamic GPS is already implemented. The API client at that commit has the location parameters and default coordinates, and it supports the Android emulator/physical-device/production URL configurations. 

One important detail: the commit also still has the package metadata `name: ver2_app` and description `"A new Flutter project."`, so I have not falsely claimed that the package itself has already been renamed to `pollutionviz`.
```
