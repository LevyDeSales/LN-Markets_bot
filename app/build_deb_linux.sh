#!/bin/bash
# Build lnmarkets-bot-linux_3.0.0_amd64.deb (Flutter Linux bundle)
set -e

VERSION="3.1.0"
PKG="lnmarkets-bot-linux"
DEB="${PKG}_${VERSION}_amd64.deb"
BUILD_DIR="$(mktemp -d)"
BUNDLE="$(dirname "$0")/build/linux/x64/release/bundle"

echo "=== Building $DEB ==="

DEST="$BUILD_DIR/opt/lnmarkets-bot-linux"
mkdir -p "$DEST"
mkdir -p "$BUILD_DIR/usr/local/bin"
mkdir -p "$BUILD_DIR/usr/share/applications"
mkdir -p "$BUILD_DIR/usr/share/pixmaps"
mkdir -p "$BUILD_DIR/DEBIAN"

# ── Copy Flutter bundle ────────────────────────────────────────────────────────
cp -r "$BUNDLE/." "$DEST/"

# ── Desktop launcher ───────────────────────────────────────────────────────────
cat > "$BUILD_DIR/usr/local/bin/lnmarkets-bot-linux" <<'LAUNCHER'
#!/bin/bash
exec /opt/lnmarkets-bot-linux/lnmarkets_bot "$@"
LAUNCHER
chmod 755 "$BUILD_DIR/usr/local/bin/lnmarkets-bot-linux"

# ── .desktop file ─────────────────────────────────────────────────────────────
cat > "$BUILD_DIR/usr/share/applications/lnmarkets-bot-linux.desktop" <<'DESKTOP'
[Desktop Entry]
Name=LN Markets Bot
Comment=Automated Bitcoin trading bot for LN Markets (Trend Tabajara 3.0)
Exec=/opt/lnmarkets-bot-linux/lnmarkets_bot
Icon=/usr/share/pixmaps/lnmarkets-trend-bot.png
Terminal=false
Type=Application
Categories=Finance;
StartupWMClass=lnmarkets_bot
DESKTOP
chmod 644 "$BUILD_DIR/usr/share/applications/lnmarkets-bot-linux.desktop"

# ── Icon (PNG — glowing lightning bolt) ───────────────────────────────────────
mkdir -p "$BUILD_DIR/usr/share/icons/hicolor/256x256/apps"
ICON_SRC="$(dirname "$0")/assets/icon/icon.png"
cp "$ICON_SRC" "$BUILD_DIR/usr/share/pixmaps/lnmarkets-trend-bot.png"
cp "$ICON_SRC" "$BUILD_DIR/usr/share/icons/hicolor/256x256/apps/lnmarkets-trend-bot.png"
chmod 644 "$BUILD_DIR/usr/share/pixmaps/lnmarkets-trend-bot.png"
chmod 644 "$BUILD_DIR/usr/share/icons/hicolor/256x256/apps/lnmarkets-trend-bot.png"

# ── DEBIAN/control ─────────────────────────────────────────────────────────────
SIZE=$(du -sk "$DEST" | awk '{print $1}')
cat > "$BUILD_DIR/DEBIAN/control" <<CTRL
Package: $PKG
Version: $VERSION
Section: finance
Priority: optional
Architecture: amd64
Installed-Size: $SIZE
Depends: libgtk-3-0, libblkid1, libglib2.0-0
Maintainer: unknown_BTC_usr <arthurleobertotto@gmail.com>
Description: LN Markets Trend Tabajara 3.0 Bot (Linux Desktop)
 Automated Bitcoin futures trading bot for LN Markets.
 Follows the Trend Tabajara 3.0 strategy (EMA 9/21/50 crossover).
 Supports PT-BR, EN, and FR. Take-profit and stop-loss included.
CTRL

# ── Build .deb ─────────────────────────────────────────────────────────────────
dpkg-deb --build --root-owner-group "$BUILD_DIR" "$DEB"
rm -rf "$BUILD_DIR"

echo ""
echo "✓ Package built: $DEB"
echo ""
echo "Install with:"
echo "  sudo dpkg -i $DEB"
echo "  sudo apt-get install -f"
echo ""
