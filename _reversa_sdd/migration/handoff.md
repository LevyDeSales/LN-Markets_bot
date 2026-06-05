# Handoff — Migracao LN Markets Bot para Mac ARM

## Leitura obrigatoria

1. `_reversa_sdd/migration/paradigm_decision.md`
2. `_reversa_sdd/migration/topology_decision.md`
3. `_reversa_sdd/migration/target_architecture.md`
4. `_reversa_sdd/migration/parity_specs.md`

## Artefatos produzidos

- `migration_brief.md`
- `paradigm_decision.md`
- `target_business_rules.md`
- `discard_log.md`
- `migration_strategy.md`
- `risk_register.md`
- `cutover_plan.md`
- `topology_decision.md`
- `target_architecture.md`
- `target_domain_model.md`
- `target_data_model.md`
- `data_migration_plan.md`
- `screen_modernization_decision.md`
- `target_screens.md`
- `screen_deviation_log.md`
- `parity_specs.md`
- `parity_tests/*.feature`

## Itens referidos a codificacao

1. Criar `app/lib/src`.
2. Implementar dominio puro de trading e indicadores.
3. Criar `CredentialsStore` com secure storage e migracao idempotente.
4. Criar adapter macOS de runtime sem foreground service.
5. Corrigir entitlements macOS para rede cliente e Keychain.
6. Adicionar testes de indicadores, trading, storage e HMAC.
7. Trocar entrypoint somente apos testes.

## Regras de seguranca

- Sem credenciais reais em testes.
- Sem chamada mainnet automatizada.
- Sem sudo.
- Sem publicacao.
- Sem deletar legado nesta etapa.

## Verificacao local

Flutter `3.44.1` e Dart `3.12.1` estao funcionais. `flutter pub get`, `flutter analyze` e `flutter test` passaram. CocoaPods `1.16.2` esta instalado. `xcode-select -p` ainda retorna `/Library/Developer/CommandLineTools`, mas um Xcode completo foi validado em `/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer` com Xcode `26.5` build `17F42` usando `DEVELOPER_DIR`. `flutter doctor -v` com `DEVELOPER_DIR` reconhece esse Xcode e o device macOS, mas ainda bloqueia `flutter run -d macos` e `flutter build macos` ate Levy aceitar a licenca e rodar first launch com sudo.

## Politica de arquivos gerados

As alteracoes em registrants gerados de Linux/Windows podem permanecer quando forem efeito direto de `flutter pub get` apos adicionar `flutter_secure_storage`. O alvo primario continua sendo macOS ARM; esses arquivos gerados nao devem ser usados para expandir o escopo da migracao para Linux/Windows nesta etapa.

## Handoff Mac mock-safe

- A raiz Flutter canonica e `app/`.
- `setup.sh` nao deve mais copiar fontes legadas da raiz para `app/`; ele roda `pub get`, `analyze` e `test` diretamente em `app/`.
- Novas configuracoes usam `testnet` por padrao.
- O modo mock usa `LNMBOT_MOCK_MODE=true`, clientes fake e chave isolada `mock_bot_position`.
- Antes de validar por clone GitHub, commitar todos os arquivos novos em `app/lib/src/`, `app/test/src/`, Podfiles e docs de handoff.
