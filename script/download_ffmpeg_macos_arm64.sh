#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="8.1.1"
BUILD_ID="1778761665_8.1.1"
BASE_URL="https://ffmpeg.martin-riedl.de/download/macos/arm64/$BUILD_ID"
TARGET_ROOT="$ROOT_DIR/Vendor/FFmpeg/macos-arm64"
TARGET_BIN="$TARGET_ROOT/bin"
WORK_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$WORK_DIR"
}

trap cleanup EXIT

download_and_verify() {
  local name="$1"
  local zip_path="$WORK_DIR/$name.zip"
  local sha_path="$WORK_DIR/$name.zip.sha256"

  curl -fL "$BASE_URL/$name.zip" -o "$zip_path"
  curl -fL "$BASE_URL/$name.zip.sha256" -o "$sha_path"

  (
    cd "$WORK_DIR"
    shasum -a 256 -c "$name.zip.sha256"
    unzip -q -o "$name.zip" -d "$name"
  )

  if [[ ! -x "$WORK_DIR/$name/$name" ]]; then
    echo "Downloaded $name archive did not contain an executable $name file."
    exit 65
  fi

  cp "$WORK_DIR/$name/$name" "$TARGET_BIN/$name"
  chmod 755 "$TARGET_BIN/$name"
}

mkdir -p "$TARGET_BIN"
download_and_verify "ffmpeg"
download_and_verify "ffprobe"

cat > "$TARGET_ROOT/README.md" <<EOF
# FFmpeg Vendor Drop

PureMP3 release builds copy these local binaries into the app bundle.

- Source: https://ffmpeg.martin-riedl.de/
- Platform: macOS arm64
- FFmpeg version: $VERSION
- Build id: $BUILD_ID
- License mode: GPL enabled
- Vendored: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

The binary files are ignored by git. Recreate them with:

\`\`\`bash
script/download_ffmpeg_macos_arm64.sh
\`\`\`

Keep release license notices in sync with the exact FFmpeg build.
EOF

echo "Downloaded FFmpeg $VERSION for macOS arm64 into $TARGET_BIN"
