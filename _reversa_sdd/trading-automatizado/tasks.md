# Tasks — Trading Automatizado

| ID | Tarefa | Origem legado | Pronto quando | Confianca |
|---|---|---|---|---|
| T-TRD-01 | Implementar `SessionStats` e `PositionState` com JSON round-trip. | `trader_service.dart:15-78` | Estado persiste e recupera posicao corretamente. | 🟢 |
| T-TRD-02 | Implementar `TraderService.start()` com conexao LN Markets, timers e foreground. | `trader_service.dart:142-185` | Bot inicia somente com `getUser()` bem-sucedido. | 🟢 |
| T-TRD-03 | Implementar `stop()` cancelando timers e foreground. | `trader_service.dart:188-197` | Nenhum timer continua depois de stop. | 🟢 |
| T-TRD-04 | Implementar `_runCycle()` com fetch de candles, indicadores e sincronizacao remota. | `trader_service.dart:201-245` | Ciclo atualiza trend, preco, P&L e limpa posicao obsoleta. | 🟢 |
| T-TRD-05 | Implementar regras de entrada, filtros BB/MACD e long-only. | `trader_service.dart:277-300` | Short e ignorado em long-only; long exige filtros. | 🟢 |
| T-TRD-06 | Implementar inversao e fechamento por sinal short em long-only. | `trader_service.dart:303-347` | P&L realizado e somado e posicao local limpa. | 🟢 |
| T-TRD-07 | Implementar `_openNew()` com compound margin, stats, TP/SL e persistencia. | `trader_service.dart:361-455` | Ordem abre e estado local fica consistente. | 🟢 |
| T-TRD-08 | Implementar atualizacoes de P&L/preco e dispose. | `trader_service.dart:459-489` | UI recebe notifyListeners em atualizacoes. | 🟢 |

## Testes sugeridos

- Unit test de `PositionState.fromJson/toJson`.
- Teste de `_runCycle` com mocks: sem posicao + long aprovado abre `buy`.
- Teste de long-only: short com long aberto fecha sem abrir sell.
- Teste de trailing: novo SL menor nao chama API; novo SL maior chama.
- Teste de compound margin com saldo baixo e alto.
