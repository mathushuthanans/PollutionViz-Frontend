import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A cached JSON object plus when it was stored.
class CachedJson {
  final Map<String, dynamic> data;
  final DateTime savedAt;
  const CachedJson(this.data, this.savedAt);

  Duration get age => DateTime.now().difference(savedAt);

  String get ageLabel => ageLabelOf(savedAt);

  /// "just now", "5 min ago", "3 h ago", "2 d ago".
  static String ageLabelOf(DateTime t) {
    final a = DateTime.now().difference(t);
    if (a.inMinutes < 1) return 'just now';
    if (a.inMinutes < 60) return '${a.inMinutes} min ago';
    if (a.inHours < 24) return '${a.inHours} h ago';
    return '${a.inDays} d ago';
  }
}

/// Tiny JSON cache on top of shared_preferences. Never throws: a broken or
/// missing cache simply means "no cached data".
class ApiCache {
  static const _prefix = 'cache_v1:';

  /// Coordinates rounded to ~1 km so tiny GPS jitter still hits the cache.
  static String coordKey(String name, double lat, double lon) =>
      '$name:${lat.toStringAsFixed(2)},${lon.toStringAsFixed(2)}';

  static Future<void> save(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_prefix$key',
        json.encode({'t': DateTime.now().millisecondsSinceEpoch, 'd': data}),
      );
    } catch (_) {}
  }

  static Future<CachedJson?> load(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$key');
      if (raw == null) return null;
      final decoded = json.decode(raw);
      if (decoded is! Map) return null;
      final d = decoded['d'];
      final t = decoded['t'];
      if (d is! Map || t is! int) return null;
      return CachedJson(
        Map<String, dynamic>.from(d),
        DateTime.fromMillisecondsSinceEpoch(t),
      );
    } catch (_) {
      return null;
    }
  }
}
