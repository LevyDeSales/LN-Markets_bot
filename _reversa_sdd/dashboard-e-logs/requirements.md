# Requirements — Dashboard e Logs

## Objetivo

🟢 **CONFIRMADO** Exibir estado do bot, preco, saldo, tendencia, posicao, estatisticas, indicadores de mercado e historico de logs.

## Requisitos Funcionais

| ID | Prioridade | Requisito | Evidencia | Confianca |
|---|---|---|---|---|
| RF-DASH-01 | Must | Dashboard deve reagir a `TraderService` via `AnimatedBuilder`. | `dashboard_tab.dart:8-18` | 🟢 |
| RF-DASH-02 | Must | Deve exibir status running/stopped e sinal long/short/neutro. | `dashboard_tab.dart:93-190` | 🟢 |
| RF-DASH-03 | Must | Botao principal deve chamar `start()` ou `stop()`. | `dashboard_tab.dart:164-184` | 🟢 |
| RF-DASH-04 | Must | Deve exibir preco BTC, saldo, tendencia, posicao e stats. | `dashboard_tab.dart:20-80`, `dashboard_tab.dart:222-431` | 🟢 |
| RF-DASH-05 | Should | Deve exibir indicadores de mercado com refresh a cada 30 min. | `dashboard_tab.dart:433-460` | 🟢 |
| RF-LOG-01 | Must | LogService deve publicar stream broadcast. | `log_service.dart:31-35` | 🟢 |
| RF-LOG-02 | Must | Historico de logs deve manter no maximo 500 entradas. | `log_service.dart:37-41` | 🟢 |
| RF-LOG-03 | Should | LogEntry deve formatar horario e prefixo por nivel. | `log_service.dart:11-28` | 🟢 |

## Criterios de Aceitacao

Dado `traderService.running=false`  
Quando Dashboard renderiza  
Entao status deve indicar parado e botao deve iniciar.

Dado `traderService.running=true`  
Quando usuario toca no botao  
Entao deve chamar `stop()`.

Dado que 501 logs sao adicionados  
Quando o historico e consultado  
Entao deve conter 500 entradas.
