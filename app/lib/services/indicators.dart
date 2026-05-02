import 'dart:math' as math;
import 'binance_api.dart';
import 'settings_service.dart';

class TrendResult {
  final String? signal;   // 'long' | 'short' | null
  final String? cross;    // 'golden' | 'death' | null
  final bool confirmed;
  final double emaFast, emaSlow, emaSignal;
  final double price;
  final bool bbFilter;    // close > BB(20) middle band
  final bool macdFilter;  // MACD(12,26) line > signal(9)

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

class Indicators {
  final SettingsService settings;
  Indicators(this.settings);

  // ── EMA padrão (fator 2/(n+1)) ────────────────────────────────────────────
  List<double> _ema(List<double> values, int period) {
    final k = 2.0 / (period + 1);
    final result = [values[0]];
    for (int i = 1; i < values.length; i++) {
      result.add(values[i] * k + result.last * (1 - k));
    }
    return result;
  }

  // ── Bollinger Bands middle (SMA) at index ─────────────────────────────────
  double _bbMiddle(List<double> closes, int idx, {int period = 20}) {
    final start = math.max(0, idx - period + 1);
    final slice = closes.sublist(start, idx + 1);
    return slice.reduce((a, b) => a + b) / slice.length;
  }

  // ── Trend Tabajara 3.0 ────────────────────────────────────────────────────
  TrendResult compute(List<Candle> candles) {
    if (candles.length < settings.emaSignal + 2) {
      throw Exception(
          'Candles insuficientes: ${candles.length} < ${settings.emaSignal + 2}');
    }

    final closes = candles.map((c) => c.close).toList();

    final fast   = _ema(closes, settings.emaFast);
    final slow   = _ema(closes, settings.emaSlow);
    final signal = _ema(closes, settings.emaSignal);

    // MACD(12,26,9)
    final macdFast   = _ema(closes, 12);
    final macdSlow   = _ema(closes, 26);
    final macdLine   = List.generate(closes.length, (i) => macdFast[i] - macdSlow[i]);
    final macdSigLine = _ema(macdLine, 9);

    // Usa penúltimo candle (último completamente fechado)
    final idx = candles.length - 2;

    final fastNow  = fast[idx],   fastPrev  = fast[idx - 1];
    final slowNow  = slow[idx],   slowPrev  = slow[idx - 1];
    final sigNow   = signal[idx];
    final price    = closes[idx];

    // Detecção de cruzamento
    String? cross;
    if (fastPrev <= slowPrev && fastNow > slowNow) {
      cross = 'golden';
    } else if (fastPrev >= slowPrev && fastNow < slowNow) {
      cross = 'death';
    }

    // Direção atual
    String? trend;
    if (fastNow > slowNow) {
      trend = 'long';
    } else if (fastNow < slowNow) {
      trend = 'short';
    }

    // Confirmação pela EMA de sinal
    bool confirmed = true;
    if (trend == 'long'  && price < sigNow) confirmed = false;
    if (trend == 'short' && price > sigNow) confirmed = false;

    // Bollinger Bands(20) filter: close above middle band
    final bbMid    = _bbMiddle(closes, idx);
    final bbFilter = price > bbMid;

    // MACD filter: MACD line above signal line
    final macdFilter = macdLine[idx] > macdSigLine[idx];

    return TrendResult(
      signal:    confirmed ? trend : null,
      cross:     cross,
      confirmed: confirmed,
      emaFast:   double.parse(fastNow.toStringAsFixed(2)),
      emaSlow:   double.parse(slowNow.toStringAsFixed(2)),
      emaSignal: double.parse(sigNow.toStringAsFixed(2)),
      price:     double.parse(price.toStringAsFixed(2)),
      bbFilter:  bbFilter,
      macdFilter: macdFilter,
    );
  }
}
