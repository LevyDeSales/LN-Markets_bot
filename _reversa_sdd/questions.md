# Perguntas de Validacao — LN Markets Bot

Gerado em: 2026-06-05T05:06:59Z

## Q1 — Armazenamento de credenciais

- **Contexto:** O README afirma que credenciais de API sao armazenadas localmente com seguranca, mas o codigo usa `SharedPreferences`.
- **Impacto:** Afeta reimplementacao, hardening e prioridade de backlog.
- **Pergunta:** Devemos preservar o comportamento atual (`SharedPreferences`) por fidelidade ao legado ou especificar migracao para storage seguro?
- **Resposta:** _pendente_
- **Confianca atual:** 🔴 LACUNA

## Q2 — Fonte canonica do app

- **Contexto:** A raiz contem `lib/` e `pubspec.yaml` de versao anterior, enquanto `app/` contem a versao atual `3.3.0+6` com plataformas geradas.
- **Impacto:** Afeta futuras mudancas, build e limpeza do repositorio.
- **Pergunta:** `app/` e a fonte canonica daqui em diante, e `lib/` raiz deve ser tratado como legado/seed?
- **Resposta:** _pendente_
- **Confianca atual:** 🟡 INFERIDO

## Q3 — Falhas silenciosas em APIs auxiliares

- **Contexto:** Market data, remote config e foreground service capturam erros silenciosamente.
- **Impacto:** Afeta observabilidade e suporte.
- **Pergunta:** Esse comportamento silencioso e intencional para degradacao graciosa, ou as falhas devem aparecer no log/dashboard?
- **Resposta:** _pendente_
- **Confianca atual:** 🟡 INFERIDO
