#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${1:-}"
ARCH_NAME="macos-$(uname -m)"
TARGET_DIR="$ROOT_DIR/Vendor/FFmpeg/$ARCH_NAME/bin"
TARGET_ROOT="$ROOT_DIR/Vendor/FFmpeg/$ARCH_NAME"

if [[ -z "$SOURCE_DIR" ]]; then
  echo "Usage: script/vendor_ffmpeg_from_path.sh /path/to/ffmpeg/bin"
  exit 64
fi

if [[ ! -x "$SOURCE_DIR/ffmpeg" || ! -x "$SOURCE_DIR/ffprobe" ]]; then
  echo "Expected executable ffmpeg and ffprobe in: $SOURCE_DIR"
  exit 66
fi

mkdir -p "$TARGET_DIR"
cp "$SOURCE_DIR/ffmpeg" "$TARGET_DIR/ffmpeg"
cp "$SOURCE_DIR/ffprobe" "$TARGET_DIR/ffprobe"
chmod 755 "$TARGET_DIR/ffmpeg" "$TARGET_DIR/ffprobe"

if [[ -d "$(dirname "$SOURCE_DIR")/lib" ]]; then
  rm -rf "$TARGET_ROOT/lib"
  cp -R "$(dirname "$SOURCE_DIR")/lib" "$TARGET_ROOT/lib"
fi

cat > "$TARGET_ROOT/README.md" <<EOF
# FFmpeg Vendor Drop

These local binaries are copied into PureMP3.app at build time.

- Source directory: \`$SOURCE_DIR\`
- Architecture: \`$ARCH_NAME\`
- Created: \`$(date -u +"%Y-%m-%dT%H:%M:%SZ")\`

Keep the release license notices in sync with the FFmpeg build configuration.
EOF

if command -v otool >/dev/null 2>&1; then
  linked_libraries="$(otool -L "$TARGET_DIR/ffmpeg" "$TARGET_DIR/ffprobe" || true)"

  if grep -E '(/opt/homebrew|/usr/local|@rpath)' <<<"$linked_libraries" >/dev/null; then
    echo "Warning: these binaries reference Homebrew, local, or @rpath libraries."
    echo "They may not be portable unless those libraries are bundled and signed too."
    echo "For public releases, prefer a self-contained FFmpeg build."
  fi
fi

echo "Vendored FFmpeg tools into $TARGET_DIR"
