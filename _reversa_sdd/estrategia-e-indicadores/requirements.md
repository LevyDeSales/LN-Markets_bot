# Requirements — Estrategia e Indicadores

## Objetivo

🟢 **CONFIRMADO** Calcular Trend Tabajara 3.0 com EMAs, cruzamentos, confirmacao por EMA sinal, filtro Bollinger middle e filtro MACD.

## Requisitos Funcionais

| ID | Prioridade | Requisito | Evidencia | Confianca |
|---|---|---|---|---|
| RF-IND-01 | Must | O calculo deve rejeitar candles insuficientes: menor que `emaSignal + 2`. | `indicators.dart:49-53` | 🟢 |
| RF-IND-02 | Must | EMA deve usar fator `2/(period+1)`. | `indicators.dart:31-39` | 🟢 |
| RF-IND-03 | Must | O candle usado para sinal deve ser o penultimo. | `indicators.dart:67-73` | 🟢 |
| RF-IND-04 | Must | Golden cross ocorre quando fast cruza acima de slow. | `indicators.dart:75-81` | 🟢 |
| RF-IND-05 | Must | Death cross ocorre quando fast cruza abaixo de slow. | `indicators.dart:75-81` | 🟢 |
| RF-IND-06 | Must | Tendencia long exige fast > slow; short exige fast < slow. | `indicators.dart:83-89` | 🟢 |
| RF-IND-07 | Must | EMA sinal confirma ou invalida a tendencia. | `indicators.dart:91-94` | 🟢 |
| RF-IND-08 | Should | Filtro BB deve indicar preco acima da SMA 20. | `indicators.dart:41-46`, `indicators.dart:96-98` | 🟢 |
| RF-IND-09 | Should | Filtro MACD deve indicar MACD line acima da signal line. | `indicators.dart:61-65`, `indicators.dart:100-101` | 🟢 |

## Criterios de Aceitacao

Dado menos candles que `emaSignal + 2`  
Quando `compute()` e chamado  
Entao deve lancar excecao de candles insuficientes.

Dado EMA fast acima da slow e preco acima/igual da EMA sinal  
Quando `compute()` roda  
Entao `signal` deve ser `long`.

Dado EMA fast abaixo da slow e preco abaixo/igual da EMA sinal  
Quando `compute()` roda  
Entao `signal` deve ser `short`.
