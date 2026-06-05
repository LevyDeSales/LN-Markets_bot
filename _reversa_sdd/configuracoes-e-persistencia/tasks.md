# Tasks — Configuracoes e Persistencia

| ID | Tarefa | Origem legado | Pronto quando | Confianca |
|---|---|---|---|---|
| T-CONF-01 | Implementar `SettingsService` com todos os campos e defaults. | `app/lib/services/settings_service.dart:3-25` | Campos existem com defaults equivalentes. | 🟢 |
| T-CONF-02 | Implementar `hasCredentials`, `baseUrl` e `candlesLimit`. | `settings_service.dart:27-34` | Getters retornam exatamente as regras legadas. | 🟢 |
| T-CONF-03 | Implementar `load()` lendo todas as chaves persistidas. | `settings_service.dart:36-57` | Ausencia de chave aplica fallback legado. | 🟢 |
| T-CONF-04 | Implementar `save()` gravando todas as chaves. | `settings_service.dart:59-79` | Reload apos save preserva valores. | 🟢 |
| T-CONF-05 | Implementar formulario Settings com validacao de credenciais. | `settings_tab.dart:79-112` | Save vazio mostra erro e nao persiste. | 🟢 |
| T-CONF-06 | Implementar troca de idioma persistida. | `settings_tab.dart:116-121` | Idioma muda imediatamente e sobrevive restart. | 🟢 |
| T-CONF-07 | Implementar sugestao de intervalo por timeframe. | `settings_tab.dart:8-15`, `settings_tab.dart:200-214` | Selecionar timeframe atualiza campo intervalo. | 🟢 |

## Testes sugeridos

- Unit tests para `baseUrl` mainnet/testnet.
- Unit tests para `candlesLimit` com `emaSignal` baixo, 50 e alto.
- Teste de persistencia round-trip em SharedPreferences mockado.
- Teste de UI para credenciais vazias.
