# LN Markets Bot App Test Handoff

## Local App Root

Use the local copy outside iCloud:

```bash
cd /Users/levy/Developer/LNbot/LN-Markets_bot/app
```

Do not use the iCloud Drive copy for macOS builds. iCloud/File Provider adds extended attributes that can break codesign.

## Verified Commands

These passed on 2026-06-06:

```bash
flutter analyze
flutter test
flutter build macos --debug --dart-define=LNMBOT_MOCK_MODE=true
```

The build output is:

```text
build/macos/Build/Products/Debug/lnmarkets_bot.app
```

## Test Mode

The app was built with:

```text
LNMBOT_MOCK_MODE=true
```

Manual testing should stay in mock mode. Do not enter real LN Markets credentials and do not run live/mainnet trades during this validation.

## What To Check

- The app opens on macOS.
- Home shell renders.
- Settings opens without requiring real credentials.
- Dashboard/logs screens render.
- Starting/stopping the bot uses mock services only.
- Closing the app exits cleanly.

## Reopen Command

```bash
open /Users/levy/Developer/LNbot/LN-Markets_bot/app/build/macos/Build/Products/Debug/lnmarkets_bot.app
```
