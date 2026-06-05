# Inventario Scout — LN Markets Bot

Gerado em: 2026-06-05T04:49:44Z

## Resumo

- Projeto: LN Markets Bot
- Raiz analisada: `/Users/levy/Library/Mobile Documents/com~apple~CloudDocs/Levy-dev-icloud/Pessoal/LNbot/LN-Markets_bot`
- Aplicacao principal atual: `app/` (Flutter gerado, versao `3.3.0+6`)
- Codigo legado/seed tambem presente na raiz: `lib/`, `pubspec.yaml`, `setup.sh`
- Total de arquivos versionados analisados, excluindo `.git`, `.reversa` e `_reversa_sdd`: 201
- Linguagem principal: Dart
- Framework principal: Flutter
- Banco de dados: ausente; persistencia local via `shared_preferences`
- CI/CD: nenhum workflow detectado
- Docker: ausente
- Testes: `app/test/widget_test.dart`, arquivo minimo sem asserts

## Modulos identificados

1. `app-shell-ui` — bootstrap Flutter, tema, i18n, navegacao e tabs principais.
2. `settings-persistence` — credenciais, parametros de trading, idioma e persistencia local.
3. `trading-engine` — ciclo do bot, estado de posicao, abertura/fechamento, TP/SL, trailing stop e compounding.
4. `indicators-strategy` — Trend Tabajara 3.0, EMA, BB middle e MACD.
5. `external-apis-market-data` — LN Markets, Binance, Alternative.me, mempool.space e CoinGecko.
6. `background-service` — foreground task para manter o bot ativo.
7. `sponsors-remote-config` — cadastro local de exchanges, configuracao remota e banners.
8. `logging-dashboard` — logs em memoria e visualizacao de estado/P&L/dashboard.

## Estrutura de diretorios

```text
.
├── app/
│   ├── android/
│   ├── assets/
│   ├── ios/
│   ├── lib/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── linux/
│   ├── macos/
│   ├── test/
│   ├── web/
│   └── windows/
├── assets/
│   └── icon/
└── lib/
    ├── screens/
    └── services/
```

## Arquivos principais por area

### Bootstrap e UI

- `app/lib/main.dart` — inicializa Flutter, orientacao portrait, `ForegroundService`, settings, logs, trader e `RemoteConfigService`.
- `app/lib/screens/home_screen.dart` — layout responsivo com tabs Dashboard, Settings, Logs, Sponsors e About.
- `app/lib/screens/dashboard_tab.dart` — estado do bot, posicao, estatisticas, tendencia e indicadores de mercado.
- `app/lib/screens/settings_tab.dart` — credenciais LN Markets, rede, timeframe, EMAs, risco, long only, trailing stop e compounding.
- `app/lib/screens/logs_tab.dart` — stream de logs.
- `app/lib/screens/sponsors_tab.dart` — exchanges parceiras e links externos.
- `app/lib/widgets/sponsor_banner.dart` — banner de patrocinio.
- `app/lib/i18n.dart` — traducoes pt_BR, en_US e fr_FR.
- `app/lib/app_theme.dart` — tema visual.

### Servicos de dominio

- `app/lib/services/trader_service.dart` — motor principal de trading automatizado.
- `app/lib/services/indicators.dart` — calculo de EMA, cruzamentos, filtro BB e MACD.
- `app/lib/services/settings_service.dart` — estado configuravel e persistencia em `SharedPreferences`.
- `app/lib/services/lnmarkets_api.dart` — autenticacao HMAC e endpoints LN Markets.
- `app/lib/services/binance_api.dart` — candles e preco BTCUSDT da Binance.
- `app/lib/services/market_data_service.dart` — Fear & Greed, hashrate e dominancia BTC.
- `app/lib/services/remote_config_service.dart` — config remota `bot-config.json` com cache local.
- `app/lib/services/sponsor_service.dart` — registry local de exchanges.
- `app/lib/services/foreground_service.dart` — servico em primeiro plano.
- `app/lib/services/log_service.dart` — logs em stream broadcast.

### Plataformas Flutter

- Android: `app/android/`
- iOS: `app/ios/`
- Linux: `app/linux/`
- macOS: `app/macos/`
- Web: `app/web/`
- Windows: `app/windows/`

### Codigo raiz legado/seed

- `pubspec.yaml` — versao `2.1.0+1`, sem `flutter_foreground_task`.
- `lib/` — versao anterior do codigo Dart.
- `setup.sh` — cria/copias fontes para `app/`, gera icone e build APK.
- `generate_icon.py` — gera icone.

## Linguagens e tipos de arquivo

| Extensao | Contagem | Observacao |
|---|---:|---|
| `.dart` | 37 | Codigo Flutter/Dart principal e legado |
| `.png` | 57 | Assets e icones gerados por plataforma |
| `.xml` | 9 | Android manifests/resources |
| `.swift` | 7 | iOS/macOS runners |
| `.h` | 8 | Windows/Linux/macOS headers gerados |
| `.cpp` | 4 | Windows runner |
| `.cc` | 4 | Linux runner |
| `.kts` | 3 | Gradle Kotlin DSL |
| `.yaml` | 3 | Flutter pubspec/analysis |
| `.md` | 3 | README/licenca/docs Flutter |
| `.plist` | 6 | iOS/macOS config |
| `.json` | 4 | manifests/assets |
| `.deb` | 7 | Pacotes Linux versionados |
| `.apk` | 1 | APK versionado |
| Outros | 58 | Build/platform metadata |

## Entry points

- `app/lib/main.dart` — entrypoint Dart principal atual.
- `lib/main.dart` — entrypoint Dart legado/seed.
- `app/android/app/src/main/kotlin/com/unknownbtc/lnmarkets_bot/MainActivity.kt` — entrypoint Android nativo.
- `app/ios/Runner/AppDelegate.swift` e `app/ios/Runner/SceneDelegate.swift` — entrypoints iOS.
- `app/macos/Runner/AppDelegate.swift` e `app/macos/Runner/MainFlutterWindow.swift` — entrypoints macOS.
- `app/linux/runner/main.cc` — entrypoint Linux.
- `app/windows/runner/main.cpp` — entrypoint Windows.
- `app/web/index.html` — entrypoint Web.
- `setup.sh` — script de setup/build Android.
- `app/build_deb_linux.sh` — script de pacote Linux.

## Configuracoes

- `app/pubspec.yaml` — manifest Flutter atual.
- `pubspec.yaml` — manifest Flutter raiz legado/seed.
- `app/analysis_options.yaml` — lint Flutter.
- `app/pubspec.lock` — lockfile de dependencias.
- `app/android/build.gradle.kts`, `app/android/app/build.gradle.kts`, `app/android/settings.gradle.kts`.
- `app/android/app/src/main/AndroidManifest.xml` e variantes debug/profile.
- `app/ios/Runner/Info.plist`.
- `app/macos/Runner/Info.plist`.
- `app/web/manifest.json`.

## Integracoes externas detectadas

1. LN Markets API:
   - `https://api.lnmarkets.com`
   - `https://api.testnet4.lnmarkets.com`
   - Endpoints usados: `/v3/account`, `/v3/futures/isolated/trades/running`, `/v3/futures/isolated/trade`, `/v3/futures/isolated/trade/close`, `/v3/futures/isolated/trade/takeprofit`, `/v3/futures/isolated/trade/stoploss`
2. Binance API:
   - `https://api.binance.com/api/v3/klines`
   - `https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT`
3. Remote config:
   - `https://bitfood.app/bot-config.json`
4. Market indicators:
   - `https://api.alternative.me/fng/?limit=1`
   - `https://mempool.space/api/v1/mining/hashrate/3d`
   - `https://api.coingecko.com/api/v3/global`
5. Links externos de suporte/patrocinio:
   - YouTube tutorial
   - Telegram
   - Binance/BingX/Bybit/OKX signup URLs

## Persistencia e dados

- Nao ha migrations, DDL, ORM ou banco relacional.
- `SettingsService` persiste credenciais e parametros em `SharedPreferences`.
- `TraderService` persiste `PositionState` serializado em JSON na chave `bot_position`.
- `RemoteConfigService` persiste cache remoto na chave `remote_bot_config`.
- `LogService` mantem logs em memoria via `StreamController.broadcast`.

## Testes

- Framework: `flutter_test` via `app/pubspec.yaml`.
- Arquivo: `app/test/widget_test.dart`.
- Estado: teste vazio intencional; sem cobertura comportamental real.

## Lista de arquivos analisados

```text
.gitignore
LICENSE
README.md
app/.gitignore
app/.metadata
app/README.md
app/analysis_options.yaml
app/android/.gitignore
app/android/app/build.gradle.kts
app/android/app/src/debug/AndroidManifest.xml
app/android/app/src/main/AndroidManifest.xml
app/android/app/src/main/kotlin/com/unknownbtc/lnmarkets_bot/MainActivity.kt
app/android/app/src/main/res/drawable-hdpi/ic_launcher_foreground.png
app/android/app/src/main/res/drawable-hdpi/ic_launcher_monochrome.png
app/android/app/src/main/res/drawable-mdpi/ic_launcher_foreground.png
app/android/app/src/main/res/drawable-mdpi/ic_launcher_monochrome.png
app/android/app/src/main/res/drawable-v21/launch_background.xml
app/android/app/src/main/res/drawable-xhdpi/ic_launcher_foreground.png
app/android/app/src/main/res/drawable-xhdpi/ic_launcher_monochrome.png
app/android/app/src/main/res/drawable-xxhdpi/ic_launcher_foreground.png
app/android/app/src/main/res/drawable-xxhdpi/ic_launcher_monochrome.png
app/android/app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png
app/android/app/src/main/res/drawable-xxxhdpi/ic_launcher_monochrome.png
app/android/app/src/main/res/drawable/launch_background.xml
app/android/app/src/main/res/mipmap-anydpi-v26/launcher_icon.xml
app/android/app/src/main/res/mipmap-hdpi/ic_launcher.png
app/android/app/src/main/res/mipmap-hdpi/launcher_icon.png
app/android/app/src/main/res/mipmap-mdpi/ic_launcher.png
app/android/app/src/main/res/mipmap-mdpi/launcher_icon.png
app/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
app/android/app/src/main/res/mipmap-xhdpi/launcher_icon.png
app/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
app/android/app/src/main/res/mipmap-xxhdpi/launcher_icon.png
app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
app/android/app/src/main/res/mipmap-xxxhdpi/launcher_icon.png
app/android/app/src/main/res/values-night/styles.xml
app/android/app/src/main/res/values/colors.xml
app/android/app/src/main/res/values/styles.xml
app/android/app/src/profile/AndroidManifest.xml
app/android/build.gradle.kts
app/android/gradle.properties
app/android/settings.gradle.kts
app/assets/images/profile.jpeg
app/build_deb_linux.sh
app/ios/.gitignore
app/ios/Flutter/AppFrameworkInfo.plist
app/ios/Flutter/Debug.xcconfig
app/ios/Flutter/Release.xcconfig
app/ios/Runner.xcodeproj/project.pbxproj
app/ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata
app/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist
app/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings
app/ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme
app/ios/Runner/AppDelegate.swift
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-50x50@1x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-50x50@2x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-57x57@1x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-57x57@2x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-72x72@1x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-72x72@2x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png
app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png
app/ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json
app/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png
app/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png
app/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md
app/ios/Runner/Base.lproj/LaunchScreen.storyboard
app/ios/Runner/Base.lproj/Main.storyboard
app/ios/Runner/Info.plist
app/ios/Runner/Runner-Bridging-Header.h
app/ios/Runner/SceneDelegate.swift
app/ios/RunnerTests/RunnerTests.swift
app/lib/app_theme.dart
app/lib/i18n.dart
app/lib/main.dart
app/lib/screens/about_tab.dart
app/lib/screens/dashboard_tab.dart
app/lib/screens/home_screen.dart
app/lib/screens/logs_tab.dart
app/lib/screens/settings_tab.dart
app/lib/screens/splash_screen.dart
app/lib/screens/sponsors_tab.dart
app/lib/services/binance_api.dart
app/lib/services/foreground_service.dart
app/lib/services/indicators.dart
app/lib/services/lnmarkets_api.dart
app/lib/services/log_service.dart
app/lib/services/market_data_service.dart
app/lib/services/remote_config_service.dart
app/lib/services/settings_service.dart
app/lib/services/sponsor_service.dart
app/lib/services/trader_service.dart
app/lib/widgets/sponsor_banner.dart
app/linux/.gitignore
app/linux/CMakeLists.txt
app/linux/flutter/CMakeLists.txt
app/linux/flutter/generated_plugin_registrant.cc
app/linux/flutter/generated_plugin_registrant.h
app/linux/flutter/generated_plugins.cmake
app/linux/runner/CMakeLists.txt
app/linux/runner/main.cc
app/linux/runner/my_application.cc
app/linux/runner/my_application.h
app/lnmarkets-bot-linux_3.0.0_amd64.deb
app/lnmarkets-bot-linux_3.0.2_amd64.deb
app/lnmarkets-bot-linux_3.1.0_amd64.deb
app/lnmarkets-bot-linux_3.2.0_amd64.deb
app/lnmarkets-bot-linux_3.2.1_amd64.deb
app/lnmarkets-bot-linux_3.2.2_amd64.deb
app/lnmarkets-bot-linux_3.3.0_amd64.deb
app/lnmarkets-bot_3.1.0.apk
app/macos/.gitignore
app/macos/Flutter/Flutter-Debug.xcconfig
app/macos/Flutter/Flutter-Release.xcconfig
app/macos/Flutter/GeneratedPluginRegistrant.swift
app/macos/Runner.xcodeproj/project.pbxproj
app/macos/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist
app/macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme
app/macos/Runner.xcworkspace/contents.xcworkspacedata
app/macos/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist
app/macos/Runner/AppDelegate.swift
app/macos/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json
app/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png
app/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png
app/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png
app/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png
app/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png
app/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png
app/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png
app/macos/Runner/Base.lproj/MainMenu.xib
app/macos/Runner/Configs/AppInfo.xcconfig
app/macos/Runner/Configs/Debug.xcconfig
app/macos/Runner/Configs/Release.xcconfig
app/macos/Runner/Configs/Warnings.xcconfig
app/macos/Runner/DebugProfile.entitlements
app/macos/Runner/Info.plist
app/macos/Runner/MainFlutterWindow.swift
app/macos/Runner/Release.entitlements
app/macos/RunnerTests/RunnerTests.swift
app/pubspec.lock
app/pubspec.yaml
app/test/widget_test.dart
app/web/favicon.png
app/web/icons/Icon-192.png
app/web/icons/Icon-512.png
app/web/icons/Icon-maskable-192.png
app/web/icons/Icon-maskable-512.png
app/web/index.html
app/web/manifest.json
app/windows/.gitignore
app/windows/CMakeLists.txt
app/windows/flutter/CMakeLists.txt
app/windows/flutter/generated_plugin_registrant.cc
app/windows/flutter/generated_plugin_registrant.h
app/windows/flutter/generated_plugins.cmake
app/windows/runner/CMakeLists.txt
app/windows/runner/Runner.rc
app/windows/runner/flutter_window.cpp
app/windows/runner/flutter_window.h
app/windows/runner/main.cpp
app/windows/runner/resource.h
app/windows/runner/resources/app_icon.ico
app/windows/runner/runner.exe.manifest
app/windows/runner/utils.cpp
app/windows/runner/utils.h
app/windows/runner/win32_window.cpp
app/windows/runner/win32_window.h
assets/icon/icon.png
generate_icon.py
lib/app_theme.dart
lib/i18n.dart
lib/main.dart
lib/screens/about_tab.dart
lib/screens/dashboard_tab.dart
lib/screens/home_screen.dart
lib/screens/logs_tab.dart
lib/screens/settings_tab.dart
lib/screens/splash_screen.dart
lib/services/binance_api.dart
lib/services/indicators.dart
lib/services/lnmarkets_api.dart
lib/services/log_service.dart
lib/services/settings_service.dart
lib/services/trader_service.dart
pubspec.yaml
setup.sh
```
