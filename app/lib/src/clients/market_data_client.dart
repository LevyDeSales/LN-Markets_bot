import '../../services/binance_api.dart';

abstract class MarketDataClient {
  Future<List<Candle>> fetchCandles(String interval, int limit);
  Future<double> fetchPrice();
}

class LiveMarketDataClient implements MarketDataClient {
  final BinanceAPI _api;

  LiveMarketDataClient(this._api);

  @override
  Future<List<Candle>> fetchCandles(String interval, int limit) =>
      _api.fetchCandles(interval, limit);

  @override
  Future<double> fetchPrice() => _api.fetchPrice();
}
