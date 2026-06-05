# Cutover Plan

## Pre-requisitos

- Toolchain Flutter/macOS validado.
- Dominio e adapters cobertos por testes.
- `flutter analyze` sem erros bloqueantes.
- Smoke local sem credenciais reais ou usando testnet manual.

## Sequencia

1. Manter codigo legado em `app/lib/services` e `app/lib/screens`.
2. Criar nova implementacao em `app/lib/src`.
3. Integrar telas atuais com facades novas.
4. Trocar `app/lib/main.dart` para a arvore nova.
5. Rodar `flutter test`.
6. Rodar `flutter analyze`.
7. Rodar `flutter run -d macos`.

## Rollback

- Reverter `app/lib/main.dart` para entrypoint legado.
- Manter `app/lib/src` em disco para diagnostico.
- Nao deletar `app/lib/services` nem `lib/` raiz nesta etapa.

## Go/No-Go

Go:
- app abre no macOS;
- settings salvam e carregam;
- dashboard/logs funcionam com fakes ou testnet manual;
- nenhum teste faz ordem real.

No-Go:
- erro em storage de credenciais;
- trade real nao simulado em teste;
- build exige senha/sudo sem intervencao do Levy.
