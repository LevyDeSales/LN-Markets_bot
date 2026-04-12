import 'binance_api.dart';
import 'settings_service.dart';

class TrendResult {
  final String? signal;   // 'long' | 'short' | null
  final String? cross;    // 'golden' | 'death' | null
  final bool confirmed;
  final double emaFast, emaSlow, emaSignal;
  final double price;

  const TrendResult({
    this.signal,
    this.cross,
    required this.confirmed,
    required this.emaFast,
    required this.emaSlow,
    required this.emaSignal,
    required this.price,
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

    return TrendResult(
      signal:    confirmed ? trend : null,
      cross:     cross,
      confirmed: confirmed,
      emaFast:   double.parse(fastNow.toStringAsFixed(2)),
      emaSlow:   double.parse(slowNow.toStringAsFixed(2)),
      emaSignal: double.parse(sigNow.toStringAsFixed(2)),
      price:     double.parse(price.toStringAsFixed(2)),
    );
  }
}
