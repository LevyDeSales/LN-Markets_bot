import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../i18n.dart';
import '../services/settings_service.dart';
import '../services/trader_service.dart';
import '../services/log_service.dart';
import 'dashboard_tab.dart';
import 'settings_tab.dart';
import 'logs_tab.dart';
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

  @override
  void initState() {
    super.initState();
    // Navega para Settings se não houver credenciais
    if (!widget.settings.hasCredentials) _tab = 1;
    // Busca preço inicial
    widget.traderService.fetchPriceOnce();
  }

  void _onTabTapped(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          DashboardTab(traderService: widget.traderService),
          SettingsTab(
            settings:      widget.settings,
            traderService: widget.traderService,
            onSaved:       () => setState(() {}),
          ),
          LogsTab(logService: widget.logService),
          AboutTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap:        _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: t('nav_dashboard'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: t('nav_settings'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt_outlined),
            activeIcon: const Icon(Icons.list_alt),
            label: t('nav_logs'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info_outline),
            activeIcon: const Icon(Icons.info),
            label: t('nav_about'),
          ),
        ],
      ),
    );
  }
}
