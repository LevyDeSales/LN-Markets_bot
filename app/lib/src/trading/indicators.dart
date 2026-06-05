import 'dart:math' as math;

class Candle {
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle(this.open, this.high, this.low, this.close, this.volume);
}

class TrendResult {
  final String? signal;
  final String? cross;
  final bool confirmed;
  final double emaFast;
  final double emaSlow;
  final double emaSignal;
  final double price;
  final bool bbFilter;
  final bool macdFilter;

  const TrendResult({
    this.signal,
    this.cross,
    required this.confirmed,
    required this.emaFast,
    required this.emaSlow,
    required this.emaSignal,
    required this.price,
    required this.bbFilter,
    required this.macdFilter,
  });
}

class IndicatorSettings {
  final int emaFast;
  final int emaSlow;
  final int emaSignal;

  const IndicatorSettings({
    required this.emaFast,
    required this.emaSlow,
    required this.emaSignal,
  });
}

class TrendTabajaraIndicators {
  final IndicatorSettings settings;

  const TrendTabajaraIndicators(this.settings);

  List<double> ema(List<double> values, int period) {
    if (values.isEmpty) return const [];
    final k = 2.0 / (period + 1);
    final result = [values[0]];
    for (var i = 1; i < values.length; i++) {
      result.add(values[i] * k + result.last * (1 - k));
    }
    return result;
  }

  double bbMiddle(List<double> closes, int idx, {int period = 20}) {
    final start = math.max(0, idx - period + 1);
    final slice = closes.sublist(start, idx + 1);
    return slice.reduce((a, b) => a + b) / slice.length;
  }

  TrendResult compute(List<Candle> candles) {
    if (candles.length < settings.emaSignal + 2) {
      throw Exception(
        'Candles insuficientes: ${candles.length} < ${settings.emaSignal + 2}',
      );
    }

    final closes = candles.map((c) => c.close).toList();
    final fast = ema(closes, settings.emaFast);
    final slow = ema(closes, settings.emaSlow);
    final signalEma = ema(closes, settings.emaSignal);
    final macdFast = ema(closes, 12);
    final macdSlow = ema(closes, 26);
    final macdLine =
        List.generate(closes.length, (i) => macdFast[i] - macdSlow[i]);
    final macdSignal = ema(macdLine, 9);

    final idx = candles.length - 2;
    final fastNow = fast[idx];
    final fastPrev = fast[idx - 1];
    final slowNow = slow[idx];
    final slowPrev = slow[idx - 1];
    final signalNow = signalEma[idx];
    final price = closes[idx];

    String? cross;
    if (fastPrev <= slowPrev && fastNow > slowNow) {
      cross = 'golden';
    } else if (fastPrev >= slowPrev && fastNow < slowNow) {
      cross = 'death';
    }

    String? trend;
    if (fastNow > slowNow) {
      trend = 'long';
    } else if (fastNow < slowNow) {
      trend = 'short';
    }

    var confirmed = true;
    if (trend == 'long' && price < signalNow) confirmed = false;
    if (trend == 'short' && price > signalNow) confirmed = false;

    final bbFilter = price > bbMiddle(closes, idx);
    final macdFilter = macdLine[idx] > macdSignal[idx];

    return TrendResult(
      signal: confirmed ? trend : null,
      cross: cross,
      confirmed: confirmed,
      emaFast: double.parse(fastNow.toStringAsFixed(2)),
      emaSlow: double.parse(slowNow.toStringAsFixed(2)),
      emaSignal: double.parse(signalNow.toStringAsFixed(2)),
      price: double.parse(price.toStringAsFixed(2)),
      bbFilter: bbFilter,
      macdFilter: macdFilter,
    );
  }
}
