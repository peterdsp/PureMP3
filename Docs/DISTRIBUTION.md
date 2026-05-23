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

1. Download or build self-contained macOS FFmpeg binaries.
2. Verify the FFmpeg build license and codec configuration.
3. Vendor the binaries:

```bash
script/vendor_ffmpeg_from_path.sh /path/to/ffmpeg/bin
```

4. Build the app bundle:

```bash
script/build_and_run.sh --verify
```

5. Confirm the tools are inside the app:

```bash
test -x dist/PureMP3.app/Contents/Resources/FFmpeg/bin/ffmpeg
test -x dist/PureMP3.app/Contents/Resources/FFmpeg/bin/ffprobe
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

Public macOS distribution still needs signing and notarization. Treat the bundled FFmpeg tools as nested executable code:

- sign `ffmpeg` and `ffprobe`
- sign the app bundle after nested tools are present
- notarize the final archive
- staple the notarization ticket before release

## Release Notes

Every binary release that bundles FFmpeg should include:

- FFmpeg version
- FFmpeg license mode, LGPL or GPL
- source link or source offer required by that build
- the PureMP3 version and commit SHA
