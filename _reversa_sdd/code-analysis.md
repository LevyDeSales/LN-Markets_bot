# Analise de Codigo — LN Markets Bot

Gerado em: 2026-06-05T04:54:42Z

Escala de confianca: 🟢 **CONFIRMADO** — extraido diretamente do codigo; 🟡 **INFERIDO** — baseado em padroes; 🔴 **LACUNA** — requer validacao humana.

## Visao geral

🟢 **CONFIRMADO** O projeto contem um app Flutter principal em `app/`, versao `3.3.0+6`, e uma copia/seed legado na raiz (`lib/`, `pubspec.yaml`, `setup.sh`). O bootstrap atual esta em `app/lib/main.dart:14-35`.

🟢 **CONFIRMADO** O produto e um bot de trading para Bitcoin futures que conecta LN Markets, coleta candles/preco da Binance, calcula sinais Trend Tabajara 3.0 e opera posicoes com TP/SL, trailing stop, modo long-only e compounding. Evidencias principais: `app/lib/services/trader_service.dart:142-490`, `app/lib/services/indicators.dart:49-114`, `app/lib/services/lnmarkets_api.dart:75-120`.

🟢 **CONFIRMADO** Nao ha banco relacional, migrations, ORM ou schema persistente. O estado local usa `SharedPreferences` para configuracoes, posicao aberta e cache remoto (`app/lib/services/settings_service.dart:36-79`, `app/lib/services/trader_service.dart:119-137`, `app/lib/services/remote_config_service.dart:41-59`).

## Modulo `app-shell-ui`

### Proposito

🟢 **CONFIRMADO** Inicializa o app Flutter, carrega configuracoes, aplica idioma, cria servicos compartilhados e alterna entre splash e tela principal (`app/lib/main.dart:14-35`, `app/lib/main.dart:54-72`).

### Arquivos primarios

- `app/lib/main.dart`
- `app/lib/screens/home_screen.dart`
- `app/lib/screens/splash_screen.dart`
- `app/lib/app_theme.dart`
- `app/lib/i18n.dart`

### Fluxo de controle

🟢 **CONFIRMADO** `main()` garante inicializacao Flutter, fixa orientacao portrait, inicializa foreground service, carrega `SettingsService`, aplica idioma, instancia `LogService` e `TraderService`, inicia config remota em modo fire-and-forget e chama `runApp` (`app/lib/main.dart:14-35`).

🟢 **CONFIRMADO** `LNMarketsApp` mostra `SplashScreen` ate `_splashDone=true`; depois injeta settings/trader/log em `HomeScreen` (`app/lib/main.dart:54-71`).

🟢 **CONFIRMADO** `HomeScreen` redireciona para Settings quando nao ha credenciais, busca preco uma vez e pede ignorar otimizacao de bateria depois de 2 segundos (`app/lib/screens/home_screen.dart:37-43`).

🟢 **CONFIRMADO** Layout muda em `600px`: mobile usa bottom navigation; desktop usa sidebar fixa e `IndexedStack` (`app/lib/screens/home_screen.dart:34-67`, `app/lib/screens/home_screen.dart:72-132`).

### Estruturas de dados

| Entidade | Campos | Confianca |
|---|---|---|
| `LNMarketsApp` | `settings`, `traderService`, `logService` | 🟢 |
| `_HomeScreenState` | `_tab`, `_desktopBreak`, `_pages` derivado | 🟢 |

## Modulo `settings-persistence`

### Proposito

🟢 **CONFIRMADO** Centraliza credenciais LN Markets, parametros de rede/trading/risco/idioma e persistencia local (`app/lib/services/settings_service.dart:3-80`).

### Arquivos primarios

- `app/lib/services/settings_service.dart`
- `app/lib/screens/settings_tab.dart`

### Fluxo e regras

🟢 **CONFIRMADO** Credenciais validas exigem `apiKey`, `apiSecret` e `apiPassphrase` nao vazios (`app/lib/services/settings_service.dart:27-28`).

🟢 **CONFIRMADO** `baseUrl` escolhe `https://api.lnmarkets.com` em `mainnet`; caso contrario usa `https://api.testnet4.lnmarkets.com` (`app/lib/services/settings_service.dart:30-32`).

🟢 **CONFIRMADO** `candlesLimit` usa `emaSignal * 3` limitado entre 150 e 500 (`app/lib/services/settings_service.dart:34`).

🟢 **CONFIRMADO** `load()` le chaves `api_key`, `api_secret`, `api_passphrase`, `network`, `timeframe`, `leverage`, `margin_sats`, `check_interval`, EMAs, TP/SL, trailing, compounding, long-only e idioma (`app/lib/services/settings_service.dart:36-57`).

🟢 **CONFIRMADO** `save()` grava os mesmos campos em `SharedPreferences` (`app/lib/services/settings_service.dart:59-79`).

🟢 **CONFIRMADO** Na UI, `_save()` bloqueia salvamento sem credenciais e aplica parsing com defaults numericos quando inputs sao invalidos (`app/lib/screens/settings_tab.dart:79-112`).

### Dicionario de dados resumido

| Campo | Tipo | Default observado | Persistencia | Confianca |
|---|---|---:|---|---|
| `apiKey` | `String` | `''` | `api_key` | 🟢 |
| `apiSecret` | `String` | `''` | `api_secret` | 🟢 |
| `apiPassphrase` | `String` | `''` | `api_passphrase` | 🟢 |
| `network` | `String` | `mainnet` | `network` | 🟢 |
| `timeframe` | `String` | classe `1d`, load `15m` | `timeframe` | 🟢 |
| `longOnly` | `bool` | `true` | `long_only` | 🟢 |
| `leverage` | `int` | `5` | `leverage` | 🟢 |
| `marginSats` | `int` | `50000` | `margin_sats` | 🟢 |
| `checkInterval` | `int` | `5` | `check_interval` | 🟢 |
| `emaFast` | `int` | `9` | `ema_fast` | 🟢 |
| `emaSlow` | `int` | `21` | `ema_slow` | 🟢 |
| `emaSignal` | `int` | `50` | `ema_signal` | 🟢 |
| `takeProfitPct` | `double` | `0.0` | `take_profit_pct` | 🟢 |
| `stopLossPct` | `double` | `0.0` | `stop_loss_pct` | 🟢 |
| `useTrailingStop` | `bool` | `true` | `use_trailing_stop` | 🟢 |
| `trailingStopPct` | `double` | `1.0` | `trailing_stop_pct` | 🟢 |
| `useCompounding` | `bool` | `true` | `use_compounding` | 🟢 |
| `compoundingPct` | `double` | `10.0` | `compounding_pct` | 🟢 |
| `language` | `String` | `pt_BR` | `language` | 🟢 |

🔴 **LACUNA** O README afirma armazenamento seguro de credenciais, mas o codigo observado usa `SharedPreferences`, nao um storage criptografado. Requer validacao se isto e aceitavel para o produto.

## Modulo `trading-engine`

### Proposito

🟢 **CONFIRMADO** Orquestra o ciclo do bot: conecta LN Markets, coleta candles/preco, calcula tendencia, sincroniza posicao aberta, abre/fecha posicoes, aplica TP/SL/trailing e atualiza P&L (`app/lib/services/trader_service.dart:82-490`).

### Arquivos primarios

- `app/lib/services/trader_service.dart`
- `app/lib/services/lnmarkets_api.dart`
- `app/lib/services/binance_api.dart`
- `app/lib/services/indicators.dart`
- `app/lib/services/settings_service.dart`
- `app/lib/services/log_service.dart`

### Fluxo de controle

🟢 **CONFIRMADO** `start()` e idempotente se `_running=true`; caso contrario cria instancias de APIs/indicadores, zera estatisticas, carrega posicao persistida, consulta usuario LN Markets e aborta se falhar (`app/lib/services/trader_service.dart:142-159`).

🟢 **CONFIRMADO** Ao iniciar com sucesso, marca `_running`, inicia foreground service, executa um ciclo imediato e agenda tres timers: ciclo principal por `settings.checkInterval` minutos, P&L a cada 15s e preco a cada 30s (`app/lib/services/trader_service.dart:161-185`).

🟢 **CONFIRMADO** `stop()` cancela timers, zera P&L nao realizado, loga encerramento, notifica listeners e para foreground service (`app/lib/services/trader_service.dart:188-197`).

🟢 **CONFIRMADO** `_runCycle()` busca candles Binance e calcula `TrendResult`; se falhar, loga erro e encerra o ciclo atual (`app/lib/services/trader_service.dart:201-224`).

🟢 **CONFIRMADO** O ciclo sincroniza posicoes abertas da LN Markets; se havia posicao local e o ID nao existe mais remotamente, limpa estado local. Atualiza P&L nao realizado usando `open[0]['pl']` quando ha posicao remota (`app/lib/services/trader_service.dart:226-245`).

🟢 **CONFIRMADO** Trailing stop so atualiza posicoes long quando `useTrailingStop=true`; o novo SL e `price * (1 - trailingStopPct / 100)` e so sobe quando maior que o trailing atual (`app/lib/services/trader_service.dart:247-264`).

🟢 **CONFIRMADO** Em modo long-only, sinais `short` viram neutros antes de abrir posicao (`app/lib/services/trader_service.dart:277-278`).

🟢 **CONFIRMADO** Sem posicao, o bot abre somente se houver `effectiveSignal`; entradas long sao bloqueadas se BB ou MACD falharem (`app/lib/services/trader_service.dart:280-300`).

🟢 **CONFIRMADO** Com posicao e sinal oposto efetivo, o bot fecha a posicao, soma P&L realizado, limpa estado local e abre a nova direcao se filtros permitirem (`app/lib/services/trader_service.dart:303-329`).

🟢 **CONFIRMADO** Em long-only, um sinal short enquanto ha long aberto fecha o long sem reabrir short (`app/lib/services/trader_service.dart:332-347`).

🟢 **CONFIRMADO** `_openNew()` converte `long` para `buy` e `short` para `sell`, calcula margem composta quando habilitada, abre ordem LN Markets, contabiliza trades, deriva entry, calcula TP/SL locais, persiste `PositionState` e aplica trailing/TP/SL remoto quando ha ID (`app/lib/services/trader_service.dart:361-455`).

### Dicionario de dados resumido

| Entidade | Campo | Tipo | Regra | Confianca |
|---|---|---|---|---|
| `SessionStats` | `totalTrades` | `int` | incrementa ao abrir nova posicao | 🟢 |
| `SessionStats` | `longTrades` | `int` | incrementa quando signal `long` | 🟢 |
| `SessionStats` | `shortTrades` | `int` | incrementa quando signal `short` | 🟢 |
| `SessionStats` | `netPnlSats` | `int` | soma P&L realizado em fechamento | 🟢 |
| `SessionStats` | `unrealizedPnl` | `int` | vem de posicao remota `pl` | 🟢 |
| `SessionStats` | `totalPnl` | getter | `netPnlSats + unrealizedPnl` | 🟢 |
| `PositionState` | `id` | `String?` | existencia define `hasPosition` | 🟢 |
| `PositionState` | `side` | `String?` | `long` ou `short` no estado local | 🟢 |
| `PositionState` | `entryPrice` | `double?` | API ou preco atual fallback | 🟢 |
| `PositionState` | `tpPrice` | `double?` | calculado localmente se TP > 0 | 🟢 |
| `PositionState` | `slPrice` | `double?` | calculado localmente se SL > 0/trailing | 🟢 |
| `PositionState` | `trailSlPrice` | `double?` | nivel corrente do trailing stop | 🟢 |
| `PositionState` | `openedAt` | `DateTime?` | `DateTime.now()` ao abrir | 🟢 |

### Algoritmos e formulas

🟢 **CONFIRMADO** Margem composta: `round(balance * compoundingPct / 100)`, limitada entre `1000` sats e `balance` (`app/lib/services/trader_service.dart:365-371`).

🟢 **CONFIRMADO** TP long: `entry * (1 + tp / 100)`; TP short: `entry * (1 - tp / 100)` (`app/lib/services/trader_service.dart:393-397`, `app/lib/services/lnmarkets_api.dart:108-113`).

🟢 **CONFIRMADO** SL long: `entry * (1 - sl / 100)`; SL short: `entry * (1 + sl / 100)` (`app/lib/services/trader_service.dart:398-402`, `app/lib/services/lnmarkets_api.dart:114-119`).

🟢 **CONFIRMADO** Trailing inicial long: `entry * (1 - trailingStopPct / 100)`; trailing subsequente long: `price * (1 - trailingStopPct / 100)` e apenas se subir (`app/lib/services/trader_service.dart:247-264`, `app/lib/services/trader_service.dart:417-431`).

## Modulo `indicators-strategy`

### Proposito

🟢 **CONFIRMADO** Calcula indicadores tecnicos e sinal de tendencia usados pelo trading engine (`app/lib/services/indicators.dart:27-115`).

### Fluxo e regras

🟢 **CONFIRMADO** `_ema()` usa fator padrao `2/(period+1)` e inicia a serie com o primeiro valor de entrada (`app/lib/services/indicators.dart:31-39`).

🟢 **CONFIRMADO** `_bbMiddle()` calcula SMA de ate 20 fechamentos ate o indice informado (`app/lib/services/indicators.dart:41-46`).

🟢 **CONFIRMADO** `compute()` exige `candles.length >= emaSignal + 2`; caso contrario lanca excecao (`app/lib/services/indicators.dart:49-53`).

🟢 **CONFIRMADO** O calculo usa o penultimo candle fechado (`idx = candles.length - 2`) para reduzir ruido da vela ainda aberta (`app/lib/services/indicators.dart:67-73`).

🟢 **CONFIRMADO** Cruzamento `golden`: EMA rapida anterior <= lenta anterior e rapida atual > lenta atual. Cruzamento `death`: EMA rapida anterior >= lenta anterior e rapida atual < lenta atual (`app/lib/services/indicators.dart:75-81`).

🟢 **CONFIRMADO** Tendencia `long` quando EMA rapida > lenta; `short` quando EMA rapida < lenta (`app/lib/services/indicators.dart:83-89`).

🟢 **CONFIRMADO** Confirmacao por EMA de sinal: long invalido se preco < EMA sinal; short invalido se preco > EMA sinal (`app/lib/services/indicators.dart:91-94`).

🟢 **CONFIRMADO** Filtros adicionais: `bbFilter = price > BB middle`; `macdFilter = MACD(12,26) > signal(9)` (`app/lib/services/indicators.dart:96-101`).

### Dicionario de dados resumido

| Entidade | Campo | Tipo | Confianca |
|---|---|---|---|
| `TrendResult` | `signal` | `String?` (`long`, `short`, null) | 🟢 |
| `TrendResult` | `cross` | `String?` (`golden`, `death`, null) | 🟢 |
| `TrendResult` | `confirmed` | `bool` | 🟢 |
| `TrendResult` | `emaFast`, `emaSlow`, `emaSignal`, `price` | `double` arredondado 2 casas | 🟢 |
| `TrendResult` | `bbFilter`, `macdFilter` | `bool` | 🟢 |
| `Candle` | `open`, `high`, `low`, `close`, `volume` | `double` | 🟢 |

## Modulo `external-apis-market-data`

### Proposito

🟢 **CONFIRMADO** Encapsula comunicacao com LN Markets, Binance e APIs publicas de indicadores de mercado.

### Arquivos primarios

- `app/lib/services/lnmarkets_api.dart`
- `app/lib/services/binance_api.dart`
- `app/lib/services/market_data_service.dart`
- `app/lib/services/settings_service.dart`

### LN Markets

🟢 **CONFIRMADO** Assinatura HMAC-SHA256 usa mensagem `timestamp + method.toLowerCase() + path + params`, chave `apiSecret` e resultado base64 (`app/lib/services/lnmarkets_api.dart:12-19`).

🟢 **CONFIRMADO** Headers autenticados: `LNM-ACCESS-KEY`, `LNM-ACCESS-PASSPHRASE`, `LNM-ACCESS-SIGNATURE`, `LNM-ACCESS-TIMESTAMP` (`app/lib/services/lnmarkets_api.dart:21-31`).

🟢 **CONFIRMADO** GET e POST aplicam timeout de 15s e `_parse()` lanca excecao para status fora de 2xx (`app/lib/services/lnmarkets_api.dart:35-70`).

🟢 **CONFIRMADO** Endpoints usados: conta, posicoes abertas, abrir trade isolado, fechar trade, set take profit e set stop loss (`app/lib/services/lnmarkets_api.dart:75-120`).

### Binance

🟢 **CONFIRMADO** `fetchCandles()` consulta `/api/v3/klines` com `symbol=BTCUSDT`, `interval` e `limit`, timeout 10s, status diferente de 200 vira excecao (`app/lib/services/binance_api.dart:9-29`).

🟢 **CONFIRMADO** `fetchPrice()` consulta `/api/v3/ticker/price?symbol=BTCUSDT`, timeout 5s, status diferente de 200 retorna `0` (`app/lib/services/binance_api.dart:32-39`).

### Market data

🟢 **CONFIRMADO** `MarketDataService.fetch()` usa cache em memoria por 30 minutos (`app/lib/services/market_data_service.dart:22-35`).

🟢 **CONFIRMADO** Busca Fear & Greed em Alternative.me, hashrate em mempool.space e dominancia BTC em CoinGecko, todos com timeout 10s e falhas silenciosas (`app/lib/services/market_data_service.dart:42-78`).

### Dicionario de dados resumido

| Entidade | Campo | Tipo | Confianca |
|---|---|---|---|
| `MarketData` | `fearGreedValue` | `int?` 0-100 | 🟢 |
| `MarketData` | `fearGreedLabel` | `String?` | 🟢 |
| `MarketData` | `hashrateEh` | `double?` em EH/s | 🟢 |
| `MarketData` | `btcDominance` | `double?` percentual | 🟢 |
| `MarketData` | `fetchedAt` | `DateTime` | 🟢 |

## Modulo `background-service`

### Proposito

🟢 **CONFIRMADO** Configura e controla `flutter_foreground_task` para manter o app ativo em background enquanto o bot roda.

### Fluxo e regras

🟢 **CONFIRMADO** `botForegroundEntryPoint()` e top-level e anotado `@pragma('vm:entry-point')`, registrando `_BotTaskHandler` (`app/lib/services/foreground_service.dart:3-7`).

🟢 **CONFIRMADO** `_BotTaskHandler` nao executa trading; o comentario indica que a logica real permanece nos timers do `TraderService` na isolate principal (`app/lib/services/foreground_service.dart:13-17`).

🟢 **CONFIRMADO** `init()` e idempotente e configura canal Android `lnmarkets_bot_channel`, notificacao iOS, wake lock permitido, autoRunOnBoot false e wifi lock false (`app/lib/services/foreground_service.dart:23-48`).

🟢 **CONFIRMADO** `start()`, `update()`, `stop()` e `requestBatteryOptimization()` capturam excecoes e degradam silenciosamente (`app/lib/services/foreground_service.dart:50-90`).

## Modulo `sponsors-remote-config`

### Proposito

🟢 **CONFIRMADO** Mantem registry local de exchanges patrocinadoras, busca configuracao remota para sobrescrever status/link e exibe cards com CTA externo.

### Arquivos primarios

- `app/lib/services/sponsor_service.dart`
- `app/lib/services/remote_config_service.dart`
- `app/lib/screens/sponsors_tab.dart`
- `app/lib/widgets/sponsor_banner.dart`

### Fluxo e regras

🟢 **CONFIRMADO** `RemoteConfigService.init()` carrega cache local e dispara fetch remoto sem aguardar (`app/lib/services/remote_config_service.dart:34-39`).

🟢 **CONFIRMADO** Config remota vem de `https://bitfood.app/bot-config.json`, e resposta 200 e salva em `SharedPreferences` como `remote_bot_config` (`app/lib/services/remote_config_service.dart:5-8`, `app/lib/services/remote_config_service.dart:49-59`).

🟢 **CONFIRMADO** Parser remoto espera `exchanges` como lista de objetos com `id`, `live` e `signupUrl` (`app/lib/services/remote_config_service.dart:10-25`, `app/lib/services/remote_config_service.dart:63-69`).

🟢 **CONFIRMADO** `SponsorsTab` mescla registry local com remote config por `id`; `signupUrl` remoto substitui local quando nao vazio, e `live` remoto controla status do card (`app/lib/screens/sponsors_tab.dart:48-65`).

### Dicionario de dados resumido

| Entidade | Campo | Tipo | Confianca |
|---|---|---|---|
| `Exchange` | `id`, `name`, `tagline`, `signupUrl`, `live` | strings/bool | 🟢 |
| `RemoteExchange` | `id`, `live`, `signupUrl` | strings/bool | 🟢 |

## Modulo `logging-dashboard`

### Proposito

🟢 **CONFIRMADO** Exibe estado operacional do bot, tendencia, posicao, estatisticas, P&L, indicadores de mercado e logs.

### Arquivos primarios

- `app/lib/screens/dashboard_tab.dart`
- `app/lib/screens/logs_tab.dart`
- `app/lib/services/log_service.dart`
- `app/lib/services/market_data_service.dart`

### Fluxo e regras

🟢 **CONFIRMADO** `DashboardTab` usa `AnimatedBuilder` sobre `TraderService`, entao cada `notifyListeners()` atualiza a tela (`app/lib/screens/dashboard_tab.dart:8-18`).

🟢 **CONFIRMADO** O dashboard renderiza status, preco BTC, saldo, tendencia, posicao, estatisticas e indicadores de mercado (`app/lib/screens/dashboard_tab.dart:20-80`).

🟢 **CONFIRMADO** O bot e iniciado/parado pelo botao da `_StatusBar`, chamando `traderService.start()` ou `traderService.stop()` (`app/lib/screens/dashboard_tab.dart:164-184`).

🟢 **CONFIRMADO** `_PositionCard` mostra side, entry, TP, SL e data de abertura quando ha posicao (`app/lib/screens/dashboard_tab.dart:284-341`).

🟢 **CONFIRMADO** `_StatsCard` mostra total de trades, longs, shorts, runtime, P&L realizado, P&L aberto e P&L total (`app/lib/screens/dashboard_tab.dart:344-431`).

🟢 **CONFIRMADO** `_MarketIndicatorsCard` busca indicadores ao iniciar e a cada 30 minutos (`app/lib/screens/dashboard_tab.dart:433-460`).

🟢 **CONFIRMADO** `LogService` mantem historico maximo de 500 entradas e publica stream broadcast (`app/lib/services/log_service.dart:31-50`).

### Dicionario de dados resumido

| Entidade | Campo | Tipo | Regra | Confianca |
|---|---|---|---|---|
| `LogEntry` | `time` | `DateTime` | criado no construtor | 🟢 |
| `LogEntry` | `level` | `LogLevel` | info/warning/error/debug | 🟢 |
| `LogEntry` | `message` | `String` | mensagem textual | 🟢 |
| `LogService.history` | lista | `List<LogEntry>` | maximo 500 entradas | 🟢 |

## Lacunas principais para proximas fases

🔴 **LACUNA** O codigo nao evidencia criptografia/secure storage para credenciais, apesar da promessa no README.

🔴 **LACUNA** Nao ha testes funcionais cobrindo estrategia, API client, persistencia ou trading engine.

🟡 **INFERIDO** A pasta `lib/` na raiz parece ser copia anterior usada por `setup.sh`; a aplicacao atual deve ser `app/`, mas nao ha documento explicito declarando a politica de sincronizacao entre as duas arvores.
