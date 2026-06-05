# Espacamento — LN Markets Bot

Fonte: `app/lib/app_theme.dart` e uso observado nos componentes.

| Token | Valor | Uso | Confianca |
|---|---:|---|---|
| `radius.input` | `8` | Inputs | CONFIRMADO |
| `radius.button` | `8` | Botoes | CONFIRMADO |
| `radius.card` | `12` | Cards legados | CONFIRMADO |
| `padding.input.x` | `14` | Input horizontal | CONFIRMADO |
| `padding.input.y` | `12` | Input vertical | CONFIRMADO |
| `padding.button.y` | `14` | Botao vertical | CONFIRMADO |
| `margin.card` | `0` | CardTheme global | CONFIRMADO |
| `breakpoint.desktop` | `600` | Troca mobile/desktop em HomeScreen | CONFIRMADO |

## Ajuste para Mac ARM

- Preferir layout desktop como primeiro alvo.
- Manter densidade operacional.
- Cards novos devem usar raio maximo `8` quando possivel; o `12` legado deve ser tratado como compatibilidade visual, nao padrao novo.
