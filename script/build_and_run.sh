#!/usr/bin/env bash
set -euo pipefail

APP_NAME="PureMP3"
BUNDLE_ID="dev.peterdsp.PureMP3"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
EXECUTABLE="$ROOT_DIR/.build/debug/$APP_NAME"
ICON_FILE="$ROOT_DIR/Assets/PureMP3.icns"
ARCH_NAME="macos-$(uname -m)"
FFMPEG_RESOURCE_DIR="$APP_BUNDLE/Contents/Resources/FFmpeg/bin"
FFMPEG_VENDOR_DIR="$ROOT_DIR/Vendor/FFmpeg/$ARCH_NAME/bin"
FFMPEG_UNIVERSAL_VENDOR_DIR="$ROOT_DIR/Vendor/FFmpeg/macos-universal/bin"

cd "$ROOT_DIR"

pkill -x "$APP_NAME" 2>/dev/null || true

swift build

copy_ffmpeg_tools() {
  local source_dir=""

  if [[ -x "$FFMPEG_VENDOR_DIR/ffmpeg" && -x "$FFMPEG_VENDOR_DIR/ffprobe" ]]; then
    source_dir="$FFMPEG_VENDOR_DIR"
  elif [[ -x "$FFMPEG_UNIVERSAL_VENDOR_DIR/ffmpeg" && -x "$FFMPEG_UNIVERSAL_VENDOR_DIR/ffprobe" ]]; then
    source_dir="$FFMPEG_UNIVERSAL_VENDOR_DIR"
  else
    local ffmpeg_path
    local ffprobe_path
    ffmpeg_path="$(command -v ffmpeg || true)"
    ffprobe_path="$(command -v ffprobe || true)"

    if [[ -n "$ffmpeg_path" && -n "$ffprobe_path" ]]; then
      source_dir="$(mktemp -d)"
      cp "$ffmpeg_path" "$source_dir/ffmpeg"
      cp "$ffprobe_path" "$source_dir/ffprobe"
      echo "Using local FFmpeg for this development bundle."
      echo "For release, vendor self-contained FFmpeg binaries under Vendor/FFmpeg/$ARCH_NAME/bin."
    fi
  fi

  if [[ -z "$source_dir" ]]; then
    echo "FFmpeg was not bundled. The app can still use PUREMP3_FFMPEG_DIR or a developer FFmpeg install."
    return
  fi

  mkdir -p "$FFMPEG_RESOURCE_DIR"
  cp "$source_dir/ffmpeg" "$FFMPEG_RESOURCE_DIR/ffmpeg"
  cp "$source_dir/ffprobe" "$FFMPEG_RESOURCE_DIR/ffprobe"
  chmod 755 "$FFMPEG_RESOURCE_DIR/ffmpeg" "$FFMPEG_RESOURCE_DIR/ffprobe"

  if [[ -d "$(dirname "$source_dir")/lib" ]]; then
    cp -R "$(dirname "$source_dir")/lib" "$APP_BUNDLE/Contents/Resources/FFmpeg/lib"
  fi
}

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"
cp "$EXECUTABLE" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

if [[ -f "$ICON_FILE" ]]; then
  cp "$ICON_FILE" "$APP_BUNDLE/Contents/Resources/PureMP3.icns"
fi

copy_ffmpeg_tools

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
