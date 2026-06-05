# Data Migration Plan

## Estrategia

Migracao idempotente no primeiro `SettingsRepository.load()` novo.

## Transformacoes

| Origem | Destino | Regra |
|---|---|---|
| SharedPreferences `api_key` | Secure storage `api_key` | copiar se destino vazio; limpar origem apos sucesso |
| SharedPreferences `api_secret` | Secure storage `api_secret` | copiar se destino vazio; limpar origem apos sucesso |
| SharedPreferences `api_passphrase` | Secure storage `api_passphrase` | copiar se destino vazio; limpar origem apos sucesso |
| demais settings | SharedPreferences | manter formato |
| `bot_position` | SharedPreferences | manter JSON compativel |

## Invalidos

- JSON invalido de posicao vira `PositionState.empty()`.
- Credenciais incompletas nao bloqueiam app, mas redirecionam para settings.

## Validacao

- Teste de migracao com fake secure store.
- Teste idempotente: rodar migracao duas vezes nao duplica nem corrompe valores.
