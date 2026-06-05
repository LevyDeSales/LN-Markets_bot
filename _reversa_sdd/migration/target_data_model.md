# Target Data Model

## Entidades locais

| Entidade | Store | Sensibilidade | Observacao |
|---|---|---|---|
| `Credentials` | Secure storage | Alta | `api_key`, `api_secret`, `api_passphrase` |
| `BotSettings` | SharedPreferences | Media/Baixa | parametros de trading e idioma |
| `PositionState` | SharedPreferences | Media | estado local da posicao |
| `RemoteConfigCache` | SharedPreferences | Baixa | cache de partners |

## Chaves

| Chave | Store alvo | Origem |
|---|---|---|
| `api_key` | secure storage | SharedPreferences legado |
| `api_secret` | secure storage | SharedPreferences legado |
| `api_passphrase` | secure storage | SharedPreferences legado |
| `network` | shared prefs | SharedPreferences legado |
| `timeframe` | shared prefs | SharedPreferences legado |
| `leverage` | shared prefs | SharedPreferences legado |
| `margin_sats` | shared prefs | SharedPreferences legado |
| `bot_position` | shared prefs | SharedPreferences legado |
| `remote_bot_config` | shared prefs | SharedPreferences legado |

## Entitlements macOS

Adicionar capacidade de Keychain para secure storage e rede cliente para chamadas HTTPS.
