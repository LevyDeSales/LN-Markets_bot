# Target Domain Model

## Aggregates

| Aggregate | Root | Responsabilidade | Regras |
|---|---|---|---|
| BotSession | `TradingEngine` | start/stop, timers logicos, ciclo de trading | BR-MIGRAR-004..007 |
| Position | `PositionState` | estado local da posicao e trailing | BR-MIGRAR-012..017 |
| Strategy | `Indicators` | calculo Trend Tabajara 3.0 | BR-MIGRAR-008..010 |
| Settings | `BotSettings` | parametros de trading e rede | BR-MIGRAR-001..003 |

## Value Objects

- `Credentials`
- `BotSettings`
- `Candle`
- `TrendResult`
- `PositionState`
- `SessionStats`
- `TradeCommand`

## Commands

| Command | Resultado esperado |
|---|---|
| `StartBot` | valida credenciais, consulta user, inicia runtime e ciclo |
| `StopBot` | cancela runtime e timers, preserva posicao |
| `EvaluateCycle` | calcula trend, sincroniza posicao, decide trade |
| `SaveSettings` | persiste preferencias e credenciais nos stores corretos |

## Rastreabilidade

Cada `BR-MIGRAR-*` de `target_business_rules.md` deve ter teste unitario ou scenario de paridade.
