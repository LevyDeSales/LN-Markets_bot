# Screen Modernization Decision

## Plataforma origem

Flutter app com Material widgets.

## Plataforma alvo

Flutter macOS desktop.

## Telas inventariadas

- Splash
- Home shell
- Dashboard
- Settings
- Logs
- Sponsors
- About

## Modos avaliados

| Modo | Custo | Fidelidade | Recomendacao |
|---|---|---|---|
| literal | Medio | Alta | Nao recomendado; preserva limitacoes mobile. |
| modernizado | Medio | Media | Recomendado para Mac funcional. |
| hibrido | Medio | Alta em textos, media em layout | Aceitavel. |

## Decisao aprovada

Modo `modernizado`, preservando textos, estados, labels e fluxos principais.

## Implicacoes

- Usar layout desktop como alvo primario.
- Preservar tab set e conteudo textual.
- Nao inventar fluxos financeiros novos.
