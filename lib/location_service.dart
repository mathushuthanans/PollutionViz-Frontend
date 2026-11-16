import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Fallback used only when the device location and any saved choice are unavailable
// (Nagpur, India - matches backend reference datasets).
const double defaultLatitude = 21.1458;
const double defaultLongitude = 79.0882;

/// Where an [AppLocation] came from. Used to tell the user when the app is
/// showing a fallback instead of their real position.
enum LocationSource { device, manual, fallback }

class AppLocation {
  final double lat;
  final double lon;
  final LocationSource source;

  /// Human-readable label for manual picks. For device/fallback locations the
  /// backend's reverse-geocoded city is shown instead.
  final String? label;

  /// Why we fell back (permission denied, services off, timeout...). Only set
  /// when [source] is [LocationSource.fallback].
  final String? fallbackReason;

  const AppLocation({
    required this.lat,
    required this.lon,
    required this.source,
    this.label,
    this.fallbackReason,
  });

  const AppLocation.fallback([String? reason])
    : lat = defaultLatitude,
      lon = defaultLongitude,
      source = LocationSource.fallback,
      label = 'Nagpur',
      fallbackReason = reason;

  @override
  bool operator ==(Object other) =>
      other is AppLocation && other.lat == lat && other.lon == lon;

  @override
  int get hashCode => Object.hash(lat, lon);
}

class PresetCity {
  final String name;
  final double lat;
  final double lon;
  const PresetCity(this.name, this.lat, this.lon);

  AppLocation toLocation() => AppLocation(
    lat: lat,
    lon: lon,
    source: LocationSource.manual,
    label: name,
  );
}

const List<PresetCity> presetCities = [
  PresetCity('Delhi', 28.6139, 77.2090),
  PresetCity('Mumbai', 19.0760, 72.8777),
  PresetCity('Bengaluru', 12.9716, 77.5946),
  PresetCity('Chennai', 13.0827, 80.2707),
  PresetCity('Kolkata', 22.5726, 88.3639),
  PresetCity('Hyderabad', 17.3850, 78.4867),
  PresetCity('Pune', 18.5204, 73.8567),
  PresetCity('Nagpur', 21.1458, 79.0882),
];

class LocationService {
  static const _kLat = 'manual_lat';
  static const _kLon = 'manual_lon';
  static const _kLabel = 'manual_label';
  static const _kDevLat = 'device_lat';
  static const _kDevLon = 'device_lon';

  /// Great-circle distance in km (Geolocator ships the maths).
  static double distanceKm(AppLocation a, AppLocation b) =>
      Geolocator.distanceBetween(a.lat, a.lon, b.lat, b.lon) / 1000;

  static Future<void> _saveDevice(AppLocation loc) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kDevLat, loc.lat);
      await prefs.setDouble(_kDevLon, loc.lon);
    } catch (_) {}
  }

  /// An instant answer with no GPS wait: the saved manual city, else the last
  /// device position we stored, else the OS's last-known position. Null when
  /// none exist (first run). Never prompts for permission.
  static Future<AppLocation?> resolveFast() async {
    final manual = await _loadManual();
    if (manual != null) return manual;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_kDevLat);
      final lon = prefs.getDouble(_kDevLon);
      if (lat != null && lon != null) {
        return AppLocation(lat: lat, lon: lon, source: LocationSource.device);
      }
    } catch (_) {}
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return AppLocation(
          lat: last.latitude,
          lon: last.longitude,
          source: LocationSource.device,
        );
      }
    } catch (_) {} // not supported on every platform (e.g. web)
    return null;
  }

  /// Remember a manual city choice across app restarts.
  static Future<void> saveManual(AppLocation loc) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kLat, loc.lat);
      await prefs.setDouble(_kLon, loc.lon);
      await prefs.setString(_kLabel, loc.label ?? '');
    } catch (_) {}
  }

  /// Forget the manual choice (used by "Use my current location").
  static Future<void> clearManual() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kLat);
      await prefs.remove(_kLon);
      await prefs.remove(_kLabel);
    } catch (_) {}
  }

  static Future<AppLocation?> _loadManual() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_kLat);
      final lon = prefs.getDouble(_kLon);
      if (lat == null || lon == null) return null;
      return AppLocation(
        lat: lat,
        lon: lon,
        source: LocationSource.manual,
        label: prefs.getString(_kLabel),
      );
    } catch (_) {
      return null;
    }
  }

  /// Resolves the user's location: saved manual choice, then device GPS, then the default.
  /// Never throws; failures come back as [AppLocation.fallback] with a reason.
  static Future<AppLocation> resolve({bool useSaved = true}) async {
    if (useSaved) {
      final saved = await _loadManual();
      if (saved != null) return saved;
    }
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const AppLocation.fallback('Location services are turned off');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const AppLocation.fallback('Location permission denied');
      }
      if (permission == LocationPermission.deniedForever) {
        return const AppLocation.fallback(
          'Location permission permanently denied (enable it in settings)',
        );
      }

      // City-level accuracy is plenty for AQI and is faster / less
      // battery-hungry than a precise fix.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final result = AppLocation(
        lat: position.latitude,
        lon: position.longitude,
        source: LocationSource.device,
      );
      _saveDevice(result);
      return result;
    } catch (e) {
      return AppLocation.fallback('Could not get location ($e)');
    }
  }
}
