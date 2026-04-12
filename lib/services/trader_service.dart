import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'lnmarkets_api.dart';
import 'binance_api.dart';
import 'indicators.dart';
import 'settings_service.dart';
import 'log_service.dart';

// ── Modelos ───────────────────────────────────────────────────────────────────

class SessionStats {
  int totalTrades     = 0;
  int longTrades      = 0;
  int shortTrades     = 0;
  int netPnlSats      = 0;   // realizado
  int unrealizedPnl   = 0;   // posição aberta (atualizado a cada 15 s)
  int get totalPnl    => netPnlSats + unrealizedPnl;
}

class PositionState {
  final String?   id;
  final String?   side;   // 'long' | 'short'
  final double?   entryPrice;
  final DateTime? openedAt;
  const PositionState({this.id, this.side, this.entryPrice, this.openedAt});

  bool get hasPosition => id != null;

  factory PositionState.empty() =>
      const PositionState(id: null, side: null, entryPrice: null, openedAt: null);

  factory PositionState.fromJson(Map<String, dynamic> j) => PositionState(
        id:         j['id']   as String?,
        side:       j['side'] as String?,
        entryPrice: (j['entry_price'] as num?)?.toDouble(),
        openedAt:   j['opened_at'] != null
            ? DateTime.tryParse(j['opened_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id':          id,
        'side':        side,
        'entry_price': entryPrice,
        'opened_at':   openedAt?.toIso8601String(),
      };
}

// ── Serviço principal ─────────────────────────────────────────────────────────

class TraderService extends ChangeNotifier {
  final SettingsService settings;
  final LogService      log;

  TraderService({required this.settings, required this.log});

  // ── Estado observável ─────────────────────────────────────────────────────
  bool          _running      = false;
  TrendResult?  _lastTrend;
  PositionState _position     = PositionState.empty();
  SessionStats  _stats        = SessionStats();
  double        _btcPrice     = 0;
  int           _balance      = 0;
  DateTime?     _startTime;

  // Getters
  bool          get running    => _running;
  TrendResult?  get lastTrend  => _lastTrend;
  PositionState get position   => _position;
  SessionStats  get stats      => _stats;
  double        get btcPrice   => _btcPrice;
  int           get balance    => _balance;
  int           get runtimeSecs =>
      _startTime == null ? 0 :
      DateTime.now().difference(_startTime!).inSeconds;

  // ── Timers ────────────────────────────────────────────────────────────────
  Timer? _cycleTimer;
  Timer? _pnlTimer;
  Timer? _priceTimer;

  late LNMarketsAPI _api;
  late BinanceAPI   _binance;
  late Indicators   _indicators;

  // ── Persistência de estado da posição ─────────────────────────────────────
  static const _posKey = 'bot_position';

  Future<void> _savePosition(PositionState p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_posKey, jsonEncode(p.toJson()));
  }

  Future<PositionState> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_posKey);
    if (s == null) return PositionState.empty();
    try {
      return PositionState.fromJson(jsonDecode(s) as Map<String, dynamic>);
    } catch (_) {
      return PositionState.empty();
    }
  }

  Future<void> _clearPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_posKey);
  }

  // ── Start / Stop ──────────────────────────────────────────────────────────

  Future<void> start() async {
    if (_running) return;
    _api        = LNMarketsAPI(settings);
    _binance    = BinanceAPI();
    _indicators = Indicators(settings);

    _stats    = SessionStats();
    _startTime = DateTime.now();
    _position  = await _loadPosition();

    // Verificar conectividade
    try {
      final user = await _api.getUser();
      _balance = ((user['balance'] as num?) ?? 0).toInt();
      log.info('Conectado: ${user['username']} | saldo=$_balance sats');
    } catch (e) {
      log.error('Falha ao conectar com LN Markets: $e');
      return;
    }

    _running = true;
    notifyListeners();

    // Primeiro ciclo imediato
    await _runCycle();

    // Ciclo periódico
    _cycleTimer = Timer.periodic(
      Duration(minutes: settings.checkInterval),
      (_) => _runCycle(),
    );

    // Atualização do P&L não realizado a cada 15 s
    _pnlTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _updateUnrealizedPnl(),
    );

    // Atualização do preço quando bot está rodando
    _priceTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updatePrice(),
    );
  }

  void stop() {
    _running = false;
    _cycleTimer?.cancel();
    _pnlTimer?.cancel();
    _priceTimer?.cancel();
    _stats.unrealizedPnl = 0;
    log.info('Bot encerrado.');
    notifyListeners();
  }

  // ── Ciclo de verificação ──────────────────────────────────────────────────

  Future<void> _runCycle() async {
    log.info('${'─' * 50}');
    log.info('Iniciando ciclo: ${DateTime.now()}');

    // 1. Busca candles e calcula tendência
    TrendResult result;
    try {
      final candles = await _binance.fetchCandles(
          settings.timeframe, settings.candlesLimit);
      result = _indicators.compute(candles);
      _lastTrend = result;
      _btcPrice  = result.price;
      log.info(
        'Trend | Preço: \$${result.price} | '
        'EMA${settings.emaFast}: ${result.emaFast} | '
        'EMA${settings.emaSlow}: ${result.emaSlow} | '
        'Sinal: ${result.signal ?? 'neutro'}',
      );
    } catch (e) {
      log.error('Erro ao buscar indicadores: $e');
      notifyListeners();
      return;
    }

    // 2. Sincroniza estado com API
    try {
      final open = await _api.getOpenPositions();
      if (_position.hasPosition) {
        final ids = open.map((p) => p['id']).toList();
        if (!ids.contains(_position.id)) {
          log.warning('Posição ${_position.id} não encontrada. Limpando.');
          _position = PositionState.empty();
          await _clearPosition();
        }
      }
      // Atualiza P&L não realizado imediatamente
      if (open.isNotEmpty) {
        _stats.unrealizedPnl = ((open[0]['pl'] as num?) ?? 0).toInt();
      } else {
        _stats.unrealizedPnl = 0;
      }
    } catch (e) {
      log.error('Erro ao buscar posições: $e');
      notifyListeners();
      return;
    }

    final signal = result.signal;

    // ── Sem posição: abrir se há sinal ────────────────────────────────────
    if (!_position.hasPosition) {
      if (signal != null) {
        log.info('Sem posição. Abrindo $signal...');
        await _openNew(signal, result.price);
      } else {
        log.info('Sem sinal confirmado. Aguardando...');
      }
      notifyListeners();
      return;
    }

    // ── Inversão de tendência: fechar e reabrir ───────────────────────────
    if (signal != null && _position.side != signal) {
      log.info(
          'INVERSÃO! ${_position.side?.toUpperCase()} → ${signal.toUpperCase()}');
      try {
        final closeResult = await _api.closePosition(_position.id!);
        final pl = ((closeResult['pl'] as num?) ?? 0).toInt();
        _stats.netPnlSats += pl;
        log.info('Posição fechada | P&L = ${pl > 0 ? '+' : ''}$pl sats');
        _position = PositionState.empty();
        await _clearPosition();
      } catch (e) {
        log.error('Erro ao fechar posição: $e');
        notifyListeners();
        return;
      }
      await _openNew(signal, result.price);
      notifyListeners();
      return;
    }

    // ── Tendência mantida ─────────────────────────────────────────────────
    log.info(
        'Tendência mantida (${signal ?? 'neutro'}). '
        'Posição ${_position.side?.toUpperCase() ?? '?'} continua.');

    // Atualiza saldo
    try {
      final user = await _api.getUser();
      _balance = ((user['balance'] as num?) ?? 0).toInt();
    } catch (_) {}

    notifyListeners();
  }

  Future<void> _openNew(String signal, double currentPrice) async {
    try {
      final side = signal == 'long' ? 'buy' : 'sell';
      final pos  = await _api.openPosition(side);

      _stats.totalTrades++;
      if (signal == 'long') {
        _stats.longTrades++;
      } else {
        _stats.shortTrades++;
      }

      final apiEntry = (pos['entryPrice'] as num?)?.toDouble() ??
                       (pos['entry_price'] as num?)?.toDouble();
      final entry    = (apiEntry != null && apiEntry > 0) ? apiEntry : currentPrice;

      _position = PositionState(
        id:         pos['id'] as String?,
        side:       signal,
        entryPrice: entry,
        openedAt:   DateTime.now(),
      );
      await _savePosition(_position);

      log.info(
          'Posição aberta: $signal | id=${_position.id} | entry=\$$entry');

      // Aplica TP/SL
      if (_position.id != null) {
        try {
          await _api.applyTpSl(_position.id!, signal, entry);
          if (settings.takeProfitPct > 0 || settings.stopLossPct > 0) {
            log.info(
                'TP/SL aplicados | TP=${settings.takeProfitPct}% | SL=${settings.stopLossPct}%');
          }
        } catch (e) {
          log.warning('Falha ao aplicar TP/SL: $e');
        }
      }
    } catch (e) {
      log.error('Erro ao abrir posição: $e');
    }
  }

  // ── Atualizações periódicas ───────────────────────────────────────────────

  Future<void> _updateUnrealizedPnl() async {
    if (!_running) return;
    try {
      final open = await _api.getOpenPositions();
      _stats.unrealizedPnl = open.isNotEmpty
          ? ((open[0]['pl'] as num?) ?? 0).toInt()
          : 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _updatePrice() async {
    if (!_running) return;
    try {
      _btcPrice = await _binance.fetchPrice();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchPriceOnce() async {
    try {
      _btcPrice = await _binance.fetchPrice();
      notifyListeners();
    } catch (_) {}
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
