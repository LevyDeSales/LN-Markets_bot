# Requirements — Servico em Background

## Objetivo

🟢 **CONFIRMADO** Usar `flutter_foreground_task` para manter o app ativo com notificacao enquanto o bot roda.

## Requisitos Funcionais

| ID | Prioridade | Requisito | Evidencia | Confianca |
|---|---|---|---|---|
| RF-BG-01 | Must | Deve existir entrypoint top-level anotado para background isolate. | `foreground_service.dart:3-7` | 🟢 |
| RF-BG-02 | Must | `init()` deve ser idempotente. | `foreground_service.dart:23-30` | 🟢 |
| RF-BG-03 | Must | Android notification channel deve usar id `lnmarkets_bot_channel`. | `foreground_service.dart:30-36` | 🟢 |
| RF-BG-04 | Should | Foreground options devem permitir wake lock e nao auto-run on boot. | `foreground_service.dart:41-46` | 🟢 |
| RF-BG-05 | Must | `start()` deve iniciar service id 256 com titulo/texto e callback. | `foreground_service.dart:50-60` | 🟢 |
| RF-BG-06 | Should | Falhas em start/update/stop/battery devem ser engolidas para degradacao graciosa. | `foreground_service.dart:50-90` | 🟢 |

## Criterios de Aceitacao

Dado que `ForegroundService.init()` ja rodou  
Quando for chamado novamente  
Entao nao deve reinicializar o plugin.

Dado que start falha por permissao/plataforma  
Quando `ForegroundService.start()` e chamado  
Entao o app nao deve quebrar.
