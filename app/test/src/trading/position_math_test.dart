import 'package:flutter_test/flutter_test.dart';
import 'package:lnmarkets_bot/src/trading/position_math.dart';

void main() {
  group('computeCompoundMargin', () {
    test('uses the configured percentage and clamps to balance', () {
      expect(
        computeCompoundMargin(balanceSats: 100000, compoundingPct: 10),
        10000,
      );
      expect(
        computeCompoundMargin(balanceSats: 5000, compoundingPct: 80),
        4000,
      );
      expect(
        computeCompoundMargin(balanceSats: 5000, compoundingPct: 1),
        1000,
      );
    });

    test('returns the balance when it is below the legacy 1000 sats floor', () {
      expect(
        computeCompoundMargin(balanceSats: 500, compoundingPct: 10),
        500,
      );
    });
  });

  group('computeTpSlPrices', () {
    test('mirrors TP and SL for long and short', () {
      final longPrices = computeTpSlPrices(
        side: 'long',
        entryPrice: 100,
        takeProfitPct: 5,
        stopLossPct: 2,
      );
      expect(longPrices.takeProfit, 105);
      expect(longPrices.stopLoss, 98);

      final shortPrices = computeTpSlPrices(
        side: 'short',
        entryPrice: 100,
        takeProfitPct: 5,
        stopLossPct: 2,
      );
      expect(shortPrices.takeProfit, 95);
      expect(shortPrices.stopLoss, 102);
    });
  });

  test('long-only neutralizes short signals', () {
    expect(effectiveSignal(longOnly: true, signal: 'short'), isNull);
    expect(effectiveSignal(longOnly: true, signal: 'long'), 'long');
    expect(effectiveSignal(longOnly: false, signal: 'short'), 'short');
  });

  test('long-only close plan never inverts into a short position', () {
    final plan = closeLongOnlyPosition(
      currentQuantity: 2,
      requestedCloseQuantity: 3,
    );

    expect(plan.closeQuantity, 2);
    expect(plan.remainingQuantity, 0);
  });
}
