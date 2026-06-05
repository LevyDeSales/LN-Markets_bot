# Design — Estrategia e Indicadores

## Componentes

| Componente | Responsabilidade | Confianca |
|---|---|---|
| `Candle` | OHLCV vindo da Binance. | 🟢 |
| `TrendResult` | Resultado de sinal/filtros para trading e dashboard. | 🟢 |
| `Indicators` | Calculo de EMAs, BB middle, MACD e sinal. | 🟢 |

## Algoritmo

```mermaid
flowchart TD
    Candles["List<Candle>"]
    Validate["length >= emaSignal + 2"]
    Closes["Extrair closes"]
    EMA["Calcular EMA fast/slow/signal"]
    MACD["Calcular MACD 12/26/9"]
    Closed["Usar idx = length - 2"]
    Cross["Detectar golden/death"]
    Trend["Definir trend fast vs slow"]
    Confirm["Confirmar por EMA signal"]
    Filters["BB middle + MACD filter"]
    Result["TrendResult"]

    Candles --> Validate --> Closes --> EMA --> MACD --> Closed --> Cross --> Trend --> Confirm --> Filters --> Result
```

## Saida

`TrendResult` retorna:

- `signal`: `long`, `short` ou null.
- `cross`: `golden`, `death` ou null.
- `confirmed`: booleano pos confirmacao por EMA sinal.
- EMAs e preco arredondados para 2 casas.
- `bbFilter` e `macdFilter` para bloqueio de entradas long no trading engine.

## Observacoes

🟢 O filtro BB/MACD e calculado sempre, mas o trading engine o aplica somente a entradas long.

🟡 O README descreve EMA9/21/50; o codigo permite configurar esses periodos pela UI.
