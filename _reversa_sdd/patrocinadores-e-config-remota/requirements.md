# Requirements — Patrocinadores e Config Remota

## Objetivo

🟢 **CONFIRMADO** Exibir exchanges parceiras com dados locais e permitir sobrescrita remota de status/link por `bot-config.json`.

## Requisitos Funcionais

| ID | Prioridade | Requisito | Evidencia | Confianca |
|---|---|---|---|---|
| RF-SPN-01 | Must | Deve existir registry local de Binance, BingX, Bybit e OKX. | `sponsor_service.dart:22-52` | 🟢 |
| RF-SPN-02 | Must | Deve buscar config remota em `https://bitfood.app/bot-config.json`. | `remote_config_service.dart:5-8`, `remote_config_service.dart:49-59` | 🟢 |
| RF-SPN-03 | Must | Config remota deve ser cacheada em `SharedPreferences` na chave `remote_bot_config`. | `remote_config_service.dart:29-59` | 🟢 |
| RF-SPN-04 | Must | Parser remoto deve aceitar lista `exchanges` com `id`, `live`, `signupUrl`. | `remote_config_service.dart:10-25`, `remote_config_service.dart:63-69` | 🟢 |
| RF-SPN-05 | Must | UI deve mesclar exchange local com config remota por `id`. | `sponsors_tab.dart:48-65` | 🟢 |
| RF-SPN-06 | Should | Links devem abrir em aplicacao externa via `url_launcher`. | `sponsors_tab.dart:26-29` | 🟢 |

## Criterios de Aceitacao

Dado config remota com `id=binance`, `live=true` e signupUrl nao vazio  
Quando SponsorsTab renderiza Binance  
Entao o card deve usar o link remoto e badge `REFERRAL`.

Dado erro HTTP na config remota  
Quando o app inicializa  
Entao deve manter cache/local sem quebrar.
