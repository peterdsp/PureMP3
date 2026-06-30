# Download → Convert Roadmap

This plan adds a **Download** capability to PureMP3: paste a link, download the
audio, and run it through the existing conversion pipeline (presets, lossy-source
warnings, command preview) to MP3 or FLAC.

It is staged so each phase ships on its own and the legally simple parts land
first.

## Tooling

- **[yt-dlp](https://github.com/yt-dlp/yt-dlp)** is the engine. It supports
  YouTube (single videos **and** whole playlists) plus ~1800 other sites with the
  same interface, and it can hand audio straight to FFmpeg, which the app already
  bundles.
- Ship the **standalone `yt-dlp_macos` binary** (PyInstaller build, no Python
  runtime needed), bundled the same way FFmpeg already is:
  - `Vendor/yt-dlp/<arch>/yt-dlp`
  - a `script/download_ytdlp_macos.sh` fetch step
  - copy into `Contents/Resources` in `package_release.sh` and `build_and_run.sh`
- yt-dlp breaks whenever sites change their players, so it must be **easy to
  update** (a self-update command or a periodic re-vendor). Pin a known-good
  version and surface the version in an About/diagnostics view.

## Architecture fit

Mirror the existing FFmpeg split so audio policy stays in `PureMP3Core`:

- `PureMP3Core`
  - `DownloadRequest` (URL, kind: single / playlist / mirrored-playlist)
  - `YtDlpCommandBuilder` (pure Swift, unit-tested argument generation — the
    same pattern as `FFmpegCommandBuilder`)
  - `RemoteMediaInfo` (title, uploader, duration, thumbnail URL, playlist index)
- `PureMP3App`
  - `ShellDownloadClient` (runs `yt-dlp` with `Process`, parses progress from
    stderr) — sibling of `ShellFFmpegClient`
  - a `DownloadJob` queue alongside the conversion queue

**Key design choice:** let yt-dlp fetch only `bestaudio` (and metadata +
thumbnail), then feed the downloaded file into the **existing conversion
pipeline**. That way every download honors the chosen preset (VBR Best / Balanced
/ 320 / 256 / 192 / FLAC Lossless Ultra), the already-lossy warning, and the
visible command preview — instead of yt-dlp doing its own opaque transcode.

## UI

- Add a top-level mode switch in the title bar (or a segmented control in the
  main panel): **Convert | Download**.
- Download view: a URL field with paste support, the same quality sidebar, an
  output-folder picker, and a job list showing per-item progress
  (download % → convert % → done, reveal in Finder).
- The command-preview bar shows the real `yt-dlp …` and `ffmpeg …` commands, in
  keeping with the app's "shows the command" promise.

---

## Phase 1 — Single URL → convert

Any yt-dlp-supported site (YouTube, Vimeo, SoundCloud, direct media, etc.).

1. Validate/normalize the pasted URL.
2. `yt-dlp -J <url>` to pull metadata (title, uploader, duration, thumbnail).
3. `yt-dlp -f bestaudio -o <tmp>/<id>.%(ext)s <url>` to fetch audio.
4. Run the existing convert pipeline with the selected preset.
5. Embed metadata + thumbnail as cover art (`--embed-metadata`,
   `--embed-thumbnail`, or write tags during the FFmpeg step).
6. Progress + reveal-in-Finder, reusing the queue UI.

## Phase 2 — YouTube playlists (whole playlist)

1. Detect a playlist URL.
2. `yt-dlp --flat-playlist -J <url>` to enumerate entries without downloading.
3. Create an output **folder named after the playlist**.
4. Queue every entry; download + convert each, numbered by playlist index:
   `%(playlist_index)02d - %(title)s`.
5. Per-track metadata + artwork embedded.
6. Resilience: continue on per-item failure, show a per-row error, allow retry.

## Phase 3 — Mirror a public streaming playlist (Spotify / Apple Music / YouTube Music / Amazon)

The audio on these services is **DRM-protected and cannot be downloaded** from
them. The supported approach (as you described) is to **read the public
playlist's metadata, then source each track from YouTube**:

1. **Read the public playlist** (name, artwork, ordered track list of
   title + artist + album, ISRC when available):
   - **Spotify** — Web API public-playlist endpoints (free app client ID/secret,
     read-only). Best metadata, includes ISRC.
   - **Apple Music** — Apple Music API (developer token) or parse the public
     share page's embedded JSON.
   - **YouTube Music** — it *is* YouTube; read and download natively
     (yt-dlp / `ytmusicapi`), no mirroring needed.
   - **Amazon Music** — no free API; parse the public share page.
2. For each track, build a query (`"<artist> <title>"`) and pick the best match
   with `yt-dlp "ytsearch3:<query>"` (prefer official/topic uploads, match
   duration to avoid wrong results).
3. Download `bestaudio`, convert with the selected preset.
4. **Tag with the original source metadata + artwork** (not the YouTube title),
   and save into a folder named after the source playlist.
5. Build a per-track report: matched / low-confidence / not found, with the
   option to fix a match by hand.
6. Alternative path: instead of downloading, **recreate the playlist on the
   user's own YouTube/YouTube Music account** from the matched videos.

> Phase 3 is mostly a matching/metadata problem, not a download problem. Budget
> most of the effort for search-result disambiguation and tagging.

---

## Packaging / platform work (cuts across phases)

- Add the **network client** entitlement; keep the app sandboxed where possible.
- Bundle + sign the `yt-dlp` binary under the hardened runtime and **notarize**
  (the FFmpeg bundling already establishes this pattern).
- Some content sits behind sign-in/age walls and needs a cookies file — make
  this opt-in, never automatic.
- Surface yt-dlp/ffmpeg versions and an "update downloader" action.

## Legal / ToS — read before building Phase 3

This is the gating concern, not the engineering:

- **yt-dlp is legal, widely-used dual-use software**, and converting media you
  own or that is public-domain / Creative-Commons / your own uploads is fine.
- Downloading copyrighted tracks — **including via the YouTube-search route** —
  generally violates YouTube's Terms of Service and copyright law unless the
  content is licensed for that use or covered by a personal-use exception in the
  user's jurisdiction.
- Spotify / Apple Music / Amazon Terms **prohibit circumventing their DRM**. The
  Phase-3 design deliberately does **not** touch their audio or DRM — it only
  reads public metadata and sources audio elsewhere — but the copyright question
  above still applies.

Recommended posture for the app:
- Show a clear, dismissible notice that the user is responsible for having the
  rights to anything they download.
- Do not bundle or document any DRM-circumvention.
- Default-document the legitimate uses (own uploads, CC/public-domain, archiving
  content you have rights to).
