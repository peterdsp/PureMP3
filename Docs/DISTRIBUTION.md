# Distribution

PureMP3 should feel like a normal Mac app: download, open, drop files, convert. Users should not need to install FFmpeg.

## Bundle Layout

The app expects bundled tools here:

```text
PureMP3.app/Contents/Resources/FFmpeg/bin/ffmpeg
PureMP3.app/Contents/Resources/FFmpeg/bin/ffprobe
PureMP3.app/Contents/Resources/FFmpeg/lib/
```

`ShellFFmpegClient` searches that location first. `PUREMP3_FFMPEG_DIR`, Homebrew, and system paths are only development fallbacks.

## Local Release Prep

1. Download the configured macOS arm64 FFmpeg release:

```bash
script/download_ffmpeg_macos_arm64.sh
```

2. Verify the FFmpeg build license and codec configuration.
3. Build the app bundle:

```bash
script/build_and_run.sh --verify
```

4. Confirm the tools are inside the app:

```bash
test -x dist/PureMP3.app/Contents/Resources/FFmpeg/bin/ffmpeg
test -x dist/PureMP3.app/Contents/Resources/FFmpeg/bin/ffprobe
```

To use another self-contained FFmpeg build instead:

```bash
script/vendor_ffmpeg_from_path.sh /path/to/ffmpeg/bin
```

For a local zipped archive with ad-hoc signing:

```bash
script/package_release.sh
```

The archive is written to:

```text
dist/PureMP3-macos-arm64.zip
```

## Portability Check

Run:

```bash
otool -L dist/PureMP3.app/Contents/Resources/FFmpeg/bin/ffmpeg
otool -L dist/PureMP3.app/Contents/Resources/FFmpeg/bin/ffprobe
```

If the output references `/opt/homebrew`, `/usr/local`, or unresolved `@rpath` libraries, the build is not plug and play yet. Bundle and sign those libraries too, or use a self-contained FFmpeg build.

The app can launch FFmpeg with `Contents/Resources/FFmpeg/lib` on `DYLD_LIBRARY_PATH`, but absolute Homebrew library references still need a self-contained build or install-name rewriting before release.

## Signing

Public macOS distribution still needs Developer ID signing and notarization. Treat the bundled FFmpeg tools as nested executable code:

- sign `ffmpeg` and `ffprobe`
- sign the app bundle after nested tools are present
- notarize the final archive
- staple the notarization ticket before release

`script/package_release.sh` uses ad-hoc signing for local validation. That proves the bundle shape is coherent, but it is not a substitute for Developer ID signing and notarization for public downloads.

## Release Notes

Every binary release that bundles FFmpeg should include:

- FFmpeg version
- FFmpeg license mode, LGPL or GPL
- source link or source offer required by that build
- the PureMP3 version and commit SHA

See [../ThirdParty/FFmpeg-NOTICES.md](../ThirdParty/FFmpeg-NOTICES.md).
