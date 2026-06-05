# Design — Dashboard e Logs

## Componentes

| Componente | Responsabilidade | Confianca |
|---|---|---|
| `DashboardTab` | Compor cards e observar `TraderService`. | 🟢 |
| `_StatusBar` | Status textual e botao start/stop. | 🟢 |
| `_TrendCard` | Sinal e EMAs. | 🟢 |
| `_PositionCard` | Side, entry, TP/SL e abertura. | 🟢 |
| `_StatsCard` | Contadores, runtime e P&L. | 🟢 |
| `_MarketIndicatorsCard` | Fear & Greed, hashrate e dominance. | 🟢 |
| `LogService` | Stream + historico de logs. | 🟢 |

## Fluxo Dashboard

```mermaid
flowchart TD
    Trader["TraderService notifyListeners"]
    Builder["AnimatedBuilder"]
    Status["StatusBar"]
    Trend["TrendCard"]
    Position["PositionCard"]
    Stats["StatsCard"]
    Market["MarketIndicatorsCard"]

    Trader --> Builder
    Builder --> Status
    Builder --> Trend
    Builder --> Position
    Builder --> Stats
    Builder --> Market
```

## Fluxo Logs

```mermaid
flowchart TD
    Add["LogService.info/warning/error/debug"]
    Entry["Criar LogEntry"]
    History["Adicionar em history"]
    Trim["Se >500 remover primeiro"]
    Stream["Publicar no stream"]

    Add --> Entry --> History --> Trim --> Stream
```

## Regras visuais

🟢 Status stopped usa vermelho; running long usa verde; running short usa vermelho; running neutro usa amarelo.

🟢 P&L positivo usa verde, negativo usa vermelho e zero/amarelo conforme card.

🟢 `_MarketIndicatorsCard` inicia fetch no `initState` e agenda timer de 30 minutos.
