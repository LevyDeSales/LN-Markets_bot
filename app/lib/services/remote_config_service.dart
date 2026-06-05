import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// URL of the bot-config.json served by the landing page server.
// Update this to your production domain when you deploy.
const kBotConfigUrl = 'https://bitfood.app/bot-config.json';

class RemoteExchange {
  final String id;
  final bool live;
  final String signupUrl;

  const RemoteExchange({
    required this.id,
    required this.live,
    required this.signupUrl,
  });

  factory RemoteExchange.fromJson(Map<String, dynamic> j) => RemoteExchange(
        id: j['id'] as String,
        live: (j['live'] as bool?) ?? false,
        signupUrl: j['signupUrl'] as String? ?? '',
      );
}

class RemoteConfigService {
  static const _cacheKey = 'remote_bot_config';

  static List<RemoteExchange> _exchanges = [];
  static List<RemoteExchange> get exchanges => _exchanges;

  /// Call once at app startup. Loads persisted cache immediately, then
  /// fetches fresh data in the background.
  static Future<void> init() async {
    await _loadCache();
    _fetchAndCache(); // fire-and-forget
  }

  static Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) _parse(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {}
  }

  static Future<void> _fetchAndCache() async {
    try {
      final resp = await http
          .get(Uri.parse(kBotConfigUrl))
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final j = jsonDecode(resp.body) as Map<String, dynamic>;
        _parse(j);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, resp.body);
      }
    } catch (_) {}
  }

  static void _parse(Map<String, dynamic> j) {
    final list = j['exchanges'] as List<dynamic>? ?? [];
    _exchanges = list
        .whereType<Map<String, dynamic>>()
        .map(RemoteExchange.fromJson)
        .toList();
  }

  /// Returns the remote URL for a given exchange id, or null if not found/live.
  static RemoteExchange? forId(String id) {
    try {
      return _exchanges.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
