# Dominio — LN Markets Bot

Gerado em: 2026-06-05T04:59:21Z

Escala de confianca: 🟢 **CONFIRMADO** — extraido diretamente do codigo; 🟡 **INFERIDO** — baseado em padroes; 🔴 **LACUNA** — requer validacao humana.

## Glossario

| Termo | Significado | Confianca |
|---|---|---|
| Bot | Processo controlado por `TraderService` que executa ciclos periodicos de analise e trading. | 🟢 |
| LN Markets | Exchange/API usada para conta, posicoes e ordens futures. | 🟢 |
| Binance | Fonte publica de candles e preco BTCUSDT. | 🟢 |
| Trend Tabajara 3.0 | Estrategia baseada em EMAs configuraveis, confirmacao por EMA sinal e filtros BB/MACD. | 🟢 |
| EMA rapida | Media movel exponencial curta, default 9. | 🟢 |
| EMA lenta | Media movel exponencial longa, default 21. | 🟢 |
| EMA sinal | Filtro de tendencia, default 50. | 🟢 |
| Long Only / Raicher Mode | Quando ativo, o bot ignora abertura short e fecha long ao receber sinal short. | 🟢 |
| Trailing Stop | Stop loss que sobe junto com preco em posicoes long, mas nao desce. | 🟢 |
| Compound Mode | Modo que usa percentual do saldo como margem por trade. | 🟢 |
| TP/SL | Take Profit e Stop Loss remotos aplicados na LN Markets. | 🟢 |
| P&L realizado | Soma local de `pl` retornado no fechamento. | 🟢 |
| P&L nao realizado | `pl` da primeira posicao remota aberta. | 🟢 |
| Sponsors | Lista de exchanges parceiras com links locais/remotos. | 🟢 |

## Regras de negocio principais

1. 🟢 O app redireciona para configuracoes quando nao ha credenciais completas (`app/lib/screens/home_screen.dart:37-43`, `app/lib/services/settings_service.dart:27-28`).
2. 🟢 A rede `mainnet` usa `https://api.lnmarkets.com`; qualquer outro valor usa testnet4 (`app/lib/services/settings_service.dart:30-32`).
3. 🟢 O limite de candles e `emaSignal * 3`, limitado entre 150 e 500 (`app/lib/services/settings_service.dart:34`).
4. 🟢 O bot nao inicia duas vezes: `start()` retorna se `_running` ja estiver ativo (`app/lib/services/trader_service.dart:142-143`).
5. 🟢 Se a consulta de usuario LN Markets falhar no inicio, o bot registra erro e nao entra em running (`app/lib/services/trader_service.dart:152-159`).
6. 🟢 O ciclo principal roda imediatamente ao iniciar e depois a cada `checkInterval` minutos (`app/lib/services/trader_service.dart:170-175`).
7. 🟢 P&L nao realizado atualiza a cada 15 segundos e preco BTC a cada 30 segundos enquanto running (`app/lib/services/trader_service.dart:177-185`, `app/lib/services/trader_service.dart:459-482`).
8. 🟢 A estrategia usa o penultimo candle fechado para evitar ruido da vela atual (`app/lib/services/indicators.dart:67-73`).
9. 🟢 `long` e gerado quando EMA rapida > EMA lenta e preco nao esta abaixo da EMA sinal (`app/lib/services/indicators.dart:83-94`).
10. 🟢 `short` e gerado quando EMA rapida < EMA lenta e preco nao esta acima da EMA sinal (`app/lib/services/indicators.dart:83-94`).
11. 🟢 Entradas long exigem filtros BB e MACD positivos; se falharem, o bot aguarda (`app/lib/services/trader_service.dart:282-289`).
12. 🟢 Quando `longOnly=true`, sinal short nao abre short; se ha long aberto, o bot fecha a posicao sem reabrir (`app/lib/services/trader_service.dart:277-278`, `app/lib/services/trader_service.dart:332-347`).
13. 🟢 Uma posicao local e apagada quando seu ID nao aparece mais nas posicoes abertas da LN Markets (`app/lib/services/trader_service.dart:226-234`).
14. 🟢 Uma inversao fecha a posicao atual antes de abrir nova posicao na direcao oposta (`app/lib/services/trader_service.dart:303-329`).
15. 🟢 Compound Mode usa `round(balance * compoundingPct / 100)` como margem e limita entre 1000 sats e o saldo atual (`app/lib/services/trader_service.dart:365-371`).
16. 🟢 TP/SL sao calculados de forma espelhada para long e short e arredondados a 2 casas (`app/lib/services/trader_service.dart:387-402`, `app/lib/services/lnmarkets_api.dart:102-120`).
17. 🟢 Trailing stop so se aplica a long e apenas aumenta o stop loss quando o novo nivel e maior que o anterior (`app/lib/services/trader_service.dart:247-264`).
18. 🟢 O historico de logs em memoria e limitado a 500 entradas (`app/lib/services/log_service.dart:37-41`).
19. 🟢 Indicadores de mercado sao cacheados por ate 30 minutos (`app/lib/services/market_data_service.dart:28-35`).
20. 🟢 Configuracao remota de partners sobrescreve `live` e `signupUrl` por exchange id (`app/lib/screens/sponsors_tab.dart:48-65`).

## Decisoes implicitas do historico Git

- 🟢 `2caf73b` introduziu o app Android Flutter inicial com Trend Tabajara 3.0, multi-idioma, P&L, TP/SL e logs.
- 🟢 `d32fa3f` introduziu Long Only como toggle e comportamento explicito de fechar long em sinal short sem reabrir short.
- 🟢 `67c28ed` adicionou Trailing Stop, Compound Mode, Market Indicators, Partners tab e remote config.
- 🟡 Os commits indicam coautoria por Claude Sonnet; isso sugere geracao assistida por LLM, mas nao muda o comportamento extraido do codigo.

## Maquinas de estado relevantes

Ver tambem `_reversa_sdd/state-machines.md`.

## Permissoes

🟢 **CONFIRMADO** Nao ha RBAC/ACL de usuario no app. O acesso operacional depende de credenciais LN Markets preenchidas localmente.

## Lacunas

1. 🔴 O README promete armazenamento seguro de credenciais, mas o codigo usa `SharedPreferences`. Validar se isto e aceitavel ou se deve migrar para storage seguro.
2. 🔴 Nao ha testes automatizados reais para a estrategia, ciclo de trading, clientes HTTP ou persistencia.
3. 🟡 A raiz `lib/` parece snapshot legado usado por `setup.sh`, enquanto `app/lib/` e a aplicacao atual; nao ha politica documentada para manter ambas sincronizadas.
4. 🟡 Falhas em market data e remote config sao silenciosas; isso parece intencional para degradacao graciosa, mas nao ha requisito explicito.
