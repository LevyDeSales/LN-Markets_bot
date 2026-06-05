import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_theme.dart';
import '../i18n.dart';
import '../services/sponsor_service.dart';
import '../services/remote_config_service.dart';

// Exchange icon colours (approximate brand colours)
const _exchangeColors = {
  'binance': Color(0xFFF0B90B),
  'bingx': Color(0xFF1DA1F2),
  'bybit': Color(0xFFFFB627),
  'okx': Color(0xFF000000),
};

const _exchangeIcons = {
  'binance': Icons.currency_bitcoin,
  'bingx': Icons.bar_chart,
  'bybit': Icons.show_chart,
  'okx': Icons.layers_outlined,
};

class SponsorsTab extends StatelessWidget {
  const SponsorsTab({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(t('partners_title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t('partners_subtitle'),
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted, height: 1.5)),
          const SizedBox(height: 20),

          // ── Exchange partner slots ──────────────────────────────────────
          _sectionLabel(t('partners_exchanges_title')),
          const SizedBox(height: 10),

          for (final ex in SponsorService.exchanges) ...[
            Builder(builder: (_) {
              // Overlay live status and URL from remote config if available
              final remote = RemoteConfigService.forId(ex.id);
              final merged = remote != null
                  ? Exchange(
                      id: ex.id,
                      name: ex.name,
                      tagline: ex.tagline,
                      signupUrl: remote.signupUrl.isNotEmpty
                          ? remote.signupUrl
                          : ex.signupUrl,
                      live: remote.live,
                    )
                  : ex;
              return _ExchangeCard(
                  exchange: merged, onTap: () => _open(merged.signupUrl));
            }),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 24),

          // ── Become a partner CTA ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppColors.orange.withValues(alpha: .25)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.handshake_outlined,
                    size: 20, color: AppColors.orange),
                const SizedBox(width: 8),
                Text(t('partners_cta_title'),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.orange)),
              ]),
              const SizedBox(height: 10),
              Text(t('partners_cta_body'),
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted, height: 1.5)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send, size: 18),
                  label: Text(t('spon_contact_telegram')),
                  onPressed: () => _open(kTelegramUrl),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
            letterSpacing: 1.0),
      );
}

class _ExchangeCard extends StatelessWidget {
  final Exchange exchange;
  final VoidCallback onTap;

  const _ExchangeCard({required this.exchange, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _exchangeColors[exchange.id] ?? AppColors.orange;
    final icon = _exchangeIcons[exchange.id] ?? Icons.open_in_new;
    final isLive = exchange.live;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isLive ? color.withValues(alpha: .5) : AppColors.divider,
              width: isLive ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(exchange.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain)),
                const SizedBox(width: 8),
                _Badge(live: isLive),
              ]),
              const SizedBox(height: 3),
              Text(exchange.tagline,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ]),
          ),
          Icon(Icons.chevron_right,
              color: isLive ? color.withValues(alpha: .8) : AppColors.textMuted,
              size: 20),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final bool live;
  const _Badge({required this.live});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: live
            ? AppColors.green.withValues(alpha: .15)
            : AppColors.yellow.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        live ? 'REFERRAL' : 'EM BREVE',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: live ? AppColors.green : AppColors.yellow,
        ),
      ),
    );
  }
}
