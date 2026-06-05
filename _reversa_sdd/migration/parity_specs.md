# Parity Specs

## Modos de validacao

- Characterization tests para indicadores e decisoes de trading.
- Contract tests para clients HTTP com fake client.
- Data parity para migracao SharedPreferences -> secure storage.
- Contract tests de tela para modo modernizado.

## Criterio de paridade aceita

- Zero divergencia nos testes unitarios de regras BR-MIGRAR confirmadas.
- Nenhum teste automatizado usa credenciais reais.
- Nenhum teste automatizado chama LN Markets mainnet.

## Cobertura adaptada ao paradigma

Transicao: services Flutter stateful -> dominio Dart puro + adapters.

Dimensoes obrigatorias:
- invariantes de `PositionState`;
- idempotencia de start;
- ordem fechar-posicao antes de abrir oposta;
- isolacao entre storage seguro e preferencias simples.

## Excecoes aprovadas

- DEV-001: layout desktop-first.
- DEV-002: secure storage para credenciais.
- DEV-003: sem foreground service Android no macOS.
