<p align="center">
  <img src="Assets/puremp3-liquid-glass-window.png" alt="PureMP3 Liquid Glass app preview" width="100%">
</p>

<h1 align="center">PureMP3</h1>

<p align="center">
  A minimal macOS app for honest, high-quality MP3 conversion.
</p>

<p align="center">
  <a href="https://github.com/peterdsp/PureMP3/actions"><img alt="CI" src="https://img.shields.io/github/actions/workflow/status/peterdsp/PureMP3/ci.yml?branch=main"></a>
  <img alt="Platform" src="https://img.shields.io/badge/platform-macOS%2014+-black">
  <img alt="Swift" src="https://img.shields.io/badge/swift-5.10-orange">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green">
</p>

PureMP3 is a small macOS app for converting video and audio files to MP3 without pretending that lossy audio has magic compression rules.

It exists because converting a video to a clean MP3 should not require remembering FFmpeg flags, opening a heavyweight encoder, or pretending that a 320 kbps MP3 can be magically compressed while staying truly 320 kbps.

Drop files in. Pick a quality preset. Convert.

## Demo

<p align="center">
  <img src="Assets/puremp3-demo.gif" alt="PureMP3 animated demo" width="100%">
</p>

The Liquid Glass direction is inspired by Lucas Romero's CSS/SVG experiment, [liquid-glass-effect-macos](https://github.com/lucasromerodb/liquid-glass-effect-macos), translated here into native SwiftUI surfaces that still build on the current macOS 14 toolchain.

## Highlights

- Drop audio or video files into a focused conversion queue
- Pick real LAME presets without digging through FFmpeg docs
- Use VBR Best, VBR Balanced, 320 kbps, 256 kbps, or 192 kbps
- Switch between full-window Glass and matte-black OLED display modes
- See the exact command PureMP3 will run
- Get warned before re-encoding an already lossy MP3
- Bundle FFmpeg and ffprobe inside the app for plug and play releases
- Keep the conversion policy in a tested Swift core module
- Ships with a custom generated macOS app icon

## Why

MP3 file size is mostly:

```text
duration x bitrate
```

If you keep real 320 kbps CBR MP3 quality, you cannot meaningfully shrink the file without changing something important:

- lower the bitrate
- use high-quality VBR
- change format
- re-encode and lose more quality

PureMP3 makes those tradeoffs explicit.

## What It Does

- Converts video and audio files to MP3
- Supports high-quality LAME presets
- Shows the exact FFmpeg command
- Warns when the source is already MP3
- Keeps the interface intentionally small
- Uses a testable Swift core instead of hiding behavior inside the UI

## Interface

PureMP3 is designed to stay out of the way:

- the queue is the product, not a settings maze
- quality choices are visible before conversion starts
- warnings are attached to the file they affect
- the FFmpeg command is visible instead of hidden behind a black box
- glass is used for hierarchy, depth, and interaction rather than decoration alone
- Glass mode uses full-window translucent surfaces with bright rim highlights
- OLED mode uses a matte-black surface system with lower glow and sharper contrast

## Quality Presets

| Preset | FFmpeg settings | Use when |
| --- | --- | --- |
| VBR Best | `-codec:a libmp3lame -q:a 0` | You want excellent quality and smaller files than fixed 320 kbps |
| VBR Balanced | `-codec:a libmp3lame -q:a 2` | You want the best practical default |
| 320 kbps | `-codec:a libmp3lame -b:a 320k` | You need maximum fixed MP3 bitrate |
| 256 kbps | `-codec:a libmp3lame -b:a 256k` | You want very good music quality with smaller files |
| 192 kbps | `-codec:a libmp3lame -b:a 192k` | You want a good general-purpose output size |

## The Rule PureMP3 Will Not Break

PureMP3 will not claim fake compression.

This is wrong:

```bash
ffmpeg -i myfile.mp3 -b:a 320k smaller.mp3
```

That re-encodes an already lossy MP3 into another MP3. It can lose quality, but it cannot restore quality or create a meaningfully smaller true 320 kbps file.

This is usually the better choice:

```bash
ffmpeg -i myfile.mp4 -vn -codec:a libmp3lame -q:a 2 myfile.mp3
```

## Plug And Play FFmpeg

PureMP3 is built to ship with FFmpeg and ffprobe inside the app bundle, so normal users do not need Homebrew, Terminal, or a separate FFmpeg install.

Release app layout:

```text
PureMP3.app/Contents/Resources/FFmpeg/bin/ffmpeg
PureMP3.app/Contents/Resources/FFmpeg/bin/ffprobe
```

Developer builds also support:

- `PUREMP3_FFMPEG_DIR`
- `/opt/homebrew/bin`
- `/usr/local/bin`
- `/usr/bin`

For release packaging, see [Docs/DISTRIBUTION.md](Docs/DISTRIBUTION.md).

## Build

```bash
git clone https://github.com/peterdsp/PureMP3.git
cd PureMP3
swift build
swift run PureMP3
```

To build a local `.app` bundle with the icon and bundled FFmpeg lookup:

```bash
script/download_ffmpeg_macos_arm64.sh
script/build_and_run.sh --verify
```

To create a local zipped app archive:

```bash
script/package_release.sh
```

## Test

```bash
swift test
```

## Architecture

PureMP3 is split into two layers:

```text
PureMP3
+-- Sources
|   +-- PureMP3App
|   |   +-- SwiftUI views
|   |   +-- app state
|   |   +-- shell FFmpeg client
|   +-- PureMP3Core
|       +-- presets
|       +-- command building
|       +-- ffprobe parsing
|       +-- size estimation
+-- Tests
    +-- PureMP3CoreTests
```

The rule is simple: conversion policy belongs in `PureMP3Core`. The app can change shape, but the audio behavior stays tested.

## Roadmap

- Real captured screenshots for each release
- Progress parsing from FFmpeg stderr
- Drag-to-reorder queue
- Conversion cancellation
- Metadata and album art preservation
- Opus, AAC, FLAC, and WAV outputs
- Homebrew cask
- Signed releases
- Localized interface
- Release pipeline for signed app bundles with bundled FFmpeg

## Contributing

Contributions are welcome if they keep the app honest, small, and useful.

Good contributions:

- improve conversion correctness
- add tests around command generation
- make the UI clearer without adding clutter
- improve accessibility
- document real audio tradeoffs

Avoid:

- fake quality claims
- growth into a generic video editor
- hidden re-encoding behavior
- adding dependencies without a strong reason

## License

PureMP3 is MIT licensed.

Bundled FFmpeg binaries keep their own license. FFmpeg licensing depends on the build configuration, so releases must include the correct FFmpeg notices, source links, and LGPL or GPL obligations.
