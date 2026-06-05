# Discard Log

| ID | Item | Vinculado a paradigma | Justificativa |
|---|---|---|---|
| BR-DESCARTAR-001 | `flutter_foreground_task` como requisito para macOS | Sim | O alvo macOS nao tem foreground service Android. A regra de negocio e manter o bot ativo enquanto running; o mecanismo alvo sera adapter macOS. |
| BR-DESCARTAR-002 | Duplicacao `lib/` raiz e `app/lib/` | Nao | O Scout confirmou `app/` como aplicacao principal. A duplicacao sera preservada inicialmente como legado, nao migrada para a nova topologia. |
