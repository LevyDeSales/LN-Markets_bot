#!/usr/bin/env bash
# Safe setup for the migrated Flutter app.
#
# The historical script copied root-level legacy sources into app/. That flow is
# intentionally disabled because app/ is now the canonical, tested Mac ARM app.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/app"

echo "LN Markets Bot — safe Flutter setup"
echo "App root: $APP_DIR"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter not found. Install it from https://docs.flutter.dev/get-started/install"
  exit 1
fi

if [ ! -f "$APP_DIR/pubspec.yaml" ]; then
  echo "Missing $APP_DIR/pubspec.yaml"
  echo "Open/run this script from the cloned repository root."
  exit 1
fi

cd "$APP_DIR"

flutter --version | head -1
flutter pub get
flutter analyze
flutter test

if [ "${BUILD_MACOS_DEBUG:-0}" = "1" ]; then
  flutter build macos --debug
else
  echo "Skipping macOS build. Set BUILD_MACOS_DEBUG=1 to build after Xcode license/first launch is complete."
fi

echo "Safe setup complete."
