import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  late SharedPreferences _prefs;

  // Defaults
  String apiKey        = '';
  String apiSecret     = '';
  String apiPassphrase = '';
  String network       = 'mainnet';
  String timeframe     = '1d';
  bool   longOnly      = true;   // true = @Raicher Mode ON (long only) by default
  int    leverage      = 5;
  int    marginSats    = 50000;
  int    checkInterval = 5;
  int    emaFast       = 9;
  int    emaSlow       = 21;
  int    emaSignal     = 50;
  double takeProfitPct  = 0.0;
  double stopLossPct    = 0.0;
  bool   useTrailingStop  = true;   // default ON (@Raicher Mode default)
  double trailingStopPct  = 1.0;   // default 1% — best from backtest on 1D
  bool   useCompounding   = true;  // default ON — use % of balance as margin
  double compoundingPct   = 10.0;  // % of balance to use per trade (default 10%)
  String language         = 'pt_BR';

  bool get hasCredentials =>
      apiKey.isNotEmpty && apiSecret.isNotEmpty && apiPassphrase.isNotEmpty;

  String get baseUrl => network == 'mainnet'
      ? 'https://api.lnmarkets.com'
      : 'https://api.testnet4.lnmarkets.com';

  int get candlesLimit => (emaSignal * 3).clamp(150, 500);

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    apiKey        = _prefs.getString('api_key')        ?? '';
    apiSecret     = _prefs.getString('api_secret')     ?? '';
    apiPassphrase = _prefs.getString('api_passphrase') ?? '';
    network       = _prefs.getString('network')        ?? 'mainnet';
    timeframe     = _prefs.getString('timeframe')      ?? '15m';
    leverage      = _prefs.getInt('leverage')          ?? 5;
    marginSats    = _prefs.getInt('margin_sats')       ?? 50000;
    checkInterval = _prefs.getInt('check_interval')    ?? 5;
    emaFast       = _prefs.getInt('ema_fast')          ?? 9;
    emaSlow       = _prefs.getInt('ema_slow')          ?? 21;
    emaSignal     = _prefs.getInt('ema_signal')        ?? 50;
    takeProfitPct   = _prefs.getDouble('take_profit_pct')   ?? 0.0;
    stopLossPct     = _prefs.getDouble('stop_loss_pct')     ?? 0.0;
    useTrailingStop = _prefs.getBool('use_trailing_stop')    ?? true;
    trailingStopPct = _prefs.getDouble('trailing_stop_pct') ?? 1.0;
    useCompounding  = _prefs.getBool('use_compounding')     ?? true;
    compoundingPct  = _prefs.getDouble('compounding_pct')   ?? 10.0;
    longOnly        = _prefs.getBool('long_only')           ?? true;
    language        = _prefs.getString('language')          ?? 'pt_BR';
  }

  Future<void> save() async {
    await _prefs.setString('api_key',          apiKey);
    await _prefs.setString('api_secret',       apiSecret);
    await _prefs.setString('api_passphrase',   apiPassphrase);
    await _prefs.setString('network',          network);
    await _prefs.setString('timeframe',        timeframe);
    await _prefs.setInt('leverage',            leverage);
    await _prefs.setInt('margin_sats',         marginSats);
    await _prefs.setInt('check_interval',      checkInterval);
    await _prefs.setInt('ema_fast',            emaFast);
    await _prefs.setInt('ema_slow',            emaSlow);
    await _prefs.setInt('ema_signal',          emaSignal);
    await _prefs.setDouble('take_profit_pct',   takeProfitPct);
    await _prefs.setDouble('stop_loss_pct',     stopLossPct);
    await _prefs.setBool('use_trailing_stop',   useTrailingStop);
    await _prefs.setDouble('trailing_stop_pct', trailingStopPct);
    await _prefs.setBool('use_compounding',     useCompounding);
    await _prefs.setDouble('compounding_pct',   compoundingPct);
    await _prefs.setBool('long_only',           longOnly);
    await _prefs.setString('language',          language);
  }
}
