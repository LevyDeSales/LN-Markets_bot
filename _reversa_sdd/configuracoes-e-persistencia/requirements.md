# Requirements — Configuracoes e Persistencia

## Objetivo

🟢 **CONFIRMADO** Persistir credenciais LN Markets, rede, idioma e parametros de trading/risco em `SharedPreferences`.

## Requisitos Funcionais

| ID | Prioridade | Requisito | Evidencia | Confianca |
|---|---|---|---|---|
| RF-CONF-01 | Must | O app deve considerar credenciais completas somente quando key, secret e passphrase estao preenchidos. | `app/lib/services/settings_service.dart:27-28` | 🟢 |
| RF-CONF-02 | Must | O usuario deve poder escolher mainnet/testnet. | `settings_service.dart:30-32`, `settings_tab.dart:190-195` | 🟢 |
| RF-CONF-03 | Must | Settings deve persistir timeframe, leverage, margin, intervalo, EMAs, TP, SL, trailing, compounding, longOnly e idioma. | `app/lib/services/settings_service.dart:36-79` | 🟢 |
| RF-CONF-04 | Must | A UI deve bloquear save quando credenciais estao vazias. | `app/lib/screens/settings_tab.dart:79-88` | 🟢 |
| RF-CONF-05 | Should | Troca de idioma deve atualizar `AppLocalizations` e persistir `settings.language`. | `app/lib/screens/settings_tab.dart:116-121` | 🟢 |
| RF-CONF-06 | Should | Mudar timeframe deve sugerir intervalo de checagem correspondente. | `app/lib/screens/settings_tab.dart:8-15`, `app/lib/screens/settings_tab.dart:200-214` | 🟢 |

## Requisitos Nao Funcionais

| ID | Requisito | Evidencia | Confianca |
|---|---|---|---|
| RNF-CONF-01 | Persistencia deve funcionar offline e localmente. | `SharedPreferences.getInstance()` | 🟢 |
| RNF-CONF-02 | Falta de storage criptografado deve ser tratada como risco. | ausencia de secure storage | 🔴 |

## Criterios de Aceitacao

Dado que key, secret ou passphrase estao vazios  
Quando o usuario tenta salvar configuracoes  
Entao a UI mostra erro de credenciais e nao salva.

Dado que o usuario seleciona testnet  
Quando `SettingsService.baseUrl` e lido  
Entao deve retornar `https://api.testnet4.lnmarkets.com`.

Dado `emaSignal=50`  
Quando `candlesLimit` e lido  
Entao deve retornar 150.
