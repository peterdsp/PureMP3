#!/usr/bin/env bash
set -euo pipefail

APP_NAME="PureMP3"
BUNDLE_ID="dev.peterdsp.PureMP3"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
EXECUTABLE="$ROOT_DIR/.build/debug/$APP_NAME"
ICON_FILE="$ROOT_DIR/Assets/PureMP3.icns"

cd "$ROOT_DIR"

pkill -x "$APP_NAME" 2>/dev/null || true

swift build

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"
cp "$EXECUTABLE" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

if [[ -f "$ICON_FILE" ]]; then
  cp "$ICON_FILE" "$APP_BUNDLE/Contents/Resources/PureMP3.icns"
fi

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundleIconFile</key>
  <string>PureMP3</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

/usr/bin/open -n "$APP_BUNDLE"

if [[ "${1:-}" == "--verify" ]]; then
  sleep 2
  pgrep -x "$APP_NAME" >/dev/null
fi
