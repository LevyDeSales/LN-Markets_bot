# Design System — LN Markets Bot

## Resumo

O design atual e um tema Flutter escuro com acento Bitcoin orange. A UI principal e operacional: dashboard, settings, logs, sponsors e about.

## Componentes detectados

| Componente | Padrao visual | Origem |
|---|---|---|
| App shell | Tema escuro, sidebar em desktop, bottom nav em mobile | `home_screen.dart` |
| Card operacional | Fundo `color.card`, estados long/short dedicados | `dashboard_tab.dart`, `app_theme.dart` |
| Form field | Fundo card, borda divider, foco orange | `app_theme.dart`, `settings_tab.dart` |
| Botao primario | Fundo orange, texto preto, peso bold | `app_theme.dart` |
| Log stream | Texto de eventos em ordem temporal | `logs_tab.dart` |

## Decisao para migracao

Preservar identidade visual e modernizar ergonomia desktop. O modo de tela recomendado para a migracao e `modernizado`, mantendo textos e regras de navegacao do legado.
