import 'dart:convert';
import 'package:http/http.dart' as http;
import 'settings_service.dart';
import '../src/trading/lnmarkets_signer.dart';

class LNMarketsAPI {
  final SettingsService settings;
  final http.Client _client;

  LNMarketsAPI(this.settings, {http.Client? client})
      : _client = client ?? http.Client();

  // ── Autenticação HMAC-SHA256 ──────────────────────────────────────────────

  String _sign(String timestamp, String method, String path, String params) {
    return signLnMarketsRequest(
      timestamp: timestamp,
      method: method,
      path: path,
      params: params,
      secret: settings.apiSecret,
    );
  }

  Map<String, String> _authHeaders(String method, String path,
      {String params = ''}) {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final sig = _sign(ts, method, path, params);
    return {
      'LNM-ACCESS-KEY': settings.apiKey,
      'LNM-ACCESS-PASSPHRASE': settings.apiPassphrase,
      'LNM-ACCESS-SIGNATURE': sig,
      'LNM-ACCESS-TIMESTAMP': ts,
    };
  }

  // ── Requisições HTTP ──────────────────────────────────────────────────────

  Future<dynamic> _get(String path, {Map<String, String>? params}) async {
    String qs = '';
    if (params != null && params.isNotEmpty) {
      qs = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    }
    final headers = _authHeaders('GET', path, params: qs);
    final url =
        Uri.parse('${settings.baseUrl}$path${qs.isNotEmpty ? '?$qs' : ''}');
    final resp = await _client
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 15));
    return _parse(resp);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final bodyStr = jsonEncode(body);
    final headers = {
      ..._authHeaders('POST', path, params: bodyStr),
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('${settings.baseUrl}$path');
    final resp = await _client
        .post(url, headers: headers, body: bodyStr)
        .timeout(const Duration(seconds: 15));
    return _parse(resp);
  }

  Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    final bodyStr = jsonEncode(body);
    final headers = {
      ..._authHeaders('PUT', path, params: bodyStr),
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('${settings.baseUrl}$path');
    final resp = await _client
        .put(url, headers: headers, body: bodyStr)
        .timeout(const Duration(seconds: 15));
    return _parse(resp);
  }

  dynamic _parse(http.Response resp) {
    dynamic data;
    try {
      data = jsonDecode(resp.body);
    } catch (_) {
      data = resp.body;
    }
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('LN Markets API ${resp.statusCode}: $data');
    }
    return data;
  }

  // ── Endpoints ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getUser() async =>
      (await _get('/v3/account')) as Map<String, dynamic>;

  Future<List<dynamic>> getOpenPositions() async =>
      (await _get('/v3/futures/isolated/trades/running')) as List<dynamic>;

  Future<Map<String, dynamic>> openPosition(String side,
      {int? marginSats}) async {
    return (await _post('/v3/futures/isolated/trade', {
      'type': 'market',
      'side': side,
      'margin': marginSats ?? settings.marginSats,
      'leverage': settings.leverage,
    })) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> closePosition(String id) async =>
      (await _post('/v3/futures/isolated/trade/close', {'id': id}))
          as Map<String, dynamic>;

  Future<void> setTakeProfit(String id, double price) async => await _put(
      '/v3/futures/isolated/trade/takeprofit', {'id': id, 'value': price});

  Future<void> setStopLoss(String id, double price) async => await _put(
      '/v3/futures/isolated/trade/stoploss', {'id': id, 'value': price});

  Future<void> applyTpSl(String id, String side, double entryPrice) async {
    final tp = settings.takeProfitPct;
    final sl = settings.stopLossPct;
    if (tp <= 0 && sl <= 0) return;

    final isLong = side == 'long';
    if (tp > 0) {
      final tpPrice =
          isLong ? entryPrice * (1 + tp / 100) : entryPrice * (1 - tp / 100);
      await setTakeProfit(id, double.parse(tpPrice.toStringAsFixed(2)));
    }
    if (sl > 0) {
      final slPrice =
          isLong ? entryPrice * (1 - sl / 100) : entryPrice * (1 + sl / 100);
      await setStopLoss(id, double.parse(slPrice.toStringAsFixed(2)));
    }
  }
}
