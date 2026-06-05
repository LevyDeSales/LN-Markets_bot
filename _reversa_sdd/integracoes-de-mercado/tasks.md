# Tasks — Integracoes de Mercado

| ID | Tarefa | Origem legado | Pronto quando | Confianca |
|---|---|---|---|---|
| T-INT-01 | Implementar assinatura HMAC LN Markets. | `lnmarkets_api.dart:12-31` | Headers batem com formato legado. | 🟢 |
| T-INT-02 | Implementar GET/POST LN Markets com timeout e parse. | `lnmarkets_api.dart:35-70` | Status nao 2xx lanca excecao. | 🟢 |
| T-INT-03 | Implementar metodos de conta/posicoes/trade/TP/SL. | `lnmarkets_api.dart:75-120` | Paths e payloads batem com legado. | 🟢 |
| T-INT-04 | Implementar Binance candles/preco. | `binance_api.dart:9-39` | Candles mapeiam OHLCV corretamente. | 🟢 |
| T-INT-05 | Implementar `MarketData` e cache 30 min. | `market_data_service.dart:4-35` | Segunda chamada retorna cache dentro da janela. | 🟢 |
| T-INT-06 | Implementar chamadas Alternative.me, mempool.space e CoinGecko. | `market_data_service.dart:42-78` | Campos sao populados quando APIs respondem 200. | 🟢 |

## Testes sugeridos

- Teste de assinatura HMAC com fixture.
- Testes HTTP mockados para status 2xx e erro LN Markets.
- Teste de mapping de kline Binance.
- Teste de cache market data com relogio controlado.
