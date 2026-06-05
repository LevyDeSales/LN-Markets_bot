# Requirements — Integracoes de Mercado

## Objetivo

🟢 **CONFIRMADO** Integrar LN Markets para trading autenticado, Binance para candles/preco e APIs publicas para indicadores de mercado.

## Requisitos Funcionais

| ID | Prioridade | Requisito | Evidencia | Confianca |
|---|---|---|---|---|
| RF-INT-01 | Must | LN Markets deve assinar requisicoes com HMAC-SHA256 base64. | `lnmarkets_api.dart:12-31` | 🟢 |
| RF-INT-02 | Must | GET/POST LN Markets devem aplicar timeout de 15s e erro para status nao 2xx. | `lnmarkets_api.dart:35-70` | 🟢 |
| RF-INT-03 | Must | Deve haver endpoints para conta, posicoes abertas, abrir/fechar trade e TP/SL. | `lnmarkets_api.dart:75-120` | 🟢 |
| RF-INT-04 | Must | Binance candles devem usar `BTCUSDT`, interval e limit. | `binance_api.dart:12-29` | 🟢 |
| RF-INT-05 | Must | Binance price deve retornar 0 quando status nao e 200 ou parse falha. | `binance_api.dart:32-39` | 🟢 |
| RF-INT-06 | Should | Market data deve buscar Fear & Greed, hashrate e BTC dominance. | `market_data_service.dart:42-78` | 🟢 |
| RF-INT-07 | Should | Market data deve cachear por 30 minutos. | `market_data_service.dart:28-35` | 🟢 |

## Criterios de Aceitacao

Dado credenciais LN Markets configuradas  
Quando `getUser()` e chamado  
Entao a requisicao deve conter headers `LNM-ACCESS-*`.

Dado resposta LN Markets 400  
Quando `_parse()` e chamado  
Entao deve lancar excecao com status e corpo.

Dado market data chamado duas vezes em menos de 30 minutos  
Quando `force=false`  
Entao a segunda chamada deve retornar cache.
