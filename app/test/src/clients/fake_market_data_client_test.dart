import 'package:flutter_test/flutter_test.dart';
import 'package:lnmarkets_bot/src/clients/fake_market_data_client.dart';

void main() {
  test('fake market data returns deterministic candles', () async {
    final client = FakeMarketDataClient();

    final candles = await client.fetchCandles('15m', 150);

    expect(candles, hasLength(150));
    expect(candles.last.close, greaterThan(candles.first.close));
    expect(candles.last.high, greaterThanOrEqualTo(candles.last.close));
    expect(candles.last.low, lessThanOrEqualTo(candles.last.open));
  });

  test('fake market data returns the latest fake close as price', () async {
    final client = FakeMarketDataClient(basePrice: 42000);

    final candles = await client.fetchCandles('1h', 3);
    final price = await client.fetchPrice();

    expect(price, candles.last.close);
  });
}
