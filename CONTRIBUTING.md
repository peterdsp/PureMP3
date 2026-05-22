# Contributing

PureMP3 is intentionally small. The goal is to make MP3 conversion clear, fast, and trustworthy.

## Local Setup

```bash
brew install ffmpeg
swift test
swift run PureMP3
```

## Principles

- Keep conversion behavior explicit.
- Put command-generation logic in `PureMP3Core`.
- Add tests for every new preset or FFmpeg behavior.
- Prefer native SwiftUI controls.
- Keep the app useful on the first screen.

## Pull Requests

Before opening a PR:

```bash
swift test
swift build
```

Include:

- what changed
- why it changed
- how you tested it

## Audio Claims

Do not add marketing copy that implies impossible compression.

A 320 kbps MP3 cannot become meaningfully smaller while staying a true 320 kbps MP3. PureMP3 should help users choose the right tradeoff instead of hiding it.
