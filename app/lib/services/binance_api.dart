import 'dart:convert';
import 'package:http/http.dart' as http;

class Candle {
  final double open, high, low, close, volume;
  const Candle(this.open, this.high, this.low, this.close, this.volume);
}

class BinanceAPI {
  static const _base = 'https://api.binance.com';

  Future<List<Candle>> fetchCandles(String interval, int limit) async {
    final url = Uri.parse('$_base/api/v3/klines').replace(queryParameters: {
      'symbol':   'BTCUSDT',
      'interval': interval,
      'limit':    '$limit',
    });
    final resp = await http.get(url).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('Binance error ${resp.statusCode}');
    }
    final raw = jsonDecode(resp.body) as List;
    return raw.map((c) => Candle(
      double.parse(c[1].toString()),
      double.parse(c[2].toString()),
      double.parse(c[3].toString()),
      double.parse(c[4].toString()),
      double.parse(c[5].toString()),
    )).toList();
  }

  Future<double> fetchPrice() async {
    final url = Uri.parse('$_base/api/v3/ticker/price?symbol=BTCUSDT');
    final resp = await http.get(url).timeout(const Duration(seconds: 5));
    if (resp.statusCode != 200) return 0;
    return double.tryParse(
            (jsonDecode(resp.body) as Map)['price'].toString()) ??
        0;
  }
}
