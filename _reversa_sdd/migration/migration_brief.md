# Migration Brief — LN Markets Bot para Mac ARM

Gerado em: 2026-06-05

## Objetivo

Reescrever/refatorar o LN Markets Bot para funcionar localmente no Mac ARM do Levy, usando Flutter/Dart como stack alvo e preservando as regras de trading extraidas pelo Reversa.

## Metricas de sucesso

- `flutter doctor -v` sem bloqueios de macOS desktop apos bootstrap do toolchain.
- `flutter pub get` executa em `app/`.
- `flutter analyze` sem erros bloqueantes.
- `flutter test` cobre dominio, indicadores, storage e clients com fakes.
- `flutter run -d macos` abre o app localmente.
- `flutter build macos --debug` gera build local.

## Restricoes

- Nao usar sudo automaticamente.
- Nao aceitar licenca Xcode em nome do usuario.
- Nao usar credenciais reais durante validacao.
- Nao executar ordens reais ou mainnet em smoke tests.
- Escopo inicial e Mac funcional; outras plataformas ficam como compatibilidade secundaria.

## Riscos conhecidos

- `flutter` e `dart` nao estao no PATH atual.
- `xcodebuild` aponta para Command Line Tools, nao Xcode completo.
- `flutter_foreground_task` e orientado a Android/iOS e nao resolve runtime persistente no macOS.
- Credenciais estao em `SharedPreferences` no legado.
- Nao ha testes comportamentais reais no app atual.

## Stakeholders

- Levy: usuario e aprovador de decisoes financeiras, credenciais, sudo/senha, publicacao e mudanca de stack.
- Gatekeeper Reversa: aprovador delegado de gates tecnicos rotineiros.

## Stack alvo

- Linguagem: Dart.
- Framework: Flutter desktop macOS.
- Runtime alvo: Mac ARM local.
- Persistencia: `shared_preferences` para preferencias nao sensiveis; `flutter_secure_storage` para credenciais.
- Infra: app local client-side, sem backend proprio.
- Observabilidade: logs locais em memoria e painel de logs.

## Escopo

Incluido:
- Dashboard, settings, logs, sponsors, about.
- Motor Trend Tabajara 3.0.
- LN Markets API, Binance API, market indicators, remote config.
- Persistencia local de settings e posicao.
- Runtime explicito enquanto app macOS esta aberto.

Excluido nesta etapa:
- Publicacao App Store.
- Execucao de trade real.
- Reescrita SwiftUI.
- Garantia de paridade total Android/iOS/Linux/Web/Windows.
