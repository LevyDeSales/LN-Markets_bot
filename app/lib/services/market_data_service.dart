import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketData {
  final int?    fearGreedValue;           // 0–100
  final String? fearGreedLabel;           // "Extreme Fear" … "Extreme Greed"
  final double? hashrateEh;              // network hashrate in EH/s
  final double? btcDominance;            // BTC market-cap dominance %
  final DateTime fetchedAt;

  const MarketData({
    this.fearGreedValue,
    this.fearGreedLabel,
    this.hashrateEh,
    this.btcDominance,
    required this.fetchedAt,
  });

  static MarketData empty() => MarketData(fetchedAt: DateTime.now());
}

class MarketDataService {
  static MarketData _cache = MarketData.empty();
  static DateTime?  _lastFetch;

  static MarketData get cached => _cache;

  // Refresh at most every 30 min to respect free-tier limits
  static Future<MarketData> fetch({bool force = false}) async {
    final now = DateTime.now();
    if (!force &&
        _lastFetch != null &&
        now.difference(_lastFetch!).inMinutes < 30) {
      return _cache;
    }

    int?    fgValue;
    String? fgLabel;
    double? hashrate;
    double? dominance;

    // ── Fear & Greed (alternative.me) ─────────────────────────────────────
    try {
      final resp = await http
          .get(Uri.parse('https://api.alternative.me/fng/?limit=1'))
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final j   = jsonDecode(resp.body) as Map<String, dynamic>;
        final row = (j['data'] as List).first as Map<String, dynamic>;
        fgValue = int.tryParse(row['value'].toString());
        fgLabel = row['value_classification'] as String?;
      }
    } catch (_) {}

    // ── Network Hashrate (mempool.space) ──────────────────────────────────
    try {
      final resp = await http
          .get(Uri.parse('https://mempool.space/api/v1/mining/hashrate/3d'))
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final j  = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = (j['currentHashrate'] as num?)?.toDouble() ?? 0;
        hashrate = raw / 1e18; // H/s → EH/s
      }
    } catch (_) {}

    // ── BTC Dominance (CoinGecko free) ────────────────────────────────────
    try {
      final resp = await http
          .get(Uri.parse('https://api.coingecko.com/api/v3/global'))
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final j   = jsonDecode(resp.body) as Map<String, dynamic>;
        final pct = (j['data'] as Map<String, dynamic>)['market_cap_percentage']
            as Map<String, dynamic>?;
        dominance = (pct?['btc'] as num?)?.toDouble();
      }
    } catch (_) {}

    _lastFetch = now;
    _cache = MarketData(
      fearGreedValue: fgValue,
      fearGreedLabel: fgLabel,
      hashrateEh:     hashrate,
      btcDominance:   dominance,
      fetchedAt:      now,
    );
    return _cache;
  }
}
