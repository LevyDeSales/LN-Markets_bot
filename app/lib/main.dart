import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'i18n.dart';
import 'services/settings_service.dart';
import 'services/trader_service.dart';
import 'services/log_service.dart';
import 'services/foreground_service.dart';
import 'services/remote_config_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Configure foreground service notification channel
  ForegroundService.init();

  final settings = SettingsService();
  await settings.load();
  AppLocalizations.setLanguage(settings.language);

  final logService    = LogService();
  final traderService = TraderService(settings: settings, log: logService);

  // Fetch remote exchange config (non-blocking, cached for offline use)
  RemoteConfigService.init();

  runApp(LNMarketsApp(
    settings:      settings,
    traderService: traderService,
    logService:    logService,
  ));
}

class LNMarketsApp extends StatefulWidget {
  final SettingsService settings;
  final TraderService   traderService;
  final LogService      logService;

  const LNMarketsApp({
    super.key,
    required this.settings,
    required this.traderService,
    required this.logService,
  });

  @override
  State<LNMarketsApp> createState() => _LNMarketsAppState();
}

class _LNMarketsAppState extends State<LNMarketsApp> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                    'LN Markets Bot',
      theme:                    AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: _splashDone
          ? HomeScreen(
              settings:      widget.settings,
              traderService: widget.traderService,
              logService:    widget.logService,
            )
          : SplashScreen(
              onDone: () => setState(() => _splashDone = true),
            ),
    );
  }
}
