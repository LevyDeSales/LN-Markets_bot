# LN Markets Bot Mac Validation Handoff

## Status

- App root: `app/`
- Xcode external path validated: `/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer`
- Xcode version: `26.5` build `17F42`
- CocoaPods: `1.16.2`
- macOS device is visible to Flutter when `DEVELOPER_DIR` is set.
- `flutter build macos --debug` was not run because Xcode first launch is still blocked by a local CoreDevice/DDI install issue.
- `setup.sh` has been made safe: it now works directly in `app/` and no longer copies root-level legacy sources over the migrated app.
- New settings default to `testnet`.
- Mock mode uses an isolated `mock_bot_position` storage key, so it does not clear a live `bot_position`.

## Xcode First Launch Issue

Levy ran:

```bash
sudo xcode-select --switch /Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
```

The selector switch succeeded. `xcode-select -p` now returns:

```bash
/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer
```

`xcodebuild -runFirstLaunch` failed while running `XcodeSystemResources.pkg`. `/var/log/install.log` shows:

```text
Begin script: XcodeSystemResources_postinstall.sh
PackageKit: Terminating PKInstallTask(...). Task has exceeded its 300 seconds of runtime.
Install Failed: Error Domain=PKInstallErrorDomain Code=112 ... XcodeSystemResources.pkg
```

The package `postinstall` only runs:

```bash
/Library/Developer/PrivateFrameworks/CoreDevice.framework/Resources/bin/devicectl manage ddis update
```

After the failed installer run, these root processes were still alive:

```text
36894 /bin/sh ... XcodeSystemResources_postinstall.sh ...
36897 /Library/Developer/PrivateFrameworks/CoreDevice.framework/Resources/bin/devicectl manage ddis update
```

The package payload did copy fresh CandidateDDIs under `/Library/Developer/CoreDevice/CandidateDDIs`, but the `devicectl manage ddis update` step is hung. Do not retry `xcodebuild -runFirstLaunch` while these PIDs are still active.

## Completed Checks

From `app/`:

```bash
DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer flutter pub get
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed lib test
```

From repo root:

```bash
git diff --check
plutil -lint app/macos/Runner/DebugProfile.entitlements app/macos/Runner/Release.entitlements
jq empty _reversa_sdd/migration/.state.json _reversa_sdd/screens/inventory.json app/.flutter-plugins-dependencies
```

All commands above passed. `flutter test` passed with 25 tests.

## Levy Action Required

Run these commands locally with your password if the stuck PIDs are still present:

```bash
ps -p 36894,36897 -o pid,user,ppid,stat,etime,command
sudo kill 36897 36894
ps -p 36894,36897 -o pid,user,ppid,stat,etime,command
```

Then retry first launch:

```bash
sudo xcodebuild -runFirstLaunch
```

If `devicectl manage ddis update` hangs again for several minutes, stop there and inspect the same two-process pattern before retrying. Do not stack repeated `runFirstLaunch` attempts while an old root `devicectl` is still alive.

Already completed:

```bash
sudo xcode-select --switch /Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```

## Validation Commands After Xcode Setup

From `app/`:

```bash
DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer flutter doctor -v
DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer flutter build macos --debug
DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer flutter run -d macos --dart-define=LNMBOT_MOCK_MODE=true
```

If you switch the global selector with `xcode-select`, the same commands can be run without `DEVELOPER_DIR=...`.

## Mock-Safe Mode

`LNMBOT_MOCK_MODE=true` uses:

- `FakeExchangeClient`
- `FakeMarketDataClient`
- `MacosBotRuntimeController`
- no sponsor/market remote background effects in the smoke shell
- no real LN Markets credentials
- no live mainnet order path
- isolated mock position state under `mock_bot_position`

## Git Handoff

Before this can be consumed by a fresh clone from GitHub, commit the changed and new files. The app imports new files under `app/lib/src/`, so leaving them untracked will break a clean clone.

Recommended final sequence after verification:

```bash
git status --short
git add .
git commit -m "feat: prepare mac mock-safe migration"
```

Do not commit build products, credentials, or local secrets.

## What To Inspect Manually

When the mock app opens:

- Home shell renders.
- Settings tab opens without requiring real credentials.
- No live trade is started.
- Dashboard can be inspected with fake services.
- App can be closed cleanly.
