# Paradigm Decision

## Legado detectado

- Paradigma: Flutter/Dart orientado a objetos simples com `ChangeNotifier`, timers e services stateful.
- Confianca: CONFIRMADO.
- Evidencias: `_reversa_sdd/architecture.md`, `_reversa_sdd/code-analysis.md`, `app/lib/services/trader_service.dart`.

## Stack alvo inferida

- Paradigma natural: Flutter/Dart declarativo com dominio testavel, interfaces para bordas e adapters por plataforma.
- Alternativa viavel: SwiftUI nativo, rejeitada para esta etapa por maior custo e mudanca de stack.

## Gap

Gap medio. A linguagem permanece Dart, mas a topologia muda de services acoplados para dominio puro + adapters.

## Opcoes avaliadas

1. Adotar paradigma natural da stack: Flutter declarativo com dominio separado e adapters.
2. Forcar topologia similar ao legado: manter `services/` stateful e condicoes por plataforma.
3. Hibrido: preservar UI/tabs e regras confirmadas, mas mover dominio e plataforma para camadas novas.

## Decisao aprovada

Opcao 3, hibrido equilibrado.

Justificativa: reduz risco para o app de trading, preserva comportamento extraido e cria base testavel para Mac ARM.

`derived_appetite`: `balanced`

## Implicacoes para agentes posteriores

| Agente | Implicacao |
|---|---|
| Curator | Migrar regras confirmadas de trading, storage e integracoes; marcar lacunas financeiras para validacao. |
| Strategist | Usar rebuild paralelo e cutover por troca de entrypoint. |
| Designer | Projetar topologia modular em `app/lib/src` sem decomposicao 1-para-1. |
| Inspector | Cobrir paridade de dominio, idempotencia de start/stop e proibicao de trade real em testes. |
