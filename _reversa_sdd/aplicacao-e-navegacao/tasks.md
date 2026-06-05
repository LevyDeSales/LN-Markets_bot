# Tasks — Aplicacao e Navegacao

## Implementacao equivalente

| ID | Tarefa | Origem legado | Pronto quando | Confianca |
|---|---|---|---|---|
| T-APP-01 | Criar bootstrap Flutter com inicializacao async e portrait. | `app/lib/main.dart:14-17` | `main()` inicializa binding e orientacao antes de servicos. | 🟢 |
| T-APP-02 | Inicializar foreground, settings, idioma, logs, trader e config remota. | `app/lib/main.dart:18-35` | App roda com os servicos injetados em `LNMarketsApp`. | 🟢 |
| T-APP-03 | Implementar Splash -> Home por callback `onDone`. | `app/lib/main.dart:54-71` | Home aparece apenas apos splash concluir. | 🟢 |
| T-APP-04 | Implementar HomeScreen com tabs Dashboard/Settings/Logs/Sponsors/About. | `app/lib/screens/home_screen.dart:48-58` | Todas as tabs existem e recebem dependencias corretas. | 🟢 |
| T-APP-05 | Implementar redirecionamento inicial para Settings quando nao ha credenciais. | `app/lib/screens/home_screen.dart:37-43` | Usuario sem credenciais cai na aba Settings. | 🟢 |
| T-APP-06 | Implementar layout mobile com bottom navigation e desktop com sidebar. | `app/lib/screens/home_screen.dart:60-132` | Breakpoint 600px troca o layout sem perder estado das tabs. | 🟢 |

## Testes sugeridos

- Criar teste de widget para `HomeScreen` sem credenciais e validar aba Settings ativa.
- Criar teste de layout com constraints abaixo/acima de 600px.
- Criar teste de bootstrap com mocks de settings/log/trader para validar transicao Splash -> Home.
