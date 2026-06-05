class TpSlPrices {
  final double? takeProfit;
  final double? stopLoss;

  const TpSlPrices({
    required this.takeProfit,
    required this.stopLoss,
  });
}

class LongOnlyClosePlan {
  final int closeQuantity;
  final int remainingQuantity;

  const LongOnlyClosePlan({
    required this.closeQuantity,
    required this.remainingQuantity,
  });
}

int? computeCompoundMargin({
  required int balanceSats,
  required double compoundingPct,
}) {
  if (balanceSats <= 0) return null;
  final raw = (balanceSats * compoundingPct / 100).round();
  if (balanceSats < 1000) return balanceSats;
  return raw.clamp(1000, balanceSats);
}

TpSlPrices computeTpSlPrices({
  required String side,
  required double entryPrice,
  required double takeProfitPct,
  required double stopLossPct,
}) {
  final isLong = side == 'long';
  double? tpPrice;
  double? slPrice;
  if (takeProfitPct > 0) {
    tpPrice = double.parse(
      (isLong
              ? entryPrice * (1 + takeProfitPct / 100)
              : entryPrice * (1 - takeProfitPct / 100))
          .toStringAsFixed(2),
    );
  }
  if (stopLossPct > 0) {
    slPrice = double.parse(
      (isLong
              ? entryPrice * (1 - stopLossPct / 100)
              : entryPrice * (1 + stopLossPct / 100))
          .toStringAsFixed(2),
    );
  }
  return TpSlPrices(takeProfit: tpPrice, stopLoss: slPrice);
}

double computeLongTrailingStop({
  required double price,
  required double trailingStopPct,
}) =>
    price * (1 - trailingStopPct / 100);

String? effectiveSignal({
  required bool longOnly,
  required String? signal,
}) =>
    longOnly && signal == 'short' ? null : signal;

LongOnlyClosePlan closeLongOnlyPosition({
  required int currentQuantity,
  required int requestedCloseQuantity,
}) {
  final safeCurrent = currentQuantity < 0 ? 0 : currentQuantity;
  final safeRequested = requestedCloseQuantity < 0 ? 0 : requestedCloseQuantity;
  final closeQuantity =
      safeRequested > safeCurrent ? safeCurrent : safeRequested;
  return LongOnlyClosePlan(
    closeQuantity: closeQuantity,
    remainingQuantity: safeCurrent - closeQuantity,
  );
}
