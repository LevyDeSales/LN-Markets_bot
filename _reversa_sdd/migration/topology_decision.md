# Topology Decision

## Topologia legada

Padrao: package-by-layer simples.

Arvore principal:

```text
app/lib/
  screens/
  services/
  widgets/
  app_theme.dart
  i18n.dart
  main.dart
```

Diagnostico: parcialmente problematica.

Evidencias:
- `TraderService` mistura timers, estado, API clients, persistencia e runtime platform.
- `SettingsService` mistura credenciais sensiveis e preferencias nao sensiveis em `SharedPreferences`.
- Ha duplicacao entre `lib/` raiz e `app/lib/`.

## Topologia alvo proposta

```text
app/lib/src/
  core/
  settings/
  trading/
  market_data/
  dashboard/
  logs/
  sponsors/
  platform/
    macos/
```

## Opcoes

1. Preservar topologia legada.
2. Adotar topologia moderna proposta.
3. Hibrido.

## Decisao aprovada

Opcao 3: hibrido.

Preservar telas/tabs e identidade visual, mas mover dominio, storage, runtime e APIs para modulos testaveis sob `app/lib/src`.

## Mapeamento legado -> novo

| Legado | Novo |
|---|---|
| `services/indicators.dart` | `src/trading/indicators.dart` |
| `services/trader_service.dart` | `src/trading/trading_engine.dart`, `src/trading/trader_controller.dart` |
| `services/settings_service.dart` | `src/settings/settings_model.dart`, `src/settings/settings_repository.dart`, `src/settings/credentials_store.dart` |
| `services/foreground_service.dart` | `src/platform/bot_runtime_controller.dart`, `src/platform/macos/macos_bot_runtime_controller.dart` |
| `services/*api.dart` | `src/market_data/*`, `src/trading/exchange_client.dart` |
| `screens/*` | mantidas inicialmente e adaptadas para facades novas |
