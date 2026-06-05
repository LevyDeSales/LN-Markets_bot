import 'dart:async';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../i18n.dart';
import '../services/market_data_service.dart';

class SponsorBanner extends StatefulWidget {
  const SponsorBanner({super.key});

  @override
  State<SponsorBanner> createState() => _SponsorBannerState();
}

class _SponsorBannerState extends State<SponsorBanner> {
  MarketData _data = MarketData.empty();
  int _index = 0;
  Timer? _cycleTimer;
  Timer? _fetchTimer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchTimer =
        Timer.periodic(const Duration(minutes: 30), (_) => _fetchData());
    _cycleTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) setState(() => _index = (_index + 1) % 3);
    });
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _fetchTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final d = await MarketDataService.fetch();
    if (mounted) {
      setState(() {
        _data = d;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _tile(
        icon: Icons.sync,
        color: AppColors.textMuted,
        label: t('market_loading'),
        value: '…',
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _buildSlide(_index),
    );
  }

  Widget _buildSlide(int i) {
    switch (i) {
      case 0:
        final fg = _data.fearGreedValue;
        final label = _data.fearGreedLabel ?? '—';
        final color = fg == null
            ? AppColors.textMuted
            : (fg >= 60
                ? AppColors.green
                : (fg <= 30 ? AppColors.red : AppColors.yellow));
        return _tile(
          key: const ValueKey(0),
          icon: Icons.mood,
          color: color,
          label: t('market_fg'),
          value: fg != null ? '$fg — $label' : '—',
        );

      case 1:
        final eh = _data.hashrateEh;
        return _tile(
          key: const ValueKey(1),
          icon: Icons.memory,
          color: AppColors.orange,
          label: t('market_hashrate'),
          value: eh != null ? '${eh.toStringAsFixed(1)} EH/s' : '—',
        );

      default:
        final dom = _data.btcDominance;
        return _tile(
          key: const ValueKey(2),
          icon: Icons.pie_chart_outline,
          color: const Color(0xFFF7931A),
          label: t('market_dominance'),
          value: dom != null ? '${dom.toStringAsFixed(1)}%' : '—',
        );
    }
  }

  Widget _tile({
    Key? key,
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) =>
      Container(
        key: key,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.panel,
          border: Border(
            top: BorderSide(color: color.withValues(alpha: .3), width: 1),
          ),
        ),
        child: Row(children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Row(children: [
              Flexible(
                child: Text(
                  '$label:  ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
          // Dots indicator
          Row(
              children: List.generate(
                  3,
                  (j) => Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(left: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: j == _index
                              ? color.withValues(alpha: .9)
                              : AppColors.divider,
                        ),
                      ))),
        ]),
      );
}
