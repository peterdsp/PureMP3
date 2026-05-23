# FFmpeg Vendor Drop

PureMP3 release builds copy these local binaries into the app bundle.

- Source: https://ffmpeg.martin-riedl.de/
- Platform: macOS arm64
- FFmpeg version: 8.1.1
- Build id: 1778761665_8.1.1
- License mode: GPL enabled
- Vendored: 2026-05-23T12:27:52Z

The binary files are ignored by git. Recreate them with:

```bash
script/download_ffmpeg_macos_arm64.sh
```

Keep release license notices in sync with the exact FFmpeg build.
