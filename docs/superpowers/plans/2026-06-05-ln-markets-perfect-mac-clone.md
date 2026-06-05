# LN Markets Bot Perfect Mac Clone Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the cloned `LevyDeSales/LN-Markets_bot` fully usable on Levy's Mac ARM with green tests, safe mocks, and no dependency on real LN Markets credentials for validation.

**Architecture:** Continue from the current Reversa/Superpowers migration and close the remaining Mac usability loop: prove the local Apple toolchain, build the macOS app, add safe mock clients for exchange/market data behavior, and keep all live trading paths behind explicit credentials and gate approval. Gate decisions are delegated to a read-only subagent that uses Engineering and Superpowers skills as decision lenses.

**Tech Stack:** Flutter 3.44.1, Dart 3.12.1, macOS ARM, Xcode, CocoaPods, `shared_preferences`, `flutter_secure_storage`, fake clients/mocks, Flutter unit/widget tests, Reversa SDD artefacts.

---

## Gatekeeper Contract

Spawn one read-only gatekeeper during execution. It must not edit files.

Prompt base:

```text
Você é o Gatekeeper Superpowers/Reversa do LN Markets Bot Mac ARM.

Não edite arquivos. Avalie o gate recebido com contexto técnico.

Use como lentes: engineering-software-architect, engineering-mobile-app-builder,
engineering-devops-automator, engineering-security-engineer,
engineering-code-reviewer, engineering-sre,
superpowers:test-driven-development, superpowers:systematic-debugging,
superpowers:verification-before-completion.

Responda somente:
APPROVE: motivo curto | skills=...
ou
REJECT: motivo curto | skills=... | falta=...

Levy delegou autonomia alta para gates técnicos rotineiros. Aprove decisões
alinhadas ao plano, ao escopo Mac ARM e aos artefatos Reversa. Reprove se houver
senha/sudo, licença Xcode interativa, credenciais reais, trade mainnet, risco de
ordem real, deleção de legado sem backup, escrita fora do escopo, ambiguidade
financeira/de negócio, ou falta de contexto essencial.
```

Every gate receives:

- phase
- objective
- files/paths writable
- commands planned
- expected result
- rollback
- risks
- stop conditions

## Task 1: Prove Mac Toolchain Is Actually Fixed

**Files:**
- Modify: none

**Xcode note from Levy:** A full Xcode exists at
`/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer` and responds
to `DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer xcodebuild -version`
with Xcode `26.5` build `17F42`. The global selector still points to
`/Library/Developer/CommandLineTools`, so normal Flutter/CocoaPods discovery
still needs Levy to run:

```bash
sudo xcode-select --switch /Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
```

Until the global selector is switched, validation may use the non-sudo
`DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer`
prefix for read-only Xcode/Flutter checks.

Flutter app root for this workspace: `app/`.

- [ ] **Step 1: Ask gatekeeper to approve read-only toolchain proof**

Gate context:

```text
phase=mac-toolchain-proof
objective=confirm Xcode full install, CocoaPods, Flutter desktop macOS, and connected devices
paths_writable=none
commands=xcode-select -p; DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer xcodebuild -version; pod --version; DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer flutter doctor -v; DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer flutter devices
risk=read-only diagnostics only
rollback=none
stop_if=sudo/password/license prompt
```

- [ ] **Step 2: Run commands**

```bash
cd app
xcode-select -p
DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer xcodebuild -version
pod --version
DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer flutter doctor -v
DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer flutter devices
```

Expected:

- `xcode-select -p` may still point to CommandLineTools until Levy runs sudo switch
- `DEVELOPER_DIR=... xcodebuild -version` succeeds with Xcode 26.5
- `pod --version` succeeds
- `flutter doctor -v` has no blocking macOS/Xcode issue
- `flutter devices` lists `macOS`

## Task 2: Build macOS Debug Without Live Trading

**Files:**
- Modify: generated Flutter files only if `flutter pub get` regenerates plugin registrants

- [ ] **Step 1: Ask gatekeeper to approve debug build**

Gate context:

```text
phase=mac-debug-build
objective=build macOS debug app locally without running live credentials/trading
paths_writable=app/.dart_tool, app/build, generated Flutter plugin files
commands=flutter pub get; flutter build macos --debug
risk=build writes artifacts; no real run, no credentials, no trade
rollback=remove build artifacts if needed; keep generated registrants if from Flutter
stop_if=signing/password/license/credential/mainnet prompt
```

- [ ] **Step 2: Run build**

```bash
cd app
flutter pub get
flutter build macos --debug
```

Expected: debug build succeeds.

## Task 3: Add Explicit Mock Mode Boundary

**Files:**
- Create: `app/lib/src/clients/exchange_client.dart`
- Create: `app/lib/src/clients/market_data_client.dart`
- Create: `app/lib/src/clients/fake_exchange_client.dart`
- Create: `app/lib/src/clients/fake_market_data_client.dart`
- Modify: `app/lib/services/trader_service.dart`
- Test: `app/test/src/clients/fake_exchange_client_test.dart`
- Test: `app/test/src/clients/fake_market_data_client_test.dart`

- [ ] **Step 1: Write failing fake exchange tests**

Test behaviors:

```dart
test('fake exchange opens and closes positions without network', () async {
  final client = FakeExchangeClient(balanceSats: 100000);

  final user = await client.getUser();
  expect(user['balance'], 100000);

  final opened = await client.openPosition('long', marginSats: 1000);
  expect(opened['side'], 'long');
  expect(await client.getOpenPositions(), hasLength(1));

  await client.closePosition(opened['id'] as String);
  expect(await client.getOpenPositions(), isEmpty);
});
```

- [ ] **Step 2: Write failing fake market data tests**

Test behaviors:

```dart
test('fake market data returns deterministic candles', () async {
  final client = FakeMarketDataClient();

  final candles = await client.fetchCandles('15m', 150);

  expect(candles, hasLength(150));
  expect(candles.last.close, greaterThan(candles.first.close));
});
```

- [ ] **Step 3: Implement minimal interfaces and fakes**

Implementation rule: no HTTP imports in fake client files.

- [ ] **Step 4: Run GREEN**

```bash
cd app
flutter test test/src/clients/fake_exchange_client_test.dart test/src/clients/fake_market_data_client_test.dart
```

Expected: fake client tests pass.

## Task 4: Inject Clients Into TraderService

**Files:**
- Modify: `app/lib/services/trader_service.dart`
- Test: `app/test/src/services/trader_service_test.dart`

- [ ] **Step 1: Write failing TraderService mock-cycle test**

Test behavior:

```dart
test('start uses injected fake clients and does not call live APIs', () async {
  final settings = SettingsService(credentialsStore: MemoryCredentialsStore());
  SharedPreferences.setMockInitialValues({
    'network': 'testnet',
    'check_interval': 5,
  });
  await settings.load();

  final trader = TraderService(
    settings: settings,
    log: LogService(),
    exchangeClient: FakeExchangeClient(balanceSats: 100000),
    marketDataClient: FakeMarketDataClient(),
    runtimeController: MacosBotRuntimeController(),
  );

  await trader.start();

  expect(trader.running, isTrue);
  expect(trader.balance, 100000);

  trader.stop();
});
```

- [ ] **Step 2: Implement injection with wrappers**

Keep legacy live API behavior by default:

- default `exchangeClient` wraps `LNMarketsAPI`
- default `marketDataClient` wraps `BinanceAPI`
- tests pass fake clients explicitly

- [ ] **Step 3: Run targeted GREEN**

```bash
cd app
flutter test test/src/services/trader_service_test.dart
```

Expected: service starts with fakes and does not require credentials/network.

## Task 5: Safe Mock App Smoke

**Files:**
- Modify: `app/lib/main.dart` only if a mock-mode switch is needed
- Create or modify: `app/test/widget_test.dart`

- [ ] **Step 1: Write failing widget smoke test**

Test behavior:

```dart
testWidgets('app renders home shell in mock-safe mode', (tester) async {
  SharedPreferences.setMockInitialValues({'network': 'testnet'});

  await tester.pumpWidget(await buildMockSafeApp());
  await tester.pump();

  expect(find.textContaining('LN'), findsWidgets);
});
```

- [ ] **Step 2: Implement test-only app builder if needed**

Keep production entrypoint behavior unchanged unless the test proves a seam is required.

- [ ] **Step 3: Run widget smoke**

```bash
cd app
flutter test test/widget_test.dart
```

Expected: widget smoke passes with mocks and no async service/network dependency.

## Task 6: Local Mac Run Smoke With Mock Guard

**Files:**
- Modify: none expected unless Task 5 requires a `--dart-define` mock switch

- [ ] **Step 1: Ask gatekeeper to approve app launch**

Gate context:

```text
phase=mac-run-smoke
objective=launch local macOS app only in mock-safe mode after debug build and tests pass
paths_writable=app/build and Flutter transient runtime files
commands=flutter run -d macos --dart-define=LNMBOT_MOCK_MODE=true
risk=app launch; must not use real credentials or live trading
rollback=stop app process; no code rollback expected
stop_if=credentials prompt becomes required, live network/trading path activates, signing prompt appears
```

- [ ] **Step 2: Run smoke**

```bash
cd app
flutter run -d macos --dart-define=LNMBOT_MOCK_MODE=true
```

Expected: app launches on macOS and home/settings/dashboard surfaces render.

## Task 7: Full Verification

**Files:**
- Read/verify all changed files

- [ ] **Step 1: Run core checks**

```bash
cd app
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build macos --debug
```

- [ ] **Step 2: Run repo artefact checks**

```bash
git diff --check
plutil -lint app/macos/Runner/DebugProfile.entitlements app/macos/Runner/Release.entitlements
jq empty _reversa_sdd/migration/.state.json _reversa_sdd/screens/inventory.json app/.flutter-plugins-dependencies
git status --short
```

- [ ] **Step 3: Dispatch final reviewers**

Use read-only reviewers:

- reviewer 1: `engineering-code-reviewer` + `superpowers:verification-before-completion`
- reviewer 2: `engineering-security-engineer` + `engineering-mobile-app-builder`

Expected: no blocking findings.

## Stop Conditions

Stop and report to Levy if any of these occurs:

- sudo/password/Xcode license prompt
- real LN Markets credential request
- live mainnet order risk
- signing/release/publish prompt
- deletion of legacy files
- build/run failure after three systematic debugging attempts
- any gatekeeper `REJECT`

## Definition Of Done

- Full Xcode toolchain verified.
- `flutter build macos --debug` passes.
- App can launch on macOS in mock-safe mode.
- All tests green with mocks.
- No test uses real credentials, Keychain secrets, network trading, or mainnet orders.
- Final subagent reviewers report no blocking findings.

## Execution Status — 2026-06-05

- Completed: Xcode external path verified with `DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer xcodebuild -version`.
- Completed: Flutter sees macOS device when `DEVELOPER_DIR` is set.
- Completed: fake exchange/market-data clients, `TraderService` injection, and widget smoke mock-safe.
- Completed: safe `setup.sh`/README remediation so setup no longer overwrites `app/` from root legacy sources.
- Completed: default network changed to `testnet`.
- Completed: mock mode uses isolated `mock_bot_position` storage key.
- Blocked: `flutter build macos --debug` and `flutter run -d macos --dart-define=LNMBOT_MOCK_MODE=true` still require Levy to accept Xcode license and run first launch:

```bash
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
```

- Optional normalisation after that:

```bash
sudo xcode-select --switch /Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer
```

- Until then, use the `DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer` prefix for validation commands.
