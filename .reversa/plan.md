# Plano Reversa — LN Markets Bot

## Fase 1 — Reconhecimento
- [x] ✅ **Scout** — Mapear estrutura, linguagens, dependencias, entry points, testes, integracoes e sugestao de organizacao das specs.

## Fase 2 — Escavacao
- [x] ✅ **Archaeologist** — Analise do modulo `app-shell-ui`
- [x] ✅ **Archaeologist** — Analise do modulo `settings-persistence`
- [x] ✅ **Archaeologist** — Analise do modulo `trading-engine`
- [x] ✅ **Archaeologist** — Analise do modulo `indicators-strategy`
- [x] ✅ **Archaeologist** — Analise do modulo `external-apis-market-data`
- [x] ✅ **Archaeologist** — Analise do modulo `background-service`
- [x] ✅ **Archaeologist** — Analise do modulo `sponsors-remote-config`
- [x] ✅ **Archaeologist** — Analise do modulo `logging-dashboard`

## Fase 3 — Interpretacao
- [x] ✅ **Detective** — Extrair regras de negocio, decisoes implicitas, estados, permissoes e lacunas.
- [x] ✅ **Architect** — Sintetizar arquitetura, C4 contexto, integracoes, dados e dividas tecnicas.

## Fase 4 — Geracao
- [x] ✅ **Writer** — Gerar specs executaveis por unidade conforme a organizacao escolhida.

## Fase 5 — Revisao
- [x] ✅ **Reviewer** — Revisar consistencia, confianca, lacunas e perguntas de validacao.
- [x] ✅ **Regression Check** — Verificar regressao semantica se houver `_reversa_forward/*/regression-watch.md`.

## Politica de gates
- Defaults pre-aprovados por Levy: plano inicial, inicio do Scout, nivel `essencial`, aceitar sugestao do Scout para organizacao e continuar checkpoints rotineiros.
- Gates nao cobertos: chamar subagente gatekeeper em modo somente leitura. Continuar apenas com `APPROVE`; parar se houver `REJECT`.
