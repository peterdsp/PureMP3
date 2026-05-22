# Security Policy

PureMP3 shells out to FFmpeg and ffprobe. That boundary should stay boring and explicit.

## Supported Versions

Security fixes are accepted on `main`.

## Reporting

Please report security issues privately by emailing `info@peterdsp.dev`.

Do not open public issues for command injection, sandbox escapes, malicious media handling, or packaged binary concerns.

## Security Expectations

- Never build shell strings for execution. Use `Process` with argument arrays.
- Treat media files as untrusted input.
- Do not follow symlinks or overwrite files without an explicit user action.
- Keep bundled binary licensing and provenance reviewable.
