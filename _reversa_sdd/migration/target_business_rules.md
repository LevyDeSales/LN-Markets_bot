# Target Business Rules

## MIGRAR

| ID | Regra alvo | Origem | Confianca |
|---|---|---|---|
| BR-MIGRAR-001 | Credenciais completas exigem key, secret e passphrase nao vazios. | `_reversa_sdd/domain.md` regra 1 | CONFIRMADO |
| BR-MIGRAR-002 | Mainnet usa `https://api.lnmarkets.com`; demais redes usam testnet4. | `_reversa_sdd/domain.md` regra 2 | CONFIRMADO |
| BR-MIGRAR-003 | Limite de candles e `emaSignal * 3`, clamp 150..500. | `_reversa_sdd/domain.md` regra 3 | CONFIRMADO |
| BR-MIGRAR-004 | Bot nao inicia duas vezes. | `_reversa_sdd/domain.md` regra 4 | CONFIRMADO |
| BR-MIGRAR-005 | Falha em `getUser` impede entrar em running. | `_reversa_sdd/domain.md` regra 5 | CONFIRMADO |
| BR-MIGRAR-006 | Ciclo roda imediatamente e depois a cada `checkInterval`. | `_reversa_sdd/domain.md` regra 6 | CONFIRMADO |
| BR-MIGRAR-007 | P&L e preco tem timers separados. | `_reversa_sdd/domain.md` regra 7 | CONFIRMADO |
| BR-MIGRAR-008 | Estrategia usa penultimo candle fechado. | `_reversa_sdd/domain.md` regra 8 | CONFIRMADO |
| BR-MIGRAR-009 | Long/short seguem EMA rapida vs lenta e filtro EMA sinal. | `_reversa_sdd/domain.md` regras 9-10 | CONFIRMADO |
| BR-MIGRAR-010 | Entrada long exige BB e MACD positivos. | `_reversa_sdd/domain.md` regra 11 | CONFIRMADO |
| BR-MIGRAR-011 | Long-only fecha long em sinal short e nao abre short. | `_reversa_sdd/domain.md` regra 12 | CONFIRMADO |
| BR-MIGRAR-012 | Posicao local e apagada se nao existir remotamente. | `_reversa_sdd/domain.md` regra 13 | CONFIRMADO |
| BR-MIGRAR-013 | Inversao fecha posicao atual antes de abrir oposta. | `_reversa_sdd/domain.md` regra 14 | CONFIRMADO |
| BR-MIGRAR-014 | Compounding calcula margem por percentual do saldo, clamp 1000..balance. | `_reversa_sdd/domain.md` regra 15 | CONFIRMADO |
| BR-MIGRAR-015 | TP/SL espelhados para long e short e arredondados a 2 casas. | `_reversa_sdd/domain.md` regra 16 | CONFIRMADO |
| BR-MIGRAR-016 | Trailing stop se aplica a long e so aumenta o stop. | `_reversa_sdd/domain.md` regra 17 | CONFIRMADO |
| BR-MIGRAR-017 | Logs em memoria limitados a 500 entradas. | `_reversa_sdd/domain.md` regra 18 | CONFIRMADO |
| BR-MIGRAR-018 | Market indicators cacheiam por ate 30 minutos. | `_reversa_sdd/domain.md` regra 19 | CONFIRMADO |
| BR-MIGRAR-019 | Remote config sobrescreve partners por exchange id. | `_reversa_sdd/domain.md` regra 20 | CONFIRMADO |

## DESCARTAR

| ID | Regra descartada | Motivo |
|---|---|---|
| BR-DESCARTAR-001 | Dependencia direta de `flutter_foreground_task` no fluxo macOS. | Artefato de plataforma Android/iOS; substituido por adapter macOS sem foreground service. |
| BR-DESCARTAR-002 | Duplicacao obrigatoria entre `lib/` raiz e `app/lib/`. | Artefato de seed/setup legado; app principal e `app/`. |

## DECISAO HUMANA

| ID | Ponto | Recomendacao |
|---|---|---|
| BR-HUMANA-001 | Uso futuro de credenciais reais e mainnet. | Levy decide fora da automacao; testes usam fakes ou testnet manual. |
| BR-HUMANA-002 | Publicacao/notarizacao/App Store. | Fora do escopo Mac local. |
