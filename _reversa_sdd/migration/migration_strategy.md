# Migration Strategy

## Estrategia escolhida

Rebuild paralelo com cutover por entrypoint.

## Alternativas avaliadas

| Estrategia | Adequacao | Motivo |
|---|---|---|
| Rebuild paralelo | Alta | Permite criar `app/lib/src` testavel sem quebrar o app legado ate o cutover. |
| Big Bang direto | Media | Menos arquivos temporarios, mas arriscado por falta de testes legados. |
| Strangler Fig | Baixa | Nao ha backend ou fronteira remota para estrangular incrementalmente. |

## Passos

1. Criar specs de migracao e paridade.
2. Adicionar nova topologia em `app/lib/src`.
3. Implementar dominio puro e testes.
4. Implementar adapters para storage, APIs e runtime.
5. Integrar UI existente com facades novas.
6. Trocar `app/lib/main.dart` para nova arvore somente depois de testes.
7. Rodar smoke macOS local.

## Criterio de conclusao

App abre no macOS ARM local, permite configurar credenciais em storage seguro, calcula sinais com testes e nao executa trade real nos testes automatizados.
