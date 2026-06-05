# Requirements — Trading Automatizado

## Objetivo

🟢 **CONFIRMADO** Executar ciclos automatizados que leem mercado, calculam sinal, sincronizam posicao LN Markets e abrem/fecham trades conforme risco configurado.

## Requisitos Funcionais

| ID | Prioridade | Requisito | Evidencia | Confianca |
|---|---|---|---|---|
| RF-TRD-01 | Must | `start()` deve ser idempotente quando o bot ja esta rodando. | `trader_service.dart:142-143` | 🟢 |
| RF-TRD-02 | Must | O bot so entra em running apos `getUser()` LN Markets com sucesso. | `trader_service.dart:152-162` | 🟢 |
| RF-TRD-03 | Must | Ao iniciar, deve carregar posicao local persistida. | `trader_service.dart:148-150` | 🟢 |
| RF-TRD-04 | Must | Deve executar um ciclo imediato e timers periodicos de ciclo/P&L/preco. | `trader_service.dart:170-185` | 🟢 |
| RF-TRD-05 | Must | Deve limpar posicao local se o ID nao existir nas posicoes remotas. | `trader_service.dart:226-234` | 🟢 |
| RF-TRD-06 | Must | Sem posicao, deve abrir nova posicao quando houver sinal efetivo e filtros permitirem. | `trader_service.dart:280-300` | 🟢 |
| RF-TRD-07 | Must | Com posicao e sinal oposto, deve fechar antes de abrir a direcao oposta. | `trader_service.dart:303-329` | 🟢 |
| RF-TRD-08 | Must | Em long-only, sinal short deve ser ignorado para entrada e fechar long aberto sem reabrir short. | `trader_service.dart:277-278`, `trader_service.dart:332-347` | 🟢 |
| RF-TRD-09 | Should | Compound Mode deve usar percentual do saldo como margem. | `trader_service.dart:365-371` | 🟢 |
| RF-TRD-10 | Should | TP/SL devem ser calculados localmente e enviados para LN Markets quando configurados. | `trader_service.dart:387-449` | 🟢 |
| RF-TRD-11 | Should | Trailing stop deve subir em posicoes long quando preco sobe. | `trader_service.dart:247-264`, `trader_service.dart:417-431` | 🟢 |

## Criterios de Aceitacao

Dado que LN Markets `getUser()` falha  
Quando o usuario inicia o bot  
Entao `_running` permanece falso e um erro e logado.

Dado que nao ha posicao e o sinal efetivo e `long`  
Quando BB e MACD passam  
Entao o bot abre posicao `buy`.

Dado que `longOnly=true` e ha long aberto  
Quando a estrategia retorna `short`  
Entao o bot fecha o long e nao abre short.

Dado que trailing stop esta habilitado em long  
Quando o novo SL calculado e maior que o anterior  
Entao o bot atualiza stop loss remoto e persiste novo `trailSlPrice`.
