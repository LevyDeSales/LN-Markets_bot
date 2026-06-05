# LN Markets Bot Mac ARM Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the current Flutter/Dart migration runnable and verifiable on Levy's Mac ARM machine without using real LN Markets credentials or executing real trades.

**Architecture:** Continue the Reversa migration already started in `app/lib/src`, keeping the legacy app as reference while hardening Mac-specific runtime, secure credential storage, and pure Dart trading behavior. Gates are delegated to a read-only gatekeeper subagent with high autonomy for routine technical decisions and strict rejection for secrets, sudo/password, destructive writes, or real trading risk.

**Tech Stack:** Flutter 3.44.1, Dart 3.12.1, macOS ARM, Xcode/CocoaPods, `flutter_secure_storage`, `shared_preferences`, Reversa SDD artefacts, Superpowers execution workflow.

---

## Current State

- Repo root: `/Users/levy/Library/Mobile Documents/com~apple~CloudDocs/Levy-dev-icloud/Pessoal/LNbot/LN-Markets_bot`
- Primary app: `app/`
- Reversa artefacts: `.reversa/`, `_reversa_sdd/`
- Previous verification passed: `flutter pub get`, `dart format`, `flutter analyze`, `flutter test`, `git diff --check`, `plutil -lint`, `jq`
- Known blocker from prior run: full Xcode/CocoaPods availability needed before `flutter build macos --debug` and `flutter run -d macos`
- Safety rule: no real credentials, no mainnet order, no destructive legacy deletion

## Execution Status — 2026-06-05

- Completed: gatekeeper delegation, read-only toolchain checks, pure Dart TDD hardening, generated-plugin policy note, final format/analyze/test checks.
- Completed: security reviewer finding on legacy plaintext credentials in `SharedPreferences`; `SettingsService` now removes `api_key`, `api_secret`, and `api_passphrase` from prefs when loading secure values, migrating legacy-only values, and saving values.
- Completed checks: `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`, `git diff --check`, `plutil -lint`, and `jq empty`.
- Blocked: `flutter build macos --debug` and `flutter run -d macos` remain blocked because `xcode-select -p` returns `/Library/Developer/CommandLineTools` and `xcodebuild -version` requires full Xcode.
- Environment note: CocoaPods `1.16.2` is installed.
- Update: full Xcode exists at `/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer` and responds with Xcode `26.5` build `17F42` when used through `DEVELOPER_DIR`. Flutter also sees the macOS device with this prefix, but Xcode license acceptance and first launch are still pending and require Levy's sudo/password.

## Gatekeeper Protocol

Every non-trivial gate receives:

- phase
- exact objective
- paths that may be written
- commands planned
- expected verification
- rollback strategy
- risk notes
- stop conditions

Gatekeeper response format:

```text
APPROVE: short reason | skills=...
```

or:

```text
REJECT: short reason | skills=... | falta=...
```

Gatekeeper must approve routine work aligned with this plan. It must reject sudo/password, Xcode license interaction, real credentials, mainnet trades, deletion of legacy code without explicit approval, writes outside declared paths, or missing essential context.

## Task 1: Toolchain Closure

**Files:**
- Modify: none expected
- Read: local Flutter/Xcode/CocoaPods environment

- [ ] **Step 1: Ask gatekeeper to approve read-only toolchain checks**

Gate context:

```text
phase=toolchain-closure
objective=check whether Xcode and CocoaPods are now available for Flutter macOS build
paths_writable=none
commands=xcode-select -p; xcodebuild -version; pod --version; flutter doctor -v; flutter devices
risks=commands may report license/setup issues but should not write project files
rollback=none needed for read-only checks
stop_if=sudo/password/license prompt/credential request
```

- [ ] **Step 2: Run read-only checks**

Run:

```bash
xcode-select -p
xcodebuild -version
pod --version
flutter doctor -v
flutter devices
```

Expected: Xcode points to full Xcode, CocoaPods is installed, macOS desktop is available.

- [ ] **Step 3: If blocked, record exact blocker**

Update final report with the exact missing component and stop without guessing.

## Task 2: Mac Debug Build

**Files:**
- Modify: generated Flutter build files only if Flutter regenerates them
- Read: `app/pubspec.yaml`, `app/macos/**`, `app/lib/**`

- [ ] **Step 1: Ask gatekeeper to approve debug build**

Gate context:

```text
phase=mac-debug-build
objective=verify the migrated Flutter app builds for macOS debug on Mac ARM
paths_writable=app/.dart_tool, app/build, app/macos/Flutter/GeneratedPluginRegistrant.swift, app/linux/flutter/generated_*, app/windows/flutter/generated_*
commands=flutter pub get; flutter build macos --debug
risks=Flutter may regenerate plugin files; no credentials or network trading should be used
rollback=remove build artefacts if needed; keep generated plugin registrants if produced by pub get
stop_if=signing/password/license/credential/mainnet-order prompt
```

- [ ] **Step 2: Run dependency and build commands**

Run:

```bash
cd app
flutter pub get
flutter build macos --debug
```

Expected: debug build succeeds or fails with a concrete toolchain/build error.

- [ ] **Step 3: Use systematic debugging for failures**

If the build fails, read the full error, identify the failing layer, compare with Flutter macOS references, then make one minimal fix with a failing test or direct build reproduction where possible.

## Task 3: Secure Storage Coverage

**Files:**
- Modify: `app/test/src/settings/credentials_store_test.dart`
- Modify if needed: `app/lib/src/settings/credentials_store.dart`

- [ ] **Step 1: Add failing test for legacy migration semantics**

Test intent:

```dart
test('memory credentials store clears all credentials without affecting settings', () async {
  final store = MemoryCredentialsStore();

  await store.saveCredentials(
    apiKey: 'key',
    apiSecret: 'secret',
    passphrase: 'passphrase',
  );
  await store.clearCredentials();

  expect(await store.readApiKey(), isNull);
  expect(await store.readApiSecret(), isNull);
  expect(await store.readPassphrase(), isNull);
});
```

- [ ] **Step 2: Run RED**

Run:

```bash
cd app
flutter test test/src/settings/credentials_store_test.dart
```

Expected: fails only if behavior is missing; if already passes, record that the behavior was already covered and add a more specific failing test instead.

- [ ] **Step 3: Implement minimal production fix if needed**

Only edit `credentials_store.dart` if the failing test proves missing behavior.

- [ ] **Step 4: Run GREEN**

Run:

```bash
cd app
flutter test test/src/settings/credentials_store_test.dart
flutter test
```

Expected: all tests pass.

## Task 4: macOS Runtime Adapter Coverage

**Files:**
- Create: `app/test/src/platform/macos_bot_runtime_controller_test.dart`
- Modify if needed: `app/lib/src/platform/macos/macos_bot_runtime_controller.dart`

- [ ] **Step 1: Add failing test for macOS no-foreground-service semantics**

Test intent:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ln_markets_bot/src/platform/bot_runtime_controller.dart';
import 'package:ln_markets_bot/src/platform/macos/macos_bot_runtime_controller.dart';

void main() {
  test('macOS runtime controller keeps explicit in-app running state', () async {
    final controller = MacosBotRuntimeController();

    expect(await controller.isRunning, isFalse);

    await controller.start(BotRuntimeSnapshot(
      title: 'LN Markets Bot',
      body: 'Running',
      isRunning: true,
    ));
    expect(await controller.isRunning, isTrue);

    await controller.update(BotRuntimeSnapshot(
      title: 'LN Markets Bot',
      body: 'Still running',
      isRunning: true,
    ));
    expect(await controller.isRunning, isTrue);

    await controller.stop();
    expect(await controller.isRunning, isFalse);
  });
}
```

- [ ] **Step 2: Run RED**

Run:

```bash
cd app
flutter test test/src/platform/macos_bot_runtime_controller_test.dart
```

Expected: fails if controller lacks observable state.

- [ ] **Step 3: Implement minimal production fix**

Add only the state needed for macOS explicit in-app runtime.

- [ ] **Step 4: Run GREEN**

Run:

```bash
cd app
flutter test test/src/platform/macos_bot_runtime_controller_test.dart
flutter test
```

Expected: all tests pass.

## Task 5: Trading Core Parity Expansion

**Files:**
- Modify: `app/test/src/trading/position_math_test.dart`
- Modify: `app/test/src/trading/lnmarkets_signer_test.dart`
- Modify if needed: `app/lib/src/trading/position_math.dart`
- Modify if needed: `app/lib/src/trading/lnmarkets_signer.dart`

- [ ] **Step 1: Add failing tests for no-real-network trading invariants**

Test intents:

```dart
test('long-only close request does not invert position', () {
  final next = closeLongOnlyPosition(
    currentQuantity: 2,
    requestedCloseQuantity: 3,
  );

  expect(next.closeQuantity, 2);
  expect(next.remainingQuantity, 0);
});
```

```dart
test('signer includes method path timestamp and body in hmac payload', () {
  final signer = LnMarketsSigner(
    apiSecret: 'secret',
    timestampProvider: () => '1700000000000',
  );

  final signature = signer.sign(
    method: 'POST',
    path: '/v2/futures',
    body: '{"type":"m"}',
  );

  expect(signature, isNotEmpty);
  expect(signature, isNot(contains('secret')));
});
```

- [ ] **Step 2: Run RED**

Run:

```bash
cd app
flutter test test/src/trading/position_math_test.dart test/src/trading/lnmarkets_signer_test.dart
```

Expected: fail only for missing behavior.

- [ ] **Step 3: Implement minimal production fix**

Keep logic pure Dart and network-free.

- [ ] **Step 4: Run GREEN**

Run:

```bash
cd app
flutter test test/src/trading/position_math_test.dart test/src/trading/lnmarkets_signer_test.dart
flutter test
```

Expected: all tests pass.

## Task 6: Generated Plugin Policy

**Files:**
- Modify: `_reversa_sdd/migration/handoff.md` or add a note in `_reversa_sdd/migration/toolchain.md`
- Read: generated plugin registrants

- [ ] **Step 1: Document generated plugin policy**

Record that Linux/Windows generated plugin registrant changes may remain when produced by `flutter pub get` for `flutter_secure_storage`, while Mac remains the primary target.

- [ ] **Step 2: Verify no binary or credential artefacts are introduced**

Run:

```bash
git status --short
git diff --name-only
```

Expected: no credentials, no signed app bundle, no unexpected binaries.

## Task 7: Final Verification

**Files:**
- Read/verify all changed files

- [ ] **Step 1: Run static and test verification**

Run:

```bash
cd app
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

- [ ] **Step 2: Run artefact verification**

Run from repo root:

```bash
git diff --check
plutil -lint app/macos/Runner/DebugProfile.entitlements app/macos/Runner/Release.entitlements
jq empty _reversa_sdd/migration/.state.json _reversa_sdd/screens/inventory.json app/.flutter-plugins-dependencies
git status --short
```

- [ ] **Step 3: Ask final code-reviewer**

Use a read-only review subagent with `engineering-code-reviewer`, `engineering-security-engineer`, `engineering-mobile-app-builder`, and `superpowers:verification-before-completion`.

- [ ] **Step 4: Report outcome**

Report what passed, what remains blocked by local Xcode/CocoaPods/signing, and exact next local action for Levy if human/admin interaction is needed.
