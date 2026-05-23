#!/usr/bin/env bash
set -euo pipefail

APP_NAME="PureMP3"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
ZIP_PATH="$DIST_DIR/${APP_NAME}-macos-arm64.zip"
FFMPEG_BIN="$APP_BUNDLE/Contents/Resources/FFmpeg/bin"

cd "$ROOT_DIR"

if [[ ! -x "$ROOT_DIR/Vendor/FFmpeg/macos-arm64/bin/ffmpeg" || ! -x "$ROOT_DIR/Vendor/FFmpeg/macos-arm64/bin/ffprobe" ]]; then
  script/download_ffmpeg_macos_arm64.sh
fi

script/build_and_run.sh --no-open --verify

if otool -L "$FFMPEG_BIN/ffmpeg" "$FFMPEG_BIN/ffprobe" | grep -E '(/opt/homebrew|/usr/local|@rpath)' >/dev/null; then
  echo "Bundled FFmpeg still references local package-manager paths."
  exit 70
fi

codesign --force --sign - --timestamp=none "$FFMPEG_BIN/ffmpeg"
codesign --force --sign - --timestamp=none "$FFMPEG_BIN/ffprobe"
codesign --force --deep --sign - --timestamp=none "$APP_BUNDLE"
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"

rm -f "$ZIP_PATH"
(
  cd "$DIST_DIR"
  COPYFILE_DISABLE=1 ditto --norsrc -c -k --keepParent "$APP_NAME.app" "$(basename "$ZIP_PATH")"
)

echo "Packaged $ZIP_PATH"
