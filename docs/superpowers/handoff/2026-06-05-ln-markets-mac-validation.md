# LN Markets Bot Mac Validation Handoff

## Status

- App root: `app/`
- Xcode external path validated: `/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer`
- Xcode version: `26.5` build `17F42`
- CocoaPods: `1.16.2`
- Global `xcode-select` now points to the external Xcode path.
- macOS device is visible to Flutter.
- `flutter analyze` passes.
- `flutter test` passes with 25 tests.
- `flutter build macos --debug --dart-define=LNMBOT_MOCK_MODE=true` still does not complete: Xcode's `SWBBuildService` hangs while running `clang -v -E -dM ... /dev/null`.
- `setup.sh` has been made safe: it now works directly in `app/` and no longer copies root-level legacy sources over the migrated app.
- New settings default to `testnet`.
- Mock mode uses an isolated `mock_bot_position` storage key, so it does not clear a live `bot_position`.
- Swift Package Manager is disabled for this Flutter app in `app/pubspec.yaml` with `flutter.config.enable-swift-package-manager: false`; current plugins are CocoaPods-based and Flutter's SPM integration failed while resolving dependencies.
- `pod install` generated macOS CocoaPods integration in `app/macos/Runner.xcodeproj/project.pbxproj`, `app/macos/Runner.xcworkspace/contents.xcworkspacedata`, and `app/macos/Podfile.lock`.
- The working local path for macOS builds is now `/Users/levy/Developer/LNbot/LN-Markets_bot`. The iCloud Drive path can trigger File Provider extended attributes that break macOS codesigning.

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

After Levy cleared the orphaned processes, the old PIDs were gone and the selector still pointed to Xcode 26.5, but the system package receipt was still old:

```bash
pkgutil --pkg-info com.apple.pkg.XcodeSystemResources
# version: 16.2.0.0.1.1733547573
```

The original Xcode tool lookup was unhealthy:

```bash
xcodebuild -find simctl
xcodebuild -sdk /Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk -find clang
```

Both commands hung at that time. After Levy opened/fixed Xcode, the basic lookup is now healthy:

```bash
xcode-select -p
# /Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer

xcodebuild -version
# Xcode 26.5
# Build version 17F42

xcodebuild -find clang
# /Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang

xcodebuild -find simctl
# /Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer/usr/bin/simctl
```

`flutter devices` now returns macOS and Chrome. `flutter doctor -v` still reports:

```text
[!] Xcode - develop for iOS and macOS (Xcode 26.5)
    ✗ Unable to get list of installed Simulator runtimes.
```

This simulator runtime issue does not explain Dart tests, but it may be related to the remaining Xcode build-service problem.

Old impact before the fix:

- `flutter devices` hangs in `xcodebuild -find simctl`.
- `flutter test` can hang in `xcodebuild -find clang`.
- `flutter build macos --debug --dart-define=LNMBOT_MOCK_MODE=true` reaches Xcode/SPM setup, then cannot complete while Xcode lookup is unhealthy.

Current remaining impact:

- `flutter build macos --debug --dart-define=LNMBOT_MOCK_MODE=true` reaches `Building macOS application...`.
- The child `xcodebuild` process starts `SWBBuildService`.
- `SWBBuildService` starts two `clang -v -E -dM ... /dev/null` commands.
- The build then hangs until interrupted.
- Running an equivalent `clang -v -E -dM ... /dev/null` directly completes, so the current blocker is inside Xcode/SwiftBuild orchestration rather than the Dart code or `clang` itself.

After moving/copying the project out of iCloud Drive to `/Users/levy/Developer/LNbot/LN-Markets_bot`, this blocker no longer reproduces.

The iCloud path later reached codesign but failed with:

```text
resource fork, Finder information, or similar detritus not allowed
```

The failing app bundle had `com.apple.FinderInfo`, `com.apple.fileprovider.fpfs#P`, and `com.apple.provenance` attributes from File Provider/iCloud. Building from the local path avoids those attributes.

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

On 2026-06-06, after Xcode was opened and selected globally:

```bash
flutter devices
flutter doctor -v
flutter analyze
flutter test
flutter build macos --debug --dart-define=LNMBOT_MOCK_MODE=true
```

Results:

- `flutter devices`: passed; macOS and Chrome visible.
- `flutter doctor -v`: Flutter, CocoaPods, Chrome, connected macOS device, and network resources are usable; Android SDK is absent; Xcode cannot list installed simulator runtimes.
- `flutter analyze`: passed with no issues.
- `flutter test`: passed with 25 tests.
- `flutter build macos --debug --dart-define=LNMBOT_MOCK_MODE=true`: blocked by the `SWBBuildService` / `clang -v -E -dM` hang described above.

On 2026-06-06, from `/Users/levy/Developer/LNbot/LN-Markets_bot/app`:

```bash
flutter pub get
pod install
flutter analyze
flutter test
flutter build macos --debug --dart-define=LNMBOT_MOCK_MODE=true
```

Results:

- `flutter analyze`: passed with no issues.
- `flutter test`: passed with 25 tests.
- `flutter build macos --debug --dart-define=LNMBOT_MOCK_MODE=true`: passed and produced `build/macos/Build/Products/Debug/lnmarkets_bot.app`.

## Levy Action Required

No `flutter build macos`, `xcodebuild`, `SWBBuildService`, or stuck `clang -v -E -dM` process was left running after the 2026-06-06 validation.

If build hangs again, inspect and stop only the active build processes:

```bash
ps -axo pid,ppid,stat,etime,command | rg "flutter build macos|xcodebuild .*Runner.xcworkspace|SWBBuildService|clang -v -E -dM"
```

Next practical local checks:

```bash
xcodebuild -runFirstLaunch
xcrun simctl list runtimes
open app/macos/Runner.xcworkspace
```

Then build once from Xcode's GUI to surface any hidden first-launch, signing, runtime, or SDK prompt that CLI output is not exposing. Keep mock mode for CLI smoke builds:

```bash
cd app
flutter build macos --debug --dart-define=LNMBOT_MOCK_MODE=true
```

Already completed by Levy:

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
