import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'lnmarkets_api.dart';
import 'binance_api.dart';
import 'indicators.dart';
import 'settings_service.dart';
import 'log_service.dart';
import 'foreground_service.dart';

// ── Modelos ───────────────────────────────────────────────────────────────────

class SessionStats {
  int totalTrades     = 0;
  int longTrades      = 0;
  int shortTrades     = 0;
  int netPnlSats      = 0;
  int unrealizedPnl   = 0;
  int get totalPnl    => netPnlSats + unrealizedPnl;
}

class PositionState {
  final String?   id;
  final String?   side;
  final double?   entryPrice;
  final double?   tpPrice;
  final double?   slPrice;
  final double?   trailSlPrice;  // current trailing SL level (null = not trailing)
  final DateTime? openedAt;

  const PositionState({
    this.id,
    this.side,
    this.entryPrice,
    this.tpPrice,
    this.slPrice,
    this.trailSlPrice,
    this.openedAt,
  });

  bool get hasPosition => id != null;

  factory PositionState.empty() => const PositionState();

  PositionState copyWith({double? trailSlPrice, double? slPrice}) => PositionState(
        id:           id,
        side:         side,
        entryPrice:   entryPrice,
        tpPrice:      tpPrice,
        slPrice:      slPrice ?? this.slPrice,
        trailSlPrice: trailSlPrice ?? this.trailSlPrice,
        openedAt:     openedAt,
      );

  factory PositionState.fromJson(Map<String, dynamic> j) => PositionState(
        id:           j['id']            as String?,
        side:         j['side']          as String?,
        entryPrice:   (j['entry_price']  as num?)?.toDouble(),
        tpPrice:      (j['tp_price']     as num?)?.toDouble(),
        slPrice:      (j['sl_price']     as num?)?.toDouble(),
        trailSlPrice: (j['trail_sl_price'] as num?)?.toDouble(),
        openedAt:     j['opened_at'] != null
            ? DateTime.tryParse(j['opened_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id':             id,
        'side':           side,
        'entry_price':    entryPrice,
        'tp_price':       tpPrice,
        'sl_price':       slPrice,
        'trail_sl_price': trailSlPrice,
        'opened_at':      openedAt?.toIso8601String(),
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

  // ── Persistência ──────────────────────────────────────────────────────────
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

    _stats     = SessionStats();
    _startTime = DateTime.now();
    _position  = await _loadPosition();

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

    // Inicia serviço em primeiro plano para manter o app ativo em background
    await ForegroundService.start(
      title: 'LN Markets Bot',
      text:  'Bot em execução…',
    );

    await _runCycle();

    _cycleTimer = Timer.periodic(
      Duration(minutes: settings.checkInterval),
      (_) => _runCycle(),
    );

    _pnlTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _updateUnrealizedPnl(),
    );

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
    ForegroundService.stop();
  }

  // ── Ciclo de verificação ──────────────────────────────────────────────────

  Future<void> _runCycle() async {
    log.info('${'─' * 50}');
    log.info('Iniciando ciclo: ${DateTime.now()}');

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
        'Sinal: ${result.signal ?? 'neutro'} | '
        'BB: ${result.bbFilter ? 'ok' : 'filt'} | '
        'MACD: ${result.macdFilter ? 'ok' : 'filt'}',
      );
    } catch (e) {
      log.error('Erro ao buscar indicadores: $e');
      notifyListeners();
      return;
    }

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

    // Trailing SL update — runs before signal logic so SL is always current
    if (settings.useTrailingStop &&
        _position.hasPosition &&
        _position.side == 'long') {
      final newSl = result.price * (1 - settings.trailingStopPct / 100);
      final currentTrailSl = _position.trailSlPrice;
      if (currentTrailSl == null || newSl > currentTrailSl) {
        try {
          await _api.setStopLoss(_position.id!, newSl);
          _position = _position.copyWith(trailSlPrice: newSl, slPrice: newSl);
          await _savePosition(_position);
          log.info(
              'Trailing SL → \$${newSl.toStringAsFixed(2)} '
              '(${settings.trailingStopPct}% abaixo de \$${result.price.toStringAsFixed(2)})');
        } catch (e) {
          log.warning('Falha ao atualizar trailing SL: $e');
        }
      }
    }

    final signal = result.signal;

    // Atualiza notificação com estado atual
    if (_running) {
      final statusText = signal != null
          ? 'Sinal: ${signal.toUpperCase()} | BTC \$${result.price.toStringAsFixed(0)}'
          : 'Neutro | BTC \$${result.price.toStringAsFixed(0)}';
      ForegroundService.update(title: 'LN Markets Bot', text: statusText);
    }

    // When longOnly, treat short signals as neutral
    final effectiveSignal = (settings.longOnly && signal == 'short') ? null : signal;

    if (!_position.hasPosition) {
      if (effectiveSignal != null) {
        // BB + MACD filters apply only to long entries
        final filtered = effectiveSignal == 'long' &&
            (!result.bbFilter || !result.macdFilter);
        if (filtered) {
          log.info(
              'Sinal long bloqueado por filtro — '
              'BB: ${result.bbFilter ? 'ok' : 'falhou'} | '
              'MACD: ${result.macdFilter ? 'ok' : 'falhou'}. Aguardando...');
        } else {
          log.info('Sem posição. Abrindo $effectiveSignal...');
          await _openNew(effectiveSignal, result.price);
        }
      } else {
        log.info(settings.longOnly && signal == 'short'
            ? 'Modo Long Only: sinal short ignorado. Aguardando...'
            : 'Sem sinal confirmado. Aguardando...');
      }
      notifyListeners();
      return;
    }

    if (effectiveSignal != null && _position.side != effectiveSignal) {
      log.info(
          'INVERSÃO! ${_position.side?.toUpperCase()} → ${effectiveSignal.toUpperCase()}');
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
      final filteredFlip = effectiveSignal == 'long' &&
          (!result.bbFilter || !result.macdFilter);
      if (!filteredFlip) {
        await _openNew(effectiveSignal, result.price);
      } else {
        log.info(
            'Inversão long bloqueada por filtro — '
            'BB: ${result.bbFilter ? 'ok' : 'falhou'} | '
            'MACD: ${result.macdFilter ? 'ok' : 'falhou'}.');
      }
      notifyListeners();
      return;
    }

    // In longOnly mode, close position when short signal fires (don't reopen short)
    if (settings.longOnly && signal == 'short' && _position.hasPosition && _position.side == 'long') {
      log.info('Modo Long Only: sinal short → fechando long sem reabrir.');
      try {
        final closeResult = await _api.closePosition(_position.id!);
        final pl = ((closeResult['pl'] as num?) ?? 0).toInt();
        _stats.netPnlSats += pl;
        log.info('Posição fechada | P&L = ${pl > 0 ? '+' : ''}$pl sats');
        _position = PositionState.empty();
        await _clearPosition();
      } catch (e) {
        log.error('Erro ao fechar posição: $e');
      }
      notifyListeners();
      return;
    }

    log.info(
        'Tendência mantida (${effectiveSignal ?? 'neutro'}). '
        'Posição ${_position.side?.toUpperCase() ?? '?'} continua.');

    try {
      final user = await _api.getUser();
      _balance = ((user['balance'] as num?) ?? 0).toInt();
    } catch (_) {}

    notifyListeners();
  }

  Future<void> _openNew(String signal, double currentPrice) async {
    try {
      final side = signal == 'long' ? 'buy' : 'sell';

      // Compound mode: use % of current balance as margin
      int? marginOverride;
      if (settings.useCompounding && _balance > 0) {
        marginOverride = (_balance * settings.compoundingPct / 100).round();
        marginOverride = marginOverride.clamp(1000, _balance); // min 1k sats
        log.info(
            'Compound margin: ${settings.compoundingPct}% × $_balance sats = $marginOverride sats');
      }

      final pos = await _api.openPosition(side, marginSats: marginOverride);

      _stats.totalTrades++;
      if (signal == 'long') {
        _stats.longTrades++;
      } else {
        _stats.shortTrades++;
      }

      final apiEntry = (pos['entryPrice'] as num?)?.toDouble() ??
                       (pos['entry_price'] as num?)?.toDouble();
      final entry    = (apiEntry != null && apiEntry > 0) ? apiEntry : currentPrice;

      // Compute TP/SL absolute prices locally for display
      final isLong = signal == 'long';
      double? tpPrice;
      double? slPrice;
      final tp = settings.takeProfitPct;
      final sl = settings.stopLossPct;
      if (tp > 0) {
        tpPrice = double.parse(
          (isLong ? entry * (1 + tp / 100) : entry * (1 - tp / 100))
              .toStringAsFixed(2));
      }
      if (sl > 0) {
        slPrice = double.parse(
          (isLong ? entry * (1 - sl / 100) : entry * (1 + sl / 100))
              .toStringAsFixed(2));
      }

      _position = PositionState(
        id:         pos['id'] as String?,
        side:       signal,
        entryPrice: entry,
        tpPrice:    tpPrice,
        slPrice:    slPrice,
        openedAt:   DateTime.now(),
      );
      await _savePosition(_position);

      log.info(
          'Posição aberta: $signal | id=${_position.id} | entry=\$$entry');

      if (_position.id != null) {
        if (settings.useTrailingStop && isLong) {
          // Set initial trailing SL; subsequent cycles will trail it upward
          final initialTrailSl = entry * (1 - settings.trailingStopPct / 100);
          try {
            await _api.setStopLoss(_position.id!, initialTrailSl);
            _position = _position.copyWith(
                trailSlPrice: initialTrailSl, slPrice: initialTrailSl);
            await _savePosition(_position);
            log.info(
                'Trailing SL inicial: \$${initialTrailSl.toStringAsFixed(2)} '
                '(${settings.trailingStopPct}% abaixo)');
          } catch (e) {
            log.warning('Falha ao aplicar trailing SL inicial: $e');
          }
          // Still apply TP if configured
          if (tp > 0) {
            try {
              await _api.applyTpSl(_position.id!, signal, entry);
              log.info('TP aplicado | TP=${tp}%');
            } catch (e) {
              log.warning('Falha ao aplicar TP: $e');
            }
          }
        } else {
          try {
            await _api.applyTpSl(_position.id!, signal, entry);
            if (tp > 0 || sl > 0) {
              log.info('TP/SL aplicados | TP=${tp}% | SL=${sl}%');
            }
          } catch (e) {
            log.warning('Falha ao aplicar TP/SL: $e');
          }
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
      _btcPrice = await BinanceAPI().fetchPrice();
      notifyListeners();
    } catch (_) {}
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
