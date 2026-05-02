import 'package:flutter/material.dart';
import '../i18n.dart';
import '../services/settings_service.dart';
import '../services/trader_service.dart';
import '../services/log_service.dart';
import '../services/foreground_service.dart';
import '../app_theme.dart';
import '../widgets/sponsor_banner.dart';
import 'dashboard_tab.dart';
import 'settings_tab.dart';
import 'logs_tab.dart';
import 'sponsors_tab.dart';
import 'about_tab.dart';

class HomeScreen extends StatefulWidget {
  final SettingsService settings;
  final TraderService   traderService;
  final LogService      logService;

  const HomeScreen({
    super.key,
    required this.settings,
    required this.traderService,
    required this.logService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  // Desktop width threshold
  static const double _desktopBreak = 600;

  @override
  void initState() {
    super.initState();
    if (!widget.settings.hasCredentials) _tab = 1;
    widget.traderService.fetchPriceOnce();
    Future.delayed(const Duration(seconds: 2),
        () => ForegroundService.requestBatteryOptimization());
  }

  void _onTab(int i) => setState(() => _tab = i);

  List<Widget> get _pages => [
    DashboardTab(traderService: widget.traderService),
    SettingsTab(
      settings:      widget.settings,
      traderService: widget.traderService,
      onSaved:       () => setState(() {}),
    ),
    LogsTab(logService: widget.logService),
    const SponsorsTab(),
    const AboutTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _desktopBreak;
        return isDesktop ? _desktopLayout() : _mobileLayout();
      },
    );
  }

  // ── Mobile: bottom navigation bar ─────────────────────────────────────────

  Widget _mobileLayout() {
    return Scaffold(
      body: Column(children: [
        Expanded(child: IndexedStack(index: _tab, children: _pages)),
        const SponsorBanner(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap:        _onTab,
        items:        _navItems(),
      ),
    );
  }

  // ── Desktop: sidebar (NavigationRail) ──────────────────────────────────────

  Widget _desktopLayout() {
    return Scaffold(
      body: Row(children: [

        // Sidebar
        Container(
          width: 200,
          color: AppColors.panel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo header
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '⚡ LN Markets',
                  style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 8),
              // Nav items
              ..._sidebarItems(),
              const Spacer(),
              const Divider(color: AppColors.divider, height: 1),
              // Sponsor banner in sidebar footer
              const SponsorBanner(),
              const SizedBox(height: 8),
            ],
          ),
        ),

        const VerticalDivider(width: 1, color: AppColors.divider),

        // Content
        Expanded(
          child: IndexedStack(index: _tab, children: _pages),
        ),
      ]),
    );
  }

  List<Widget> _sidebarItems() {
    final labels = [
      t('nav_dashboard'),
      t('nav_settings'),
      t('nav_logs'),
      t('nav_sponsors'),
      t('nav_about'),
    ];
    final icons = [
      [Icons.dashboard_outlined, Icons.dashboard],
      [Icons.settings_outlined,  Icons.settings],
      [Icons.list_alt_outlined,  Icons.list_alt],
      [Icons.handshake_outlined, Icons.handshake],
      [Icons.info_outline,       Icons.info],
    ];

    return List.generate(labels.length, (i) {
      final active = _tab == i;
      return InkWell(
        onTap: () => _onTab(i),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? AppColors.orange.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Icon(
              active ? icons[i][1] : icons[i][0],
              size: 20,
              color: active ? AppColors.orange : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Text(
              labels[i],
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  color: active ? AppColors.orange : AppColors.textMuted),
            ),
          ]),
        ),
      );
    });
  }

  List<BottomNavigationBarItem> _navItems() => [
    BottomNavigationBarItem(
      icon:       const Icon(Icons.dashboard_outlined),
      activeIcon: const Icon(Icons.dashboard),
      label:      t('nav_dashboard'),
    ),
    BottomNavigationBarItem(
      icon:       const Icon(Icons.settings_outlined),
      activeIcon: const Icon(Icons.settings),
      label:      t('nav_settings'),
    ),
    BottomNavigationBarItem(
      icon:       const Icon(Icons.list_alt_outlined),
      activeIcon: const Icon(Icons.list_alt),
      label:      t('nav_logs'),
    ),
    BottomNavigationBarItem(
      icon:       const Icon(Icons.handshake_outlined),
      activeIcon: const Icon(Icons.handshake),
      label:      t('nav_sponsors'),
    ),
    BottomNavigationBarItem(
      icon:       const Icon(Icons.info_outline),
      activeIcon: const Icon(Icons.info),
      label:      t('nav_about'),
    ),
  ];
}
