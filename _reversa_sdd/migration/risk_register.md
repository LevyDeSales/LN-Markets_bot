# Risk Register

| ID | Risco | Prob. | Impacto | Mitigacao | Contingencia | Owner |
|---|---|---:|---:|---|---|---|
| R001 | Flutter ausente do PATH. | Alta | Alto | Instalar/localizar Flutter stable Apple Silicon sem sudo. | Pausar bootstrap e pedir path ao Levy. | Codex |
| R002 | Xcode completo ausente. | Alta | Alto | Detectar e informar comando oficial. | Pausar qualquer build macOS que exija Xcode. | Levy |
| R003 | Foreground service nao suportar macOS. | Alta | Alto | Adapter `BotRuntimeController` e runtime explicito enquanto app aberto. | Documentar limite operacional no UI/logs. | Codex |
| R004 | Credenciais em storage inseguro. | Alta | Alto | `flutter_secure_storage` e entitlements Keychain. | Bloquear persistencia de credenciais reais ate resolver. | Codex |
| R005 | Regras de trading divergirem. | Media | Critico | Testes de caracterizacao para indicadores e trading decisions. | Reverter cutover do entrypoint. | Codex |
| R006 | Comando acidental em mainnet. | Baixa | Critico | Testes com fakes; smoke manual testnet; sem credenciais reais. | Parar e pedir decisao do Levy. | Levy |
