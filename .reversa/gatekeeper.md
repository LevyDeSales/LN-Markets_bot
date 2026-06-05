# Politica do Gatekeeper Reversa

## Objetivo
Avaliar gates nao cobertos pelos defaults aprovados por Levy sem bloquear falsamente o fluxo normal do Reversa.

## Estado conhecido desta execucao
Os seguintes caminhos foram criados pelo orquestrador nesta sessao e NAO devem ser tratados como estado anterior ambiguo:

- `.reversa/version`
- `.reversa/state.json`
- `.reversa/config.toml`
- `.reversa/plan.md`
- `.reversa/gatekeeper.md`
- `.reversa/context/`
- `_reversa_sdd/`

Enquanto esses arquivos forem consistentes com o plano atual e nao houver checkpoints ou artefatos contraditorios, a existencia de `.reversa/` e `_reversa_sdd/` deve ser tratada como estado corrente conhecido.

## Defaults ja aprovados por Levy
- Aprovar o plano inicial.
- Iniciar o Scout.
- Escolher `doc_level = "essencial"` apos o Scout.
- Aceitar a sugestao do Scout para organizacao das specs.
- Continuar checkpoints rotineiros.

## Quando aprovar
Responder `APPROVE: <motivo curto>` quando:

- A escrita proposta esta restrita a `.reversa/` e/ou `_reversa_sdd/`.
- O estado existente corresponde aos arquivos conhecidos desta execucao.
- Nao ha migracao em andamento.
- Nao ha estrutura de specs materializada que conflite com a decisao atual.
- Nao ha erro de IO ou risco de sobrescrever codigo legado.

## Quando reprovar
Responder `REJECT: <motivo curto>` quando:

- Houver risco de apagar, mover ou sobrescrever arquivos do projeto legado.
- Houver estado Reversa previo nao criado nesta execucao ou inconsistente com `.reversa/state.json`.
- Existir `<output_folder>/migration/.state.json` em andamento.
- A escolha de organizacao conflitar com specs ja materializadas.
- O gate depender de decisao humana de negocio nao coberta pelos defaults.
- Houver erro de IO, permissao ou leitura incompleta de arquivos obrigatorios.
