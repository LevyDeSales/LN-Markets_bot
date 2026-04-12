#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# Setup — LN Markets Flutter Bot
# Cria o projeto Flutter, copia os fontes e gera o APK.
# ──────────────────────────────────────────────────────────────────────────────
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/app"

echo "⚡  LN Markets Bot — Flutter Setup"
echo "────────────────────────────────────"

# 1. Verifica Flutter
if ! command -v flutter &>/dev/null; then
    echo "❌  Flutter não encontrado. Instale em https://docs.flutter.dev/get-started/install"
    exit 1
fi
flutter --version | head -1

# 2. Cria projeto base
if [ ! -d "$APP_DIR" ]; then
    echo ""
    echo "📦  Criando projeto Flutter..."
    flutter create --org com.unknownbtc --project-name lnmarkets_bot "$APP_DIR"
else
    echo "ℹ   Diretório $APP_DIR já existe — pulando create."
fi

# 3. Copia fontes
echo ""
echo "📋  Copiando arquivos fonte..."
cp "$SCRIPT_DIR/pubspec.yaml" "$APP_DIR/pubspec.yaml"

mkdir -p "$APP_DIR/lib/services" "$APP_DIR/lib/screens" "$APP_DIR/assets/icon"
cp "$SCRIPT_DIR/lib/main.dart"                        "$APP_DIR/lib/"
cp "$SCRIPT_DIR/lib/app_theme.dart"                   "$APP_DIR/lib/"
cp "$SCRIPT_DIR/lib/i18n.dart"                        "$APP_DIR/lib/"
cp "$SCRIPT_DIR/lib/services/"*.dart                  "$APP_DIR/lib/services/"
cp "$SCRIPT_DIR/lib/screens/"*.dart                   "$APP_DIR/lib/screens/"

# 4. Gera ícone
echo ""
echo "🎨  Gerando ícone..."
python3 "$SCRIPT_DIR/generate_icon.py"
cp "$SCRIPT_DIR/assets/icon/icon.png" "$APP_DIR/assets/icon/icon.png"

# 5. Adiciona permissão INTERNET ao AndroidManifest
MANIFEST="$APP_DIR/android/app/src/main/AndroidManifest.xml"
if ! grep -q "INTERNET" "$MANIFEST"; then
    sed -i 's|<manifest|<manifest\n    xmlns:android="http://schemas.android.com/apk/res/android"|g' \
        "$MANIFEST" 2>/dev/null || true
    sed -i '/<manifest/a \    <uses-permission android:name="android.permission.INTERNET"/>' \
        "$MANIFEST"
    echo "✓  Permissão INTERNET adicionada."
fi

# Adiciona queries para url_launcher (Android 11+)
if ! grep -q "queries" "$MANIFEST"; then
    sed -i 's|</manifest>|    <queries>\n        <intent><action android:name="android.intent.action.VIEW"/></intent>\n    </queries>\n</manifest>|' \
        "$MANIFEST"
    echo "✓  queries (url_launcher) adicionado."
fi

# 6. pub get
echo ""
echo "📥  Instalando dependências..."
cd "$APP_DIR"
flutter pub get

# 7. Gera ícones do launcher
echo ""
echo "🖼   Gerando ícones de launcher..."
dart run flutter_launcher_icons || flutter pub run flutter_launcher_icons

# 8. Build APK
echo ""
echo "🔨  Compilando APK release..."
flutter build apk --release

echo ""
echo "✅  Concluído!"
echo "   APK: $APP_DIR/build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "   Para instalar via ADB:"
echo "   adb install $APP_DIR/build/app/outputs/flutter-apk/app-release.apk"
