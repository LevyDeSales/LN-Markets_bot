# Tasks — Estrategia e Indicadores

| ID | Tarefa | Origem legado | Pronto quando | Confianca |
|---|---|---|---|---|
| T-IND-01 | Implementar `Candle` e `TrendResult`. | `binance_api.dart:4-7`, `indicators.dart:5-24` | Campos batem com legado. | 🟢 |
| T-IND-02 | Implementar EMA com fator `2/(period+1)`. | `indicators.dart:31-39` | Valores batem em fixture conhecida. | 🟢 |
| T-IND-03 | Implementar BB middle como SMA 20 ate o indice. | `indicators.dart:41-46` | Janela inicial usa dados disponiveis. | 🟢 |
| T-IND-04 | Implementar validacao de candles minimos. | `indicators.dart:49-53` | Excecao ocorre para lista curta. | 🟢 |
| T-IND-05 | Implementar uso do penultimo candle. | `indicators.dart:67-73` | Ultimo candle aberto nao altera sinal. | 🟢 |
| T-IND-06 | Implementar cross/trend/confirmacao e filtros. | `indicators.dart:75-113` | `TrendResult` retorna campos completos. | 🟢 |

## Testes sugeridos

- Fixture de candles onde golden cross acontece no penultimo candle.
- Fixture onde ultimo candle mudaria sinal, mas penultimo preserva sinal anterior.
- Testes de confirmacao por EMA sinal.
- Testes de BB e MACD independentes.
