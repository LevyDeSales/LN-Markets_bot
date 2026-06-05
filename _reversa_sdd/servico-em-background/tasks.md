# Tasks — Servico em Background

| ID | Tarefa | Origem legado | Pronto quando | Confianca |
|---|---|---|---|---|
| T-BG-01 | Criar entrypoint top-level com `@pragma('vm:entry-point')`. | `foreground_service.dart:3-7` | Plugin encontra callback em background. | 🟢 |
| T-BG-02 | Implementar handler minimo sem trading no isolate background. | `foreground_service.dart:9-21` | onRepeatEvent nao executa ordens. | 🟢 |
| T-BG-03 | Implementar init idempotente com canal Android e options. | `foreground_service.dart:23-48` | Segunda chamada nao reinicializa. | 🟢 |
| T-BG-04 | Implementar start/update/stop com try/catch. | `foreground_service.dart:50-82` | Falha do plugin nao derruba app. | 🟢 |
| T-BG-05 | Implementar pedido de ignorar otimizacao de bateria. | `foreground_service.dart:84-90` | Metodo nao quebra em plataforma sem suporte. | 🟢 |

## Testes sugeridos

- Unit test com wrapper/mock do plugin para init idempotente.
- Teste de excecao em start/update/stop.
- Teste integrado Android para permissao/notificacao.
