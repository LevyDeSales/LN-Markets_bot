import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../i18n.dart';
import '../services/trader_service.dart';

class DashboardTab extends StatelessWidget {
  final TraderService traderService;
  const DashboardTab({super.key, required this.traderService});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: traderService,
      builder: (ctx, _) => _build(ctx),
    );
  }

  Widget _build(BuildContext context) {
    final tr     = traderService;
    final trend  = tr.lastTrend;
    final pos    = tr.position;
    final stats  = tr.stats;
    final signal = trend?.signal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('⚡ LN Markets Bot'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _StatusDot(running: tr.running, signal: signal),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(children: [

          // ── Status bar ──────────────────────────────────────────────────
          _StatusBar(traderService: tr),
          const SizedBox(height: 10),

          // ── Linha 1: Preço + Saldo ───────────────────────────────────────
          Row(children: [
            Expanded(child: _InfoCard(
              label: t('dash_price'),
              value: tr.btcPrice > 0
                  ? '\$ ${_fmt(tr.btcPrice, decimals: 2)}'
                  : '—',
            )),
            const SizedBox(width: 10),
            Expanded(child: _InfoCard(
              label:      t('dash_balance'),
              value:      '${_fmtInt(tr.balance)} ${t('dash_sats')}',
              valueColor: AppColors.orange,
            )),
          ]),
          const SizedBox(height: 10),

          // ── Linha 2: Tendência + Posição ─────────────────────────────────
          Row(children: [
            Expanded(child: _TrendCard(trend: trend)),
            const SizedBox(width: 10),
            Expanded(child: _PositionCard(position: pos)),
          ]),
          const SizedBox(height: 10),

          // ── Estatísticas ─────────────────────────────────────────────────
          _StatsCard(stats: stats, runtime: tr.runtimeSecs),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  static String _fmt(double v, {int decimals = 0}) {
    final parts = v.toStringAsFixed(decimals).split('.');
    final intPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return decimals > 0 ? '$intPart.${parts[1]}' : intPart;
  }

  static String _fmtInt(int v) => _fmt(v.toDouble());
}

// ── Status dot (AppBar) ───────────────────────────────────────────────────────
class _StatusDot extends StatelessWidget {
  final bool    running;
  final String? signal;
  const _StatusDot({required this.running, this.signal});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (!running) {
      color = AppColors.red;
    } else if (signal == 'long') {
      color = AppColors.green;
    } else if (signal == 'short') {
      color = AppColors.red;
    } else {
      color = AppColors.yellow;
    }
    return Icon(Icons.circle, size: 14, color: color);
  }
}

// ── Barra de status + Start/Stop ─────────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  final TraderService traderService;
  const _StatusBar({required this.traderService});

  @override
  Widget build(BuildContext context) {
    final running = traderService.running;
    final signal  = traderService.lastTrend?.signal;

    Color barColor;
    String barLabel;
    IconData barIcon;

    if (!running) {
      barColor = AppColors.red;
      barLabel = t('dash_stopped');
      barIcon  = Icons.stop_circle_outlined;
    } else if (signal == 'long') {
      barColor = AppColors.green;
      barLabel = '${t('dash_running')}  ·  ${t('dash_long')}';
      barIcon  = Icons.arrow_upward;
    } else if (signal == 'short') {
      barColor = AppColors.red;
      barLabel = '${t('dash_running')}  ·  ${t('dash_short')}';
      barIcon  = Icons.arrow_downward;
    } else {
      barColor = AppColors.yellow;
      barLabel = t('dash_running');
      barIcon  = Icons.radio_button_checked;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: barColor.withOpacity(.4)),
      ),
      child: Row(children: [
        Icon(barIcon, color: barColor, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(barLabel,
              style: TextStyle(
                  color: barColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          width: 140,
          height: 40,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: running ? AppColors.red : AppColors.green,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: Icon(running ? Icons.pause : Icons.play_arrow, size: 18),
            label: Text(
                running ? t('dash_stop') : t('dash_start'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            onPressed: () {
              if (running) {
                traderService.stop();
              } else {
                traderService.start();
              }
            },
          ),
        ),
      ]),
    );
  }
}

// ── Card genérico de info ─────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String label, value;
  final Color  valueColor;
  const _InfoCard({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textMain,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: valueColor)),
        ]),
      ),
    );
  }
}

// ── Card de tendência ─────────────────────────────────────────────────────────
class _TrendCard extends StatelessWidget {
  final dynamic trend;
  const _TrendCard({this.trend});

  @override
  Widget build(BuildContext context) {
    final signal = trend?.signal as String?;
    Color  bgColor;
    Color  sigColor;
    String sigText;

    if (signal == 'long') {
      bgColor  = AppColors.cardLong;
      sigColor = AppColors.green;
      sigText  = t('dash_long');
    } else if (signal == 'short') {
      bgColor  = AppColors.cardShort;
      sigColor = AppColors.red;
      sigText  = t('dash_short');
    } else {
      bgColor  = AppColors.card;
      sigColor = AppColors.yellow;
      sigText  = t('dash_neutral');
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t('dash_trend'),
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(sigText,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: sigColor)),
        const SizedBox(height: 8),
        if (trend != null) ...[
          _emaRow('EMA fast',   '${trend!.emaFast}'),
          _emaRow('EMA slow',   '${trend!.emaSlow}'),
          _emaRow('EMA signal', '${trend!.emaSignal}'),
        ] else ...[
          _emaRow('EMA fast',   '—'),
          _emaRow('EMA slow',   '—'),
          _emaRow('EMA signal', '—'),
        ],
      ]),
    );
  }

  Widget _emaRow(String label, String val) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(children: [
          Text('$label: ',
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          Text(val,
              style: const TextStyle(fontSize: 10, color: AppColors.textMain)),
        ]),
      );
}

// ── Card de posição ───────────────────────────────────────────────────────────
class _PositionCard extends StatelessWidget {
  final dynamic position;
  const _PositionCard({required this.position});

  @override
  Widget build(BuildContext context) {
    final hasPos = position?.hasPosition == true;
    final side   = position?.side as String?;
    Color  bg    = hasPos
        ? (side == 'long' ? AppColors.cardLong : AppColors.cardShort)
        : AppColors.card;
    Color  sideColor = side == 'long' ? AppColors.green : AppColors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t('dash_position'),
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(
          hasPos ? side!.toUpperCase() : t('dash_no_position'),
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: hasPos ? sideColor : AppColors.textMuted),
        ),
        const SizedBox(height: 6),
        if (hasPos) ...[
          Text(
            '${t('dash_entry')}: \$ ${position!.entryPrice?.toStringAsFixed(2) ?? '—'}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            '${t('dash_opened')}: ${position!.openedAt?.toString().substring(0, 16) ?? ''}',
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ]),
    );
  }
}

// ── Stats ─────────────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final dynamic stats;
  final int     runtime;
  const _StatsCard({required this.stats, required this.runtime});

  static Color _pnlColor(int v) =>
      v > 0 ? AppColors.green : (v < 0 ? AppColors.red : AppColors.yellow);

  static String _pnlTxt(int v, bool hasData) {
    if (!hasData) return '—';
    return v > 0 ? '+$v' : '$v';
  }

  static String _fmtRuntime(int secs) {
    if (secs <= 0) return '—';
    final h = (secs ~/ 3600).toString().padLeft(2, '0');
    final m = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final total     = stats?.totalTrades   ?? 0;
    final longs     = stats?.longTrades    ?? 0;
    final shorts    = stats?.shortTrades   ?? 0;
    final realized  = stats?.netPnlSats    ?? 0;
    final unrealized = stats?.unrealizedPnl ?? 0;
    final totalPnl  = stats?.totalPnl      ?? 0;
    final hasData   = runtime > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t('stats_title'),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orange)),
          const SizedBox(height: 10),

          // Linha 1: contadores
          Row(children: [
            _mini(t('stats_total'),   '$total',              AppColors.textMain),
            _mini(t('stats_longs'),   '$longs',              AppColors.green),
            _mini(t('stats_shorts'),  '$shorts',             AppColors.red),
            _mini(t('stats_runtime'), _fmtRuntime(runtime),  AppColors.textMain),
          ]),
          const Divider(color: AppColors.divider, height: 16),

          // Linha 2: P&L
          Row(children: [
            _mini(t('stats_pnl_realized'),
                '${_pnlTxt(realized, hasData)} sats',
                hasData ? _pnlColor(realized) : AppColors.textMuted),
            _mini(t('stats_pnl_open'),
                '${_pnlTxt(unrealized, hasData)} sats',
                hasData ? _pnlColor(unrealized) : AppColors.yellow),
            Expanded(child: _miniWidget(
              t('stats_pnl_total'),
              '${_pnlTxt(totalPnl, hasData)} sats',
              hasData ? _pnlColor(totalPnl) : AppColors.yellow,
            )),
          ]),
          const SizedBox(height: 4),
        ]),
      ),
    );
  }

  Widget _mini(String label, String value, Color color) => Expanded(
        child: _miniWidget(label, value, color),
      );

  Widget _miniWidget(String label, String value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      );
}
