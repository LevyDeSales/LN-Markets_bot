# Tasks — Dashboard e Logs

| ID | Tarefa | Origem legado | Pronto quando | Confianca |
|---|---|---|---|---|
| T-DASH-01 | Implementar DashboardTab com `AnimatedBuilder`. | `dashboard_tab.dart:8-18` | Alteracoes em TraderService atualizam UI. | 🟢 |
| T-DASH-02 | Implementar StatusBar com cores, texto e start/stop. | `dashboard_tab.dart:115-190` | Botao chama start/stop correto. | 🟢 |
| T-DASH-03 | Implementar cards de preco/saldo/tendencia/posicao. | `dashboard_tab.dart:20-80`, `222-341` | Dados aparecem com fallback quando ausentes. | 🟢 |
| T-DASH-04 | Implementar StatsCard. | `dashboard_tab.dart:344-431` | Runtime e P&L formatam corretamente. | 🟢 |
| T-DASH-05 | Implementar MarketIndicatorsCard com timer 30 min. | `dashboard_tab.dart:433-460` | Timer cancela no dispose. | 🟢 |
| T-LOG-01 | Implementar `LogLevel`, `LogEntry` e prefixos. | `log_service.dart:3-28` | `toString()` inclui horario/prefixo/mensagem. | 🟢 |
| T-LOG-02 | Implementar `LogService` com stream broadcast e limite 500. | `log_service.dart:31-50` | 501 entradas resultam em 500 no historico. | 🟢 |

## Testes sugeridos

- Unit test de limite de historico.
- Unit test de prefixos por `LogLevel`.
- Widget test de botao start/stop com fake TraderService.
- Widget test de StatsCard com P&L positivo, negativo e zero.
