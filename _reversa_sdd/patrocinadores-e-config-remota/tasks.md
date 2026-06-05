# Tasks — Patrocinadores e Config Remota

| ID | Tarefa | Origem legado | Pronto quando | Confianca |
|---|---|---|---|---|
| T-SPN-01 | Implementar modelo `Exchange` e registry local. | `sponsor_service.dart:3-52` | Quatro exchanges existem com ids corretos. | 🟢 |
| T-SPN-02 | Implementar `RemoteExchange.fromJson`. | `remote_config_service.dart:10-25` | JSON remoto vira modelo tolerando campos opcionais. | 🟢 |
| T-SPN-03 | Implementar cache local e fetch remoto fire-and-forget. | `remote_config_service.dart:34-59` | Cache carrega antes do fetch remoto. | 🟢 |
| T-SPN-04 | Implementar `forId`. | `remote_config_service.dart:71-78` | Retorna null quando nao encontra. | 🟢 |
| T-SPN-05 | Implementar merge local/remoto em SponsorsTab. | `sponsors_tab.dart:48-65` | Link/status remoto sobrescreve local por id. | 🟢 |
| T-SPN-06 | Implementar cards, badges e CTA Telegram. | `sponsors_tab.dart:72-209` | UI mostra cards e abre links externos. | 🟢 |

## Testes sugeridos

- Unit test de parse remoto com signupUrl ausente.
- Unit test de merge preservando link local quando remoto vazio.
- Widget test para badge `REFERRAL`/`EM BREVE`.
