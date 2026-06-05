import '../../services/binance_api.dart';
import 'market_data_client.dart';

class FakeMarketDataClient implements MarketDataClient {
  final double basePrice;
  List<Candle>? _lastCandles;

  FakeMarketDataClient({this.basePrice = 50000});

  @override
  Future<List<Candle>> fetchCandles(String interval, int limit) async {
    final safeLimit = limit < 1 ? 1 : limit;
    final candles = List.generate(safeLimit, (index) {
      final close = basePrice + index;
      return Candle(
        close - 1,
        close + 2,
        close - 2,
        close,
        100 + index.toDouble(),
      );
    });
    _lastCandles = candles;
    return candles;
  }

  @override
  Future<double> fetchPrice() async {
    final candles = _lastCandles ?? await fetchCandles('15m', 2);
    return candles.last.close;
  }
}
