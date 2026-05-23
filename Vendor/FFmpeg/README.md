# FFmpeg Vendor Directory

PureMP3 is designed to ship as a plug and play macOS app. Release builds should include `ffmpeg` and `ffprobe` inside the app bundle:

```text
PureMP3.app
+-- Contents
    +-- Resources
        +-- FFmpeg
            +-- bin
            |   +-- ffmpeg
            |   +-- ffprobe
            +-- lib
                +-- optional bundled dylibs
```

The app searches this bundled path before it checks developer fallback paths.

## Add Local Binaries

Use a self-contained FFmpeg build for release packaging:

```bash
script/vendor_ffmpeg_from_path.sh /path/to/ffmpeg/bin
script/build_and_run.sh --verify
```

The vendor script copies tools into:

```text
Vendor/FFmpeg/macos-$(uname -m)/bin
```

Those binary files are intentionally ignored by git. Keep source code small, keep release binaries traceable, and attach the reviewed app artifact to GitHub Releases.

If your FFmpeg build includes a sibling `lib` directory, the build script copies it into `Contents/Resources/FFmpeg/lib` and the app adds that folder to `DYLD_LIBRARY_PATH` when launching FFmpeg.

## Licensing

FFmpeg licensing depends on how FFmpeg is built. Some builds are LGPL, some are GPL, and codec choices can change the obligations.

Before publishing a release that bundles FFmpeg:

- record the FFmpeg source and version
- include FFmpeg license notices in the release
- confirm whether the build is LGPL or GPL
- include any required source offer or source links
- sign bundled binaries together with the app

PureMP3 source code is MIT licensed. Bundled FFmpeg binaries keep their own license.
