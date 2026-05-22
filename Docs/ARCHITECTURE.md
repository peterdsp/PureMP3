# Architecture

PureMP3 has one product goal: make high-quality MP3 conversion understandable.

## Layers

`PureMP3Core` contains the behavior that should remain stable:

- quality presets
- FFmpeg argument generation
- ffprobe JSON parsing
- size estimation
- audio honesty copy

`PureMP3App` owns platform behavior:

- SwiftUI views
- drag and drop
- file panels
- shell process execution
- queue state

## Why This Split

The app should be easy to redesign without changing audio policy. The command builder is pure Swift and covered by tests, which makes preset changes reviewable.

## Execution

PureMP3 runs FFmpeg with `Process` and an argument array. It does not concatenate a shell command for execution.

The visible command preview is only a preview.

## Future Work

Longer term, the app should introduce:

- a cancellable conversion actor
- stderr progress parsing
- a package builder
- app sandbox review
- release notarization
