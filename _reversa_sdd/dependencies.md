# Dependencias — LN Markets Bot

Gerado em: 2026-06-05T04:49:44Z

## Manifest principal atual

Arquivo: `app/pubspec.yaml`

| Pacote | Versao | Papel |
|---|---:|---|
| `flutter` | SDK | Framework UI multiplataforma |
| `http` | `^1.2.0` | Chamadas REST para LN Markets, Binance, market data e config remota |
| `crypto` | `^3.0.3` | HMAC-SHA256 para assinatura LN Markets |
| `shared_preferences` | `^2.3.0` | Persistencia local de credenciais, parametros, posicao e cache |
| `url_launcher` | `^6.3.0` | Abrir tutorial, Telegram e links de exchanges |
| `intl` | `^0.19.0` | Internacionalizacao/formatacao |
| `flutter_foreground_task` | `^8.0.0` | Servico em primeiro plano para manter execucao em background |

## Dev dependencies

| Pacote | Versao | Papel |
|---|---:|---|
| `flutter_test` | SDK | Framework de testes Flutter |
| `flutter_lints` | `^4.0.0` | Regras de lint |
| `flutter_launcher_icons` | `^0.14.1` | Geracao de icones |

## Manifest legado/seed na raiz

Arquivo: `pubspec.yaml`

| Diferenca relevante | Valor |
|---|---|
| Versao do app | `2.1.0+1` |
| Ausente em relacao a `app/pubspec.yaml` | `flutter_foreground_task` |
| Assets | somente `assets/icon/` |

## Gerenciadores e toolchain

- Gerenciador Dart/Flutter: `pub` via `flutter pub get`.
- Android: Gradle Kotlin DSL (`*.gradle.kts`).
- Plataformas Flutter geradas: Android, iOS, Linux, macOS, Web e Windows.
- Scripts: `setup.sh` e `app/build_deb_linux.sh`.

## Integracoes HTTP usadas pelo codigo

| Integracao | Arquivo | Timeout | Observacao |
|---|---|---:|---|
| LN Markets mainnet/testnet | `app/lib/services/lnmarkets_api.dart`, `app/lib/services/settings_service.dart` | 15s | Requer headers HMAC com key/secret/passphrase |
| Binance candles/preco | `app/lib/services/binance_api.dart` | 10s / 5s | BTCUSDT klines e ticker |
| Remote config | `app/lib/services/remote_config_service.dart` | 10s | Busca `https://bitfood.app/bot-config.json` e cacheia |
| Fear & Greed | `app/lib/services/market_data_service.dart` | 10s | `api.alternative.me` |
| Hashrate | `app/lib/services/market_data_service.dart` | 10s | `mempool.space` |
| BTC dominance | `app/lib/services/market_data_service.dart` | 10s | `api.coingecko.com` |

## Riscos de dependencia observados

- Pacotes binarios (`.deb`, `.apk`) estao versionados dentro de `app/`, aumentando o tamanho do repositorio.
- `app/test/widget_test.dart` nao exerce comportamento; dependencia de teste existe, mas cobertura funcional e praticamente nula.
- Credenciais sao persistidas via `shared_preferences`; o README diz armazenamento seguro, mas o codigo observado nao usa armazenamento seguro criptografado.
