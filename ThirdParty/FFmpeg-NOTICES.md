# FFmpeg Notices

PureMP3 can bundle FFmpeg and ffprobe in binary release builds so users do not need to install FFmpeg themselves.

## Vendored Build

The current macOS arm64 packaging script downloads FFmpeg from:

```text
https://ffmpeg.martin-riedl.de/
```

Configured build:

```text
FFmpeg version: 8.1.1
Platform: macOS arm64
Build id: 1778761665_8.1.1
License mode: GPL enabled
```

## License

PureMP3 source code is MIT licensed.

FFmpeg is a separate project with separate licensing. FFmpeg binary licensing depends on the exact build configuration. Public PureMP3 releases that include FFmpeg must ship the matching FFmpeg license notices and any required source links or source offer.

Before publishing a release, verify:

- the exact FFmpeg version
- that the bundled GPL-enabled FFmpeg build is acceptable for the release
- the license text required by that build
- source code access required by that build
- notices required by enabled codecs and libraries

## Runtime Location

Release app bundles place FFmpeg tools here:

```text
PureMP3.app/Contents/Resources/FFmpeg/bin/ffmpeg
PureMP3.app/Contents/Resources/FFmpeg/bin/ffprobe
```
