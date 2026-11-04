# Product spec

## 1. What Freebify is (desktop)
A free, ad-free, account-free music streaming desktop app with a Spotify-style UI. Metadata comes from **YouTube Music** (Innertube via `youtubei.js` in the Electron main process). Audio comes from **yt-dlp** extracted googlevideo URLs, raced against a hidden YouTube IFrame player. The **Audius** public API is the fallback catalog. Library, playlists, stats, and downloads are all local. Languages: English and Spanish. Source: `README.md`, `AGENTS.md`, `electron/*.cjs`, `src/**`.

## 2. Mobile product goal
The same experience on Android and iOS phones: search, browse, play in the background with lock-screen controls, like, build playlists, import from Spotify/YouTube/CSV, download for offline, synced lyrics, local stats and monthly Rewind. No account, no ads, no server.

## 3. Feature map: desktop → mobile
Legend: **KEEP** = same behaviour. **ADAPT** = same goal, different mechanism. **DROP** = removed (reason given). **NEW** = mobile-only addition.

| # | Desktop feature (source) | Mobile | Notes |
|---|---|---|---|
| F1 | YouTube Music search: songs, artists, playlists/albums, top result (`yt:search`, `pages/Search.tsx`) | KEEP | Dart Innertube client (plan.md §4.1) |
| F2 | Search suggestions (`yt:suggest`) | KEEP | debounce 250 ms |
| F3 | Browse genres + "Moods & moments" (`yt:moods`, `yt:mood`, `pages/Genre.tsx`, `pages/MoodPage.tsx`) | KEEP | |
| F4 | Home feed: greeting, Rewind teaser, Trending this week, Top songs, Charts, New releases, Hot playlists, Top artists, "Because you listened to X", "{mood} mixes", New for you (`pages/Home.tsx`, `yt:trending/charts/newreleases/playlists`) | KEEP | Horizontal carousels |
| F5 | Artist page: verified badge, monthly listeners, top songs + play counts, albums, singles, follow, about (`pages/Artist.tsx`, `yt:artist`) | KEEP | |
| F6 | Album / remote playlist page, "Save to Library" (`pages/Playlist.tsx`, `yt:album`, `yt:playlist`) | KEEP | |
| F7 | Audius fallback catalog when YouTube is unreachable or a track can't stream (`api/audius.ts`) | KEEP | host rotation from `https://api.audius.co`, `app_name` param |
| F8 | Playback engine: yt-dlp audio URL raced with hidden IFrame | **ADAPT** | `youtube_explode_dart` resolves the audio-only stream (m4a/opus) → `just_audio`. IFrame race is dropped (ads + ToS + no hidden webview playback in background on iOS). Fallback chain: YT stream → retry once with fresh URL → Audius search by title+artist → skip. |
| F9 | Stream URL cache ~5 h, in-flight dedup, prefetch next/top-3 (`youtube.cjs`, `prefetchStream`) | KEEP | In-memory + drift cache with expiry parsed from URL `expire=` param |
| F10 | Queue: play context, play next, add to queue, remove, reorder, clear (confirm), jump (`QueuePanel.tsx`, `player.ts`) | KEEP | Reorder via drag handle |
| F11 | Shuffle, repeat off/all/one, history | KEEP | |
| F12 | Autoplay radio when < 4 tracks remain (`maybeFillRadio`, `yt:upnext`), Deezer related-artist radio when YT runs dry (`deezer.cjs`) | KEEP | toggle in Settings + Queue |
| F13 | "Start radio" from a track | KEEP | |
| F14 | Circuit breaker: stop after 3 consecutive auto-failures | KEEP | |
| F15 | Resume last track/position on launch (`freebify-resume`) | KEEP | |
| F16 | Equalizer 7 bands (60…14k Hz), presets Flat/Bass/Bright/Vocal/V-shape (`EqPopover.tsx`, `audiobus.ts`) | **ADAPT** | Android: `AndroidEqualizer` (device bands; map 7 desktop bands to nearest device bands). iOS: hidden (open question Q3). |
| F17 | Effects: reverb, echo, drive, "Enhance" (Web Audio graph) | **DROP** | No portable equivalent in just_audio; would need native DSP. Listed in Open Questions. |
| F18 | Loudness normalisation (per-track measured gain, `freebify-loudness`) | **ADAPT** | Use YouTube's `loudnessDb` from the player response if available → `setVolume` gain; else off. |
| F19 | Crossfade seconds | **ADAPT** | Android/iOS: simple fade-out/fade-in on track change (volume ramp), not overlapping crossfade. |
| F20 | Sleep timer | KEEP | |
| F21 | Now Playing full screen: large art, dominant colour backdrop, scrubber, controls, like, queue (`NowPlaying.tsx`) | KEEP | swipe-down to close |
| F22 | Lyrics: synced (YTM timed lyrics → Musixmatch → LRCLIB → QQ), plain fallback, tap line to seek | **ADAPT** | Port YTM timed lyrics, LRCLIB, Musixmatch. QQ lyrics and the caption-based auto sync-correction (`refineOffset`, `alignOffset`) are phase 2 / optional. Manual offset: long-press a line = "sync this line to now" (replaces Shift+click), persisted per track+sheet fingerprint. |
| F23 | Liked songs, recently played, followed artists (`store/library.ts`) | KEEP | drift tables |
| F24 | Local playlists: create, rename, delete (confirm), add/remove tracks, reorder, sort by title/artist/duration, collage cover, save queue as playlist | KEEP | |
| F25 | Playlist export `.freebify.json` (`playlistExportJson`) | ADAPT | Share sheet (`share_plus`) instead of save dialog. Keep the same JSON format (`app: "freebify"`, `type: "playlist"`, `version: 1`) for interoperability with the desktop app. |
| F26 | Import playlist: Spotify link (anonymous embed token → pathfinder), YouTube Music `list=` link, CSV, `.freebify.json`; instant pending rows, background matching ~2–3 tracks/s, max 6 parallel searches, cache of matches (`ImportPlaylist.tsx`, `spotify.cjs`, `resolve.ts`) | KEEP | Also accept links via Android share intent / iOS share (NEW, small) |
| F27 | Downloads: download a track (bestaudio m4a), queue with limited concurrency, progress, play offline, delete, "Play all" (`downloads.cjs`, `pages/Downloads.tsx`) | ADAPT | dio download of the youtube_explode audio stream into app documents dir (`downloads/`), not a user-visible folder. "Open folder" → DROP (no file manager on iOS); replaced by "Export file" via share sheet. |
| F28 | Local stats: total listening time, plays, top tracks/artists, this week chart, caps (300 tracks / 200 artists / 120 days / 14 months) (`store/stats.ts`, `pages/Stats.tsx`) | KEEP | same caps |
| F29 | Monthly Rewind story (unlocks when a month closes, "so far" edition, min 10 min / 5 plays, top 5) (`store/rewind.ts`, `Rewind.tsx`) | KEEP | full-screen stories with tap-to-advance |
| F30 | Settings: autoplay, language, library stats, clear cache, export backup, shortcuts, about, check updates, logs, contribute, legal | ADAPT | see §5 |
| F31 | Full library backup export (Settings "Export") | KEEP | JSON via share sheet + NEW import-backup |
| F32 | i18n English + Spanish (`src/i18n`) | KEEP + NEW Arabic | Arabic with full RTL is NEW (requested by Mohamed) |
| F33 | Offline banner (`app.offline`) | KEEP | connectivity_plus |
| F34 | Toasts (`notify`, 4.5 s) | KEEP | glass snackbar |
| F35 | Error boundary "Something went wrong… Reload" | KEEP | `ErrorWidget.builder` + per-route error screen |
| F36 | Track ⋯ menu: like, add to playlist/new playlist, add to queue, play next, start radio, go to artist/album, copy link, download/remove download | KEEP | bottom sheet |
| F37 | Deep link scheme `freebify://` | ADAPT | own scheme (e.g. `awadymusic://`) via app_links; also handle `music.youtube.com` / `open.spotify.com/playlist` shares → Import |
| F38 | Media keys / SMTC overlay (Media Session) | ADAPT | audio_service: lock screen, notification, Bluetooth/headset buttons, Android Auto-less media session, iOS Control Center |
| F39 | Windows taskbar thumbnail toolbar, tray, frameless window controls, close-to-tray | DROP | desktop-only; notification controls replace it |
| F40 | Discord Rich Presence (`discord.cjs`) | DROP | no Discord IPC on mobile |
| F41 | Launch at login | DROP | not applicable |
| F42 | electron-updater auto-update | ADAPT | Android sideload: Settings → "Check for updates" queries GitHub Releases of the new repo and opens the APK URL. iOS: none (open question Q5) |
| F43 | Keyboard shortcuts (Space, ←/→, M, L, N) | DROP | replaced by gestures (swipe mini player = next/prev, double-tap art = like) |
| F44 | Hover prefetch | ADAPT | prefetch on list visibility of top-3 + on long-press menu open |
| F45 | yt-dlp self-update | DROP | replaced by updating the `youtube_explode_dart` dependency in releases |

## 4. User stories with acceptance criteria
Each story ID maps to tasks in tasks.md.

**US-01 Search.** As a listener I type a query and see Top result, Songs, Artists, Playlists & albums.
- AC1: results appear ≤ 2 s on 4G for a common query ("adele").
- AC2: suggestions appear while typing, debounced 250 ms.
- AC3: when YouTube fails, Audius results are shown and a small "fallback catalog" note is visible.
- AC4: empty query shows Browse genres + Moods grid; no-results shows `search.noResults` with the query.

**US-02 Play.** Tapping a song starts audio and the mini player appears.
- AC1: audio-only stream, no video, no ads.
- AC2: playback continues with screen off and app in background (Android foreground service, iOS `audio` background mode).
- AC3: lock screen / notification shows art, title, artist, play/pause, next, prev, seek.
- AC4: if the stream fails, retry once with a fresh URL, then Audius match, then skip with toast `core.unavailable`; 3 consecutive auto-failures stop playback.

**US-03 Queue & radio.** Next up list, reorder, remove, clear; autoplay similar songs fills when < 4 remain.
- AC1: drag reorder persists across app restart.
- AC2: with autoplay on, playing the last track always has ≥ 4 upcoming tracks after 3 s.

**US-04 Now Playing + lyrics.** Full-screen player with synced lyrics.
- AC1: the current lyric line is highlighted and auto-scrolls; tap a line seeks to it.
- AC2: long-press a line pins it to the current time; offset is remembered for that track+sheet.
- AC3: no lyrics → `np.noLyrics`.

**US-05 Library.** Like songs, follow artists, see recently played, create/manage playlists.
- AC1: everything survives app kill and reboot.
- AC2: delete playlist requires confirm.
- AC3: corrupted rows are skipped without crash (unit-tested).

**US-06 Import.** Paste a Spotify/YouTube Music playlist link, or pick CSV/.freebify.json.
- AC1: playlist with pending rows appears in ≤ 2 s; rows resolve in background in list order.
- AC2: tapping a pending row resolves it immediately and plays it.
- AC3: unmatched rows are dropped after one retry; a summary toast shows matched/total.

**US-07 Downloads.** Download tracks, see progress, play offline.
- AC1: in airplane mode downloaded tracks play; non-downloaded show disabled state.
- AC2: max 2 concurrent downloads; others show "Queued".
- AC3: delete removes the file and the badge.

**US-08 Stats & Rewind.** See listening stats and monthly Rewind.
- AC1: stats only count audible playback time (buffered + playing).
- AC2: Rewind banner on Home when a month closed with ≥ 10 min and ≥ 5 plays.

**US-09 Settings.** Theme (system/light/dark), language (system/en/es/ar), autoplay, EQ (Android), normalisation, crossfade, sleep timer, clear cache, export/import backup, check updates (Android), about with attribution, legal.

**US-10 Arabic & RTL.** Switching to Arabic mirrors the whole layout; numbers and durations are formatted with the locale; Latin song titles keep LTR inside RTL rows (use `Directionality`/`Bidi` per text).

## 5. Settings mapping
| Desktop setting | Mobile |
|---|---|
| Autoplay | KEEP |
| Discord presence | DROP |
| Launch at login | DROP |
| Language (en/es) | KEEP + ar + "system" |
| Library stats line | KEEP |
| Clear cache | KEEP (image + stream URL cache) |
| Export backup | KEEP (+ import backup NEW) |
| Shortcuts | DROP |
| About + versions | ADAPT (app version, `youtube_explode_dart` version, attribution) |
| Check updates | ADAPT (Android only, GitHub Releases) |
| Open logs | ADAPT ("Share logs") |
| Contribute / Legal | KEEP (links to DISCLAIMER/TERMS/PRIVACY of the new repo + upstream) |
| — | NEW: Theme mode, Wi-Fi-only downloads, stream quality (high/low) |

## 6. Non-functional requirements
- **Offline:** library, playlists, stats, downloads and settings work with no network. Offline banner shown. Remote screens show cached last result if present else an error with Retry.
- **Performance:** cold start ≤ 2.5 s on a mid-range Android (Pixel 6a class); scroll 60 fps on lists of 1 000 tracks (use `ListView.builder`, `const` widgets, image `memCacheWidth`); persisted writes debounced (stats flush every 15 s like desktop `FLUSH_MS`).
- **Battery:** no polling; position updates from just_audio streams only.
- **Accessibility:** all tappables ≥ 44×44 pt with `Semantics` labels (reuse desktop aria strings); support text scale up to 200 %; contrast ≥ 4.5:1 for text on glass (add a scrim when needed); "Reduce transparency" (iOS) / high-contrast → solid surfaces instead of blur; reduce motion respected.
- **i18n:** en, es (ported from `src/i18n/locales`), ar (new). RTL mirroring. Plurals with ICU.
- **Theme:** dark and light, follows system by default.
- **Security/privacy:** no analytics; no secrets in repo; network only to YouTube, Audius, Deezer, Spotify (import), LRCLIB, Musixmatch, GitHub (updates).
- **Platforms:** Android 8.0+ (minSdk 26), target latest SDK; iOS 15+.

## 7. Out of scope
Desktop-only features in §3 marked DROP; casting (Chromecast/AirPlay beyond the system route picker); Android Auto / CarPlay; video playback; user accounts.

## 8. Risks
- YouTube changes break extraction → keep the resolver behind an interface; Audius fallback; update `youtube_explode_dart` regularly.
- Store rejection (Play/App Store) → plan for sideload distribution.
- Innertube rate limits (403 past ~6 parallel searches, per AGENTS.md) → global semaphore of 4 for Innertube calls.

## 9. Open questions (must be answered by Mohamed before release, not before coding)
- **Q1 Name & icon.** License forbids "Freebify" name/logo. Placeholder: "Awady Music", package `com.awady.music`. Confirm.
- **Q2 Distribution.** APK sideload + iOS via AltStore/TestFlight-internal? Store listing is unlikely to pass.
- **Q3 iOS EQ.** just_audio has no iOS equalizer. Options: (a) hide EQ on iOS, (b) write a native AVAudioEngine plugin later.
- **Q4 Effects (reverb/echo/drive/enhance).** Dropped for v1. OK?
- **Q5 Updates on iOS.** None for sideloaded builds. OK?
- **Q6 Audius fallback.** Keep (recommended)?
- **Q7 Lyrics extras.** QQ lyrics and caption-based auto-sync correction postponed to v1.1. OK?
- **Q8 Repo.** Which GitHub repo hosts the port (must be public under GPL-3.0)?
