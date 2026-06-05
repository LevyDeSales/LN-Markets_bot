class BotSettingsSnapshot {
  final String network;
  final String timeframe;
  final bool longOnly;
  final int leverage;
  final int marginSats;
  final int checkInterval;
  final int emaFast;
  final int emaSlow;
  final int emaSignal;
  final double takeProfitPct;
  final double stopLossPct;
  final bool useTrailingStop;
  final double trailingStopPct;
  final bool useCompounding;
  final double compoundingPct;
  final String language;

  const BotSettingsSnapshot({
    required this.network,
    required this.timeframe,
    required this.longOnly,
    required this.leverage,
    required this.marginSats,
    required this.checkInterval,
    required this.emaFast,
    required this.emaSlow,
    required this.emaSignal,
    required this.takeProfitPct,
    required this.stopLossPct,
    required this.useTrailingStop,
    required this.trailingStopPct,
    required this.useCompounding,
    required this.compoundingPct,
    required this.language,
  });

  int get candlesLimit => (emaSignal * 3).clamp(150, 500);

  String get baseUrl => network == 'mainnet'
      ? 'https://api.lnmarkets.com'
      : 'https://api.testnet4.lnmarkets.com';
}
