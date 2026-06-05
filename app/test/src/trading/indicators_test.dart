import 'package:flutter_test/flutter_test.dart';
import 'package:lnmarkets_bot/src/trading/indicators.dart';

void main() {
  List<Candle> candlesFromCloses(List<double> closes) {
    return closes
        .map((close) => Candle(close - 1, close + 1, close - 2, close, 1))
        .toList();
  }

  test('throws when there are not enough candles for the signal EMA', () {
    const indicators = TrendTabajaraIndicators(
      IndicatorSettings(emaFast: 3, emaSlow: 5, emaSignal: 10),
    );

    expect(
      () => indicators.compute(candlesFromCloses(List.filled(10, 100))),
      throwsException,
    );
  });

  test('uses the penultimate closed candle as the price source', () {
    const indicators = TrendTabajaraIndicators(
      IndicatorSettings(emaFast: 3, emaSlow: 5, emaSignal: 10),
    );
    final closes = <double>[
      100,
      101,
      102,
      103,
      104,
      105,
      106,
      107,
      108,
      109,
      110,
      999,
    ];

    final result = indicators.compute(candlesFromCloses(closes));

    expect(result.price, 110);
  });

  test('reports a long signal on an upward trend when filters pass', () {
    const indicators = TrendTabajaraIndicators(
      IndicatorSettings(emaFast: 3, emaSlow: 5, emaSignal: 10),
    );
    final closes = List<double>.generate(40, (i) => 100 + i.toDouble());

    final result = indicators.compute(candlesFromCloses(closes));

    expect(result.signal, 'long');
    expect(result.bbFilter, isTrue);
    expect(result.macdFilter, isTrue);
  });
}
