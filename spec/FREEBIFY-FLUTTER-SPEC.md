
<!-- ===== README.md ===== -->

# Flutter mobile port of Freebify: spec kit

Source analysed: https://github.com/govu/freebify (`main`, last push 2026-10-31, v1.0.59, Electron + React 19 + TypeScript, GPL-3.0 + Freebify Attribution Clause).
Target: a Flutter app for Android and iOS. The working name is **"Awady Music"**, a placeholder (see Open Questions; the license forbids the Freebify name and logo).

This kit is written for an AI coding agent (Google Antigravity, Gemini Flash). Read the files in this order:

| # | File | What it is |
|---|------|------------|
| 1 | `constitution.md` | Non-negotiable rules: stack, packages, folder layout, lint, testing, licensing |
| 2 | `spec.md` | Product spec: every desktop feature mapped to mobile, user stories + acceptance criteria, non-functional reqs |
| 3 | `plan.md` | Architecture, Dart data models, service interfaces, desktop→mobile replacements, permissions, CI |
| 4 | `ui.md` | Every screen, navigation map, states, Liquid Glass design system (dark + light, RTL) |
| 5 | `tasks.md` | Ordered, numbered tasks in phases with checkpoints. Do them one at a time. |
| 6 | `prompts.md` | Ready-to-paste prompts for Antigravity: kickoff + one per phase |

`FREEBIFY-FLUTTER-SPEC.md` is all of the above concatenated into one file.

## Open questions (summary; details in spec.md §9)
1. App name and icon (cannot be "Freebify").
2. Distribution: sideload APK / AltStore only? Google Play and the App Store will likely reject a YouTube-audio-extraction app.
3. iOS: EQ/effects are not available through just_audio on iOS. Ship Android-only EQ, or drop it?
4. Keep the Audius fallback? (Recommended: yes, it is the legal/robust fallback.)
5. Distribution of auto-updates for sideloaded Android (in-app "new version" check against GitHub Releases?).

<!-- ===== constitution.md ===== -->

# Constitution: Flutter mobile port of Freebify

These rules override anything else. If a task conflicts with them, stop and flag it.

## 1. Principles
1. **Port behaviour, don't invent.** Every feature must trace back to a file in `govu/freebify` (cited in spec.md). No new features without an explicit "NEW" tag in spec.md.
2. **No accounts, no server, no tracking.** Like the original, all data stays on the device. No analytics SDKs, no Firebase, no crash reporters that phone home.
3. **Playback never dead-ends.** YouTube Music first, Audius fallback, circuit breaker after 3 consecutive auto-failures (desktop `MAX_AUTO_SKIPS = 3`).
4. **Instant feel.** Prefetch stream URLs for the next queue track and top-3 search/home results. Target: tap-to-sound < 1.5 s on 4G.
5. **Corrupt data never bricks the app.** Every persisted object is validated on read (port of `src/store/storage.ts` `isValidTrack`/`repairTrack`); bad rows are dropped, not thrown.
6. **One task, one commit, green build.** Each task in tasks.md ends with `flutter analyze` clean and `flutter test` green.
7. **License.** The project is GPL-3.0 with the Freebify Attribution Clause. The repo must ship `LICENSE` (copied verbatim from upstream), a `NOTICE`, and an About screen line: "Based on Freebify by govu — https://github.com/govu/freebify". It must NOT use the name "Freebify" or its logo as its own identity. The source must stay public under GPL-3.0.

## 2. Tech stack (exact)
Use the latest stable version of each package at the time of the task (`flutter pub add <name>`), never lower than the floor below. Commit `pubspec.lock`.

| Concern | Package | Floor |
|---|---|---|
| SDK | Flutter stable channel, Dart 3 | Flutter 3.35 / Dart 3.9 |
| State management | `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` (codegen) | 3.0 |
| Routing | `go_router` (with `StatefulShellRoute.indexedStack` for tabs) | 16.0 |
| Immutable models / JSON | `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation` | freezed 3.0 |
| HTTP | `dio` | 5.7 |
| YouTube stream URLs | `youtube_explode_dart` | 2.4 |
| Audio playback | `just_audio` | 0.10 |
| Background audio / lock screen / media buttons | `audio_service` + `audio_session` | 0.18 / 0.1 |
| Local DB | `drift` + `drift_flutter` + `sqlite3_flutter_libs` (dev: `drift_dev`) | drift 2.26 |
| Small key/value prefs | `shared_preferences` | 2.3 |
| Files/paths | `path_provider`, `path` | latest |
| Images | `cached_network_image` | 3.4 |
| Dominant artwork colour | `palette_generator` (or a tiny own average-colour util if discontinued) | latest |
| Glass blur | Flutter `BackdropFilter` + `ImageFilter.blur` (no package) | built-in |
| Icons | `lucide_icons_flutter` (desktop uses lucide-react) | latest |
| Font | Inter via `google_fonts` **bundled as asset** (no runtime fetch); Arabic fallback `IBM Plex Sans Arabic` bundled | n/a |
| i18n | `flutter_localizations` + `intl` + ARB files (`gen-l10n`) | built-in |
| File picking (CSV/JSON import) | `file_picker` | 8.x |
| Sharing / export | `share_plus` | 10.x |
| Deep links (`freebify://` replacement scheme) | `app_links` | 6.x |
| Connectivity banner | `connectivity_plus` | 6.x |
| Wakelock (none) | not used | n/a |
| Testing | `flutter_test`, `mocktail`, `http_mock_adapter` (for dio) | latest |
| Golden/screenshot tests | `alchemist` | latest |
| Lint | `very_good_analysis` | latest |

**Do not add** other packages without writing the reason in `docs/DECISIONS.md`.

## 3. Folder structure
```
awady_music/
  lib/
    main.dart                 # bootstrap: ProviderScope, audio_service init, drift open
    app.dart                  # MaterialApp.router, theme, locale, RTL
    core/
      theme/                  # glass tokens, ThemeData light/dark, GlassSurface widgets
      l10n/                   # arb files: app_en.arb, app_es.arb, app_ar.arb
      router/                 # go_router config, route names
      util/                   # format.dart (durations, counts), color.dart, text_clean.dart
      errors/                 # Result/Failure types
    data/
      models/                 # freezed: Track, Artist(User), Artwork, Playlist, LocalPlaylist, ...
      db/                     # drift database, tables, DAOs
      sources/
        innertube/            # YouTube Music Innertube client (search/browse/next)
        ytstream/             # youtube_explode_dart stream resolver + cache
        audius/               # Audius REST client with host rotation
        deezer/               # related-artist radio
        spotify/              # anonymous playlist import
        lyrics/               # YTM timed lyrics, LRCLIB, Musixmatch
      repositories/           # CatalogRepository, LibraryRepository, StatsRepository, DownloadsRepository, LyricsRepository
    player/
      audio_handler.dart      # audio_service BaseAudioHandler wrapping just_audio
      player_controller.dart  # Riverpod notifier: queue, index, shuffle, repeat, radio fill, circuit breaker
      eq.dart                 # Android equalizer adapter
    features/
      home/ search/ library/ playlist/ artist/ genre/ mood/ downloads/ stats/ rewind/
      now_playing/ queue/ import/ settings/
        <feature>_screen.dart, widgets/, <feature>_providers.dart
    widgets/                  # shared: TrackTile, Cards, ArtworkImage, MiniPlayer, GlassTabBar, Skeletons, Toast
  test/                       # mirrors lib/
  integration_test/
  assets/fonts/ assets/icon/
  LICENSE NOTICE README.md docs/DECISIONS.md
```

## 4. Coding rules
- `analysis_options.yaml`: `include: package:very_good_analysis/analysis_options.yaml`; allow `public_member_api_docs: false`.
- No `print`; use a `Logger` in `core/util/log.dart` writing to a rotating file in app support dir (desktop has `app:log` → main.log).
- All network calls go through repositories; widgets never call dio directly.
- All user-visible strings in ARB files (en, es, ar). No hard-coded text.
- Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start/end` only, never `left/right`, so Arabic RTL works.
- Every async UI uses `AsyncValue` and renders loading, error (with Retry), and empty states.
- Generated files (`*.g.dart`, `*.freezed.dart`) are committed. Regenerate with `dart run build_runner build -d`.

## 5. Verification commands (used by every task)
```
dart run build_runner build -d
flutter analyze
flutter test
flutter build apk --debug          # Android checkpoint
flutter build ios --no-codesign    # iOS checkpoint (macOS runner / CI only)
```

## 6. Design constitution (short; full in ui.md)
- Apple-style **Liquid Glass**: translucent blurred surfaces over content, floating capsule tab bar, large titles, continuous-corner radii, both dark and light mode follow the system (override in Settings).
- Keep the desktop's **neutral palette**: blacks/greys (dark) or whites/greys (light) with a single accent (white in dark, near-black in light). Only colour source: dominant artwork tint behind Now Playing at low opacity.
- Desktop anti-slop rules carry over (AGENTS.md "Design language"): no decorative tracked-out micro-labels, no generic sparkle/rocket icons, no spoilers on teaser cards, motion only when something causes it.

<!-- ===== spec.md ===== -->

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

<!-- ===== plan.md ===== -->

# Technical plan

## 1. Architecture
```
UI (features/*, widgets/)        Flutter widgets, go_router, Riverpod consumers
   │ watches
State (Riverpod notifiers)       PlayerController, LibraryNotifier, DownloadsNotifier, ImportQueue, StatsRecorder, SettingsNotifier
   │ calls
Repositories (data/repositories) CatalogRepository (YT → Audius fallback), LibraryRepository, LyricsRepository, DownloadsRepository, StatsRepository, ImportRepository
   │ use
Sources (data/sources)           InnertubeClient, StreamResolver, AudiusClient, DeezerClient, SpotifyImporter, LrclibClient, MusixmatchClient, YtmLyricsClient
   │
Platform                         just_audio + audio_service (AudioHandler), drift (SQLite), shared_preferences, path_provider, dio
```
Rules: UI never imports `data/sources`. Repositories return `Result<T>` (sealed `Ok`/`Err`) or throw typed `Failure`s caught into `AsyncValue.error`.

The desktop "Electron main ↔ renderer IPC" split disappears. Every `window.freebify.*` call (`electron/preload.cjs`) becomes a Dart repository method. Mapping is in §4.

## 2. Data models (Dart, freezed + json_serializable)
Ported 1:1 from `src/api/types.ts`, `src/store/*.ts`. IDs keep the desktop prefixes so `.freebify.json` and backups interoperate: tracks `yt-<videoId>` or Audius hashid, artists `yt-<channelId>`, albums `ytalb-<browseId>`, editorial playlists `ytpl-<browseId>`, local playlists `local-<base36time>-<rand4>`.

```dart
enum TrackSource { audius, yt }
enum RepeatMode { off, all, one }

@freezed
abstract class Artwork with _$Artwork {
  const factory Artwork({
    @JsonKey(name: '150x150') String? s150,
    @JsonKey(name: '480x480') String? s480,
    @JsonKey(name: '1000x1000') String? s1000,
    @Default(<String>[]) List<String> mirrors,
    String? fallback, // https://i.ytimg.com/vi/<id>/hqdefault.jpg for yt
  }) = _Artwork;
  factory Artwork.fromJson(Map<String, dynamic> j) => _$ArtworkFromJson(j);
}

@freezed
abstract class Artist with _$Artist { // desktop "User"
  const factory Artist({
    required String id,
    String? streamId,
    @Default('') String handle,
    required String name,
    String? bio,
    @Default(false) bool isVerified,
    @Default(0) int followerCount,
    @Default(0) int trackCount,
    Artwork? profilePicture,
    String? coverPhoto,
  }) = _Artist;
  factory Artist.fromJson(Map<String, dynamic> j) => _$ArtistFromJson(j);
}
// hasArtistPage(a): id not empty and not 'yt-va' and not 'yt-'  (types.ts)

@freezed
abstract class AlbumRef with _$AlbumRef {
  const factory AlbumRef({required String id, required String name}) = _AlbumRef;
  factory AlbumRef.fromJson(Map<String, dynamic> j) => _$AlbumRefFromJson(j);
}

@freezed
abstract class Track with _$Track {
  const factory Track({
    required String id,
    @Default(TrackSource.audius) TrackSource source,
    String? streamId,          // videoId for yt
    @Default(false) bool pending, // import row not matched yet
    required String title,
    @Default(0) int duration,  // seconds
    String? genre,
    @Default(0) int playCount,
    AlbumRef? album,
    Artwork? artwork,
    required Artist artist,    // desktop field "user"
    @Default(true) bool isStreamable,
  }) = _Track;
  factory Track.fromJson(Map<String, dynamic> j) => _$TrackFromJson(j);
}

@freezed
abstract class RemotePlaylist with _$RemotePlaylist { // desktop "Playlist"
  const factory RemotePlaylist({
    required String id,
    required String name,
    @Default(false) bool isAlbum,
    String? description,
    Artwork? artwork,
    @Default(0) int trackCount,
    required Artist owner,
  }) = _RemotePlaylist;
  factory RemotePlaylist.fromJson(Map<String, dynamic> j) => _$RemotePlaylistFromJson(j);
}

@freezed
abstract class LocalPlaylist with _$LocalPlaylist {
  const factory LocalPlaylist({
    required String id, required String name,
    required List<Track> tracks, required DateTime createdAt,
  }) = _LocalPlaylist;
}

@freezed
abstract class DownloadItem with _$DownloadItem {
  const factory DownloadItem({required String trackId, required String filePath,
    required DateTime addedAt, required Track track}) = _DownloadItem;
}

@freezed
abstract class StreamInfo with _$StreamInfo {
  const factory StreamInfo({required Uri url, required DateTime expiresAt,
    String? mimeType, int? bitrate, double? loudnessDb}) = _StreamInfo;
}

@freezed
abstract class LyricLine with _$LyricLine {
  const factory LyricLine({required int startMs, required String text}) = _LyricLine;
}
sealed class Lyrics { }  // SyncedLyrics(List<LyricLine> lines, String source, String fingerprint) | PlainLyrics(String text) | NoLyrics

// Stats (store/stats.ts) and Rewind (store/rewind.ts)
class TrackAgg { Track track; int plays; int ms; }
class ArtistAgg { String name; String? art; int plays; int ms; }
class MonthAgg { int ms; int plays; Map<String,TrackAgg> tracks; Map<String,ArtistAgg> artists; }
class RewindData { String key /*YYYY-MM*/; String label; String full; bool partial; int ms; int plays;
  List<TrackAgg> tracks /*top5*/; List<ArtistAgg> artists /*top5*/; int trackCount; int artistCount; }
```
Constants copied from desktop: `MAX_TRACKS=300, MAX_ARTISTS=200, MAX_DAYS=120, MAX_MONTHS=14, MAX_MONTH_TRACKS=60, MAX_MONTH_ARTISTS=40, FLUSH_MS=15000`. Rewind: `MIN_MS=10min, MIN_PLAYS=5, MIN_PLAYS_PARTIAL=3`. Radio fill threshold: `< 4` remaining. `MAX_AUTO_SKIPS=3`. EQ bands `[60,250,500,1000,4000,8000,14000]`.

## 3. Persistence (drift, file `app.sqlite`)
Tables:
- `tracks(id PK, json TEXT)`: canonical slim track cache (`slimTrack` port).
- `liked(track_id PK, added_at)`, ordered by `added_at DESC`.
- `recents(track_id, played_at)`, capped at 50 rows.
- `followed(artist_id PK, json, added_at)`.
- `playlists(id PK, name, created_at)` and `playlist_tracks(playlist_id, position, track_id, pending INT)`.
- `downloads(track_id PK, file_path, added_at)`.
- `stream_cache(video_id PK, url, expires_at)`.
- `song_matches(key PK /*normalized title|artist*/, track_json)` replaces desktop `song-matches.json`.
- `stats_tracks`, `stats_artists`, `stats_days(day PK, ms)`, `stats_months(month PK, json)`.
- `lyric_offsets(key PK /*trackId-sheetFp*/, ms, manual INT)` replaces `lrcoffa-`/`lrcoff2-` keys.
- `queue_state(id=1, json)`: queue, index, position for resume (`freebify-resume`).

`shared_preferences`: themeMode, locale, autoplay, volume, shuffle, repeat, eqGains, eqEnabled, normOn, fadeSecs, wifiOnlyDownloads, rewindSeen.

Every JSON read goes through `TrackValidator.isValid` / `repair` (port of `storage.ts`: backfill `streamId` from `yt-` id; strip `?sqp=` query from ytimg URLs; add `fallback` thumbnail).

## 4. Service interfaces & desktop IPC mapping
### 4.1 InnertubeClient (replaces `youtubei.js` in `electron/youtube.cjs`)
Raw HTTPS POST to `https://music.youtube.com/youtubei/v1/<endpoint>?prettyPrint=false` with context client `WEB_REMIX` (current clientVersion fetched from `ytcfg` on the music.youtube.com homepage once per session; also yields `visitorData`). Concurrency limiter: 4 in flight.
```dart
abstract interface class InnertubeClient {
  Future<SearchResults> search(String q);                 // yt:search  (song/artist/album filters via params)
  Future<List<String>> suggest(String q);                 // yt:suggest (music/get_search_suggestions)
  Future<ArtistPage> artist(String channelId, {String? nameHint}); // yt:artist (/browse UC…, + MPAD albums)
  Future<PlaylistPage> album(String browseId);            // yt:album
  Future<PlaylistPage> playlist(String browseId);         // yt:playlist (strip/retry VL prefix)
  Future<List<RemotePlaylist>> homePlaylists();           // yt:playlists (FEmusic_home + FEmusic_explore)
  Future<List<Track>> upNext(String videoId);             // yt:upnext (/next, PlaylistPanelVideo)
  Future<List<Track>> trending();                         // yt:trending
  Future<List<Track>> charts();                           // yt:charts (FEmusic_charts)
  Future<List<RemotePlaylist>> newReleases();             // yt:newreleases (FEmusic_new_releases)
  Future<List<MoodCategory>> moods();                     // yt:moods (FEmusic_moods_and_genres)
  Future<MoodPageData> mood(String params);               // yt:mood
  Future<List<Track?>> match(List<MatchQuery> items);     // yt:match (import; scored title/artist/duration)
}
```
Parsers must be defensive: every JSON path read with a `dig()` helper returning null, never throwing. Write parsers against **recorded fixtures** (tasks record real responses into `test/fixtures/innertube/*.json`).
Notes from AGENTS.md: explore/home items carry artist/duration/views in `flex_columns[1].title.runs`; artist full discography via `MPAD<browseId>` raw `/browse`; past ~6 parallel searches Innertube returns 403.

### 4.2 StreamResolver (replaces yt-dlp + IFrame race; `yt:stream/prefetch/invalidate`)
```dart
abstract interface class StreamResolver {
  Future<StreamInfo> resolve(String videoId, {bool forceFresh = false});
  void prefetch(String videoId);
  void invalidate(String videoId);
}
```
Implementation order (first success wins, sequential, not raced):
1. **`VisionOsPlayerResolver`**: port of desktop's in-process resolver (`electron/youtube.cjs` ~line 270): POST `https://www.youtube.com/youtubei/v1/player` with client `VISIONOS` context, matching User-Agent header, `signatureTimestamp` (STS) and `visitorData` read from one youtube.com homepage fetch per session; pick best `audio/mp4` (else `audio/webm`) from `adaptiveFormats`. Constants (clientVersion, osVersion, UA) live in one file `ytstream/client_constants.dart` because they must stay current.
2. **`YoutubeExplodeResolver`**: `youtube_explode_dart` `videos.streamsClient.getManifest(id)` → `audioOnly.withHighestBitrate()` (prefer mp4a for iOS compatibility).
3. Fail → `Failure.streamUnavailable`. PlayerController then tries Audius.
Cache: memory LRU 200 + `stream_cache` table; expiry = `expire` query param − 10 min (desktop caches ~5 h). In-flight dedup with a `Map<String, Future<StreamInfo>>`.
iOS note: AVPlayer cannot play webm/opus. Always prefer m4a/mp4a on iOS.

### 4.3 AudiusClient (`src/api/audius.ts`)
GET `https://api.audius.co` → `{data:[hosts]}`, pick random, rotate on failure; every request `?app_name=<AppName>`. Endpoints: `/v1/tracks/trending?genre&time`, `/v1/tracks/search`, `/v1/users/search`, `/v1/playlists/search`, `/v1/playlists/trending`, `/v1/playlists/{id}`, `/v1/playlists/{id}/tracks`, `/v1/users/{id}`, `/v1/users/{id}/tracks`. Stream URL: `{host}/v1/tracks/{id}/stream` (302, play directly). Skip `is_stream_gated` or `!is_streamable`. Genre strings case-sensitive.

### 4.4 Others
- `DeezerClient.radio(artist, title, limit)`: `api.deezer.com/search/artist?q=&limit=1` → `/artist/{id}/related` → `/artist/{id}/top`, then `match()` to YouTube (`electron/deezer.cjs`).
- `SpotifyImporter.import(playlistId)`: GET `https://open.spotify.com/embed/playlist/{id}`, parse `__NEXT_DATA__` for the anonymous access token, then POST `https://api-partner.spotify.com/pathfinder/v1/query` `fetchPlaylist` 100 per page, 5 pages in parallel; returns `{name, entries[{title, artist, duration}], limited}` (`electron/spotify.cjs`). Port the exact query hash from the source file.
- `YtmLyricsClient.timed(videoId)`: `/next` → lyrics tab `MPLYt…` browseId → `/browse` with `clientName: ANDROID_MUSIC`, `clientVersion: 7.21.50` → `timedLyricsData[].cueRange.startTimeMilliseconds`.
- `MusixmatchClient`: `https://apic.musixmatch.com/ws/1.1/` `token.get` (cached guest token), then `track.subtitle.get`/`macro.subtitles.get`; UA `Dalvik/2.1.0 (Linux; U; Android 9; Pixel 3)`; 8 s timeout.
- `LrclibClient`: `https://lrclib.net/api/search` with three query shapes in parallel (`track_name+artist_name`, `q`, `track_name`), then `/api/get`; trust duration only within ±25 s.
- `LyricsRepository.get(track)`: order YTM timed → Musixmatch → LRCLIB synced → any plain. Fingerprint = hash of the first 10 lines. Offset = manual pin ?? auto ?? 0.
- `ImportQueue` (`store/resolve.ts`): instant playlist with `pending` rows; background matcher concurrency 3, in order, caches to `song_matches`; drop after a retry; resume leftovers on open.
- `UpdateChecker` (Android only): GET `https://api.github.com/repos/<owner>/<repo>/releases/latest`, compare `tag_name` with `PackageInfo.version`, open the `.apk` asset URL in the browser.

## 5. Player design (port of `src/store/player.ts`)
- `AwadyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler` owns one `AudioPlayer` (just_audio). It exposes `mediaItem`, `playbackState`, `queue` to the OS.
- `PlayerController` (Riverpod `Notifier<PlayerState>`) is the single source of truth for queue/index/history/shuffle/repeat/autoplay/sleep/eq/norm/fade. It calls the handler; the handler forwards OS commands (lock screen next/prev) back to the controller.
- **Do not use `ConcatenatingAudioSource` for the whole queue.** Stream URLs expire and must be resolved lazily. Load one `AudioSource.uri` per track (`LockCachingAudioSource` is not used). Pre-resolve the next track's URL when the current one passes 50 %.
- `loadAt(i)`: bump `loadSeq`; stop; resolve (downloaded file → `AudioSource.file`; yt → StreamResolver; audius → stream URL); ignore results whose seq is stale; play. On error: if `streamRetries == 0`, invalidate and retry; else Audius fallback by `title+artist` search; else `failAdvance()`.
- `failAdvance()`: `autoFailStreak++`; if ≥ 3, stop + toast `core.noConnection`; else go to next (ignoring repeat-one).
- Radio: after each track change, if autoplay and remaining < 4, `upNext(current.streamId)` → dedupe by id and normalized title → append; if empty, Deezer radio.
- Stats: subscribe to `positionStream` while playing; add deltas to `StatsRecorder.recordMs`, flush every 15 s and on pause/track change; `recordPlay` once a track passes 30 s or 50 %.
- Sleep timer: `Timer` to pause at `sleepAt`.
- Fade: on track change ramp volume 1→0 over `fadeSecs/2`, swap, ramp 0→1.
- EQ (Android): `AudioPipeline(androidAudioEffects: [AndroidEqualizer(), AndroidLoudnessEnhancer()])`. Map desktop 7 gains to the device bands by nearest centre frequency.
- Normalisation: if `loudnessDb` known, gain = clamp(−loudnessDb, −6, +6) dB via `AndroidLoudnessEnhancer` (Android) or `setVolume` (iOS, attenuation only).

## 6. Desktop-only → mobile replacements
| Desktop | Mobile replacement |
|---|---|
| Electron main process + IPC | Dart repositories in-process (isolates for heavy JSON parse via `compute`) |
| yt-dlp binary + self-update | VISIONOS `/player` port + youtube_explode_dart |
| Hidden YouTube IFrame race | dropped |
| `<audio>` + Web Audio graph | just_audio + Android audio effects |
| Media Session / SMTC / thumbar / tray | audio_service notification, lock screen, Control Center |
| Frameless window chrome | system status bar, edge-to-edge |
| `fbx://dl/<file>` scheme | `AudioSource.file(path)` |
| `userData/downloads` + "Open folder" | `getApplicationDocumentsDirectory()/downloads` + share-sheet export |
| `app:save-json` save dialog | `share_plus` `Share.shareXFiles` |
| CSV file input | `file_picker` |
| `freebify://` protocol | `app_links` custom scheme + `https` shares of Spotify/YT Music links |
| electron-updater | GitHub Releases check (Android) |
| Discord RPC, launch at login, keyboard shortcuts | dropped |
| localStorage (zustand persist) | drift + shared_preferences |
| `main.log` | rotating log file + "Share logs" |

## 7. Platform configuration
### Android (`android/app/src/main/AndroidManifest.xml`)
- Permissions: `INTERNET`, `WAKE_LOCK`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `POST_NOTIFICATIONS` (request at first play on Android 13+), `ACCESS_NETWORK_STATE`.
- audio_service: replace `MainActivity` base with `AudioServiceActivity`; declare `com.ryanheise.audioservice.AudioService` service with `foregroundServiceType="mediaPlayback"` and the `MediaButtonReceiver`.
- Intent filters: custom scheme `awadymusic://`; `ACTION_SEND text/plain` for shared links.
- `minSdk 26`, `compileSdk/targetSdk` = latest stable; `applicationId` per Q1.
- Release signing via `key.properties` (not committed); CI uses secrets.

### iOS (`ios/Runner/Info.plist`)
- `UIBackgroundModes`: `audio`.
- `CFBundleURLTypes`: scheme `awadymusic`.
- `NSAppTransportSecurity`: default (all endpoints HTTPS).
- AudioSession category `.music()` via `audio_session` at startup.
- `LSSupportsOpeningDocumentsInPlace`/`UISupportsDocumentBrowser` not needed (file_picker handles).
- Deployment target 15.0.

## 8. Testing strategy
- Unit: models JSON round-trip; validators (`isValidTrack`, `repairTrack`) ported from `storage.test.ts`; library ops ported from `library.test.ts`; stats caps from `stats.test.ts`; rewind gating from `rewind.test.ts`; Innertube parsers on fixtures; text matching/scoring for import; LRC parser.
- Widget: each screen in loading/empty/error/data states with fake repositories.
- Golden: key screens dark+light+ar (alchemist), CI-tolerant.
- Integration (`integration_test/`): launch → search (fake repo) → play (fake audio) → like → appears in Library.
- Live smoke (manual, not CI): real search + play on device.

## 9. CI (GitHub Actions `.github/workflows/ci.yml`)
- `ubuntu-latest`: `subosito/flutter-action@v2` (channel stable, cache true) → `flutter pub get` → `dart run build_runner build -d` → `dart format --set-exit-if-changed .` → `flutter analyze` → `flutter test --coverage` → `flutter build apk --release --split-per-abi` (debug-signed if no secrets) → upload artifact `awady-music-apk`.
- `macos-latest`: `flutter build ios --release --no-codesign` → zip `Runner.app` artifact (unsigned).
- Tag `v*` → release workflow attaches APKs to a GitHub Release (used by UpdateChecker).

<!-- ===== ui.md ===== -->

# UI spec: Liquid Glass, dark + light, RTL

## 1. Design tokens (`lib/core/theme/tokens.dart`)
| Token | Dark | Light |
|---|---|---|
| `bg` (base canvas) | `#000000` | `#F2F2F7` |
| `bgElevated` | `#0E0E10` | `#FFFFFF` |
| `glassFill` | `Colors.white @ 8 %` | `Colors.white @ 62 %` |
| `glassFillStrong` (tab bar, mini player) | `white @ 12 %` | `white @ 75 %` |
| `glassStroke` (1 px hairline) | `white @ 14 %` | `black @ 8 %` |
| `glassHighlight` (top inner gradient) | `white @ 18 % → 0 %` | `white @ 90 % → 0 %` |
| `textPrimary` | `#FFFFFF` | `#0B0B0C` |
| `textDim` | `white @ 64 %` | `black @ 60 %` |
| `textFaint` | `white @ 40 %` | `black @ 38 %` |
| `accent` (single accent, desktop rule) | `#FFFFFF` | `#0B0B0C` |
| `onAccent` | `#000000` | `#FFFFFF` |
| `danger` | `#FF453A` | `#FF3B30` |
| Blur sigma | 24 (bars), 18 (cards/sheets) | same |
| Radius | 12 small, 20 cards, 28 sheets, 999 capsules (use `RoundedSuperellipseBorder` where available, else `RoundedRectangleBorder`) |
| Spacing | 4, 8, 12, 16, 20, 24, 32 |
| Type (Inter; Arabic: IBM Plex Sans Arabic) | Large title 34/700, Title 22/700, Headline 17/600, Body 15/400, Caption 12/500, Big number 48/800 (stats) |
| Motion | 220 ms `Curves.easeOutCubic` default; springs for sheets; respect `MediaQuery.disableAnimations` |

## 2. Core glass components (`lib/core/theme/glass.dart`, `lib/widgets/`)
- `GlassSurface({child, radius, strong=false})`: `ClipRSuperellipse/ClipRRect` → `BackdropFilter(blur)` → `DecoratedBox(fill, 1 px stroke, top highlight gradient)`. Falls back to solid `bgElevated` when `MediaQuery.highContrast` or the "Reduce transparency" setting (Settings → Appearance) is on.
- `GlassTabBar`: floating capsule, 64 h, margin 16 from sides and bottom safe area, 4 items (Home, Search, Library, Stats) with lucide icons + labels; selected item gets an inner pill `accent @ 14 %`.
- `MiniPlayer`: glass capsule above the tab bar (height 60), artwork 44 rounded 10, title/artist marquee, play/pause, next; thin progress line at the bottom edge; tap → Now Playing; horizontal swipe → next/prev.
- `LargeTitleScaffold`: `CustomScrollView` + `SliverAppBar.large`-style title that collapses into a glass top bar on scroll.
- `TrackTile`: artwork 48, title (1 line), artist · duration (dim), trailing ⋯; pending → spinner instead of artwork overlay; downloaded → small down-arrow badge; currently playing → `LiveBars` animated equaliser icon (port of `LiveBars.tsx`).
- `MediaCard` (album/playlist/mix): 150 square art radius 16 + 2-line title; `ArtistCard`: circular 140.
- `CollageCover`: 2×2 of first 4 track arts for local playlists.
- `GlassSheet`: modal bottom sheet with grabber, used for track menu, EQ, sleep timer, add-to-playlist.
- `GlassToast`: floating capsule above mini player, auto-hide 4.5 s.
- `Skeletons`: shimmer blocks matching each list/card shape (port of `Skeletons.tsx`).
- `ArtworkImage`: tries `s480` → `s1000` → `s150` → `mirrors` → `fallback` on error (port of `ArtworkImg.tsx`); placeholder = neutral glass square with music note.

## 3. Navigation map (go_router)
```
StatefulShellRoute (tabs, glass tab bar + mini player overlay)
├─ /home                       HomeScreen
│   ├─ /home/rewind/:month     RewindScreen (fullscreen dialog route)
├─ /search                     SearchScreen
│   ├─ /search/genre/:name     GenreScreen
│   └─ /search/mood/:params    MoodScreen
├─ /library                    LibraryScreen
│   ├─ /library/liked          PlaylistScreen(kind: liked)
│   ├─ /library/downloads      DownloadsScreen
│   └─ /library/recent         RecentScreen
└─ /stats                      StatsScreen
Shared (pushed on top of current tab, keep tab bar):
  /artist/:id   ArtistScreen
  /playlist/:id PlaylistScreen (ytpl-, ytalb-, audius id, local-)
Root-level modal routes (cover tab bar):
  /now-playing  NowPlayingScreen (slides up)
  /queue        QueueScreen (sheet over Now Playing)
  /import       ImportScreen (sheet)
  /settings     SettingsScreen (pushed from Library header gear icon and Home avatar-less gear)
  /settings/eq  EqualizerScreen
  /settings/legal LegalScreen
Deep links: awadymusic://playlist/<id>, awadymusic://artist/<id>, shared spotify/yt links → /import?url=
```
Desktop had a sidebar (`Sidebar.tsx`) with Home/Search/Library/Stats/Settings + playlists; mobile moves playlists into Library and Settings behind a gear.

## 4. Screens
For every screen: **Loading** = skeletons of the final layout (never a lone spinner). **Error** = glass card with message key + Retry button. **Empty** = icon-free friendly text + one CTA. All lists support pull-to-refresh where data is remote.

### 4.1 Home (`pages/Home.tsx`)
Layout: large title = time greeting (`home.greeting.morning/afternoon/evening/late`), gear icon trailing. Then:
1. Rewind banner glass card if available (`home.rewind.ready`/`partialReady`, button `home.rewind.watch`), no spoilers.
2. Quick grid 2×3 of recently played (glass tiles, art + title).
3. Carousels (each a section title + horizontal `MediaCard`/`TrackCard` list): "Because you listened to {name}", Trending this week, Top songs this week, Chart, New releases, Hot playlists, Top artists, "{mood} mixes", New for you.
States: loading skeleton carousels; error `home.loadError` + `home.loadErrorHint` + Retry; offline banner on top.

### 4.2 Search (`pages/Search.tsx`)
Glass search field pinned under the large title (`search.placeholder`), clear button. 
- Empty query: "Browse genres" grid (2 columns, neutral glass tiles with genre name) + "Moods & moments" grid.
- Typing: suggestions list.
- Submitted: Top result big glass card (art, name, type, Play button), then Songs (4 + "More tracks"), Artists carousel, Playlists & albums carousel. Segmented chips to filter: All / Songs / Artists / Playlists.
- No results: `search.noResults` + hint. Error: `search.failed` + `search.failedHint` + Retry.

### 4.3 Genre / Mood (`pages/Genre.tsx`, `pages/MoodPage.tsx`)
Large title = name; Genre has segmented control Week / Month / All time + Play button + track list ("Top hits · trending"). Mood shows Top tracks list, Mixes carousel, "{name} playlists" carousel.

### 4.4 Artist (`pages/Artist.tsx`)
Stretchy header with artist image fading into the background, name in large title, verified check, "{n} monthly listeners". Buttons row: Play (accent capsule), Shuffle, Follow/Following (glass capsule). Sections: Popular (top 5 with play counts, "See all"), Albums carousel, Singles carousel, About (glass card with bio, expandable).

### 4.5 Playlist / Album / Liked / Local (`pages/Playlist.tsx`)
Header: 220 cover (collage for local), title, owner · n tracks · total duration, actions: Play, Shuffle, Download all, ⋯ (Save to Library for remote; Rename, Sort (title/artist/duration), Export, Delete for local). Track list with drag handles in "Edit" mode for local playlists. Pending import rows show a spinner and a "Matching n/m" glass progress pill in the header.
Empty local: "Nothing here yet." + "Find songs" CTA → Search.

### 4.6 Library (`pages/Library.tsx`, `Sidebar.tsx`)
Large title "Your library", trailing: Import (link icon) and gear. Filter chips: Playlists / Artists / Downloads. Pinned rows: Liked Songs (count), Downloads (count), Recently played. Then list of local + saved playlists (collage art) and followed artists. FAB-style glass "+ New playlist" capsule above mini player.

### 4.7 Downloads (`pages/Downloads.tsx`)
Title + subtitle `downloads.subtitle`, Play all. Rows show progress ring when downloading, "Queued" label when queued, cancel/delete. Empty: `downloads.emptyTitle` + `emptyHint` + CTA `emptyCta`.

### 4.8 Stats (`pages/Stats.tsx`)
Large title "Your stats", subtitle `stats.subtitle`. Glass tiles: Listening time (big number), Total plays, Tracks played, Artists heard. "This week" bar chart (7 bars, accent fill; custom painter, no chart package). Top tracks (5), Top artists (5). Rewind button (`stats.rewind.full/partial`). Empty: `stats.emptyTitle`/`emptyHint`.

### 4.9 Rewind (`components/Rewind.tsx`)
Full-screen stories: progress segments at top, tap right/left = next/prev, swipe down = close. Slides: intro (month, tag), "you listened for" big minutes, top artist, top 5 songs ("The songs you couldn't stop"), summary chips (total, plays, tracks, artists), CTA "Play your top tracks". Background = dominant colour of top artwork at 35 % over black/white.

### 4.10 Now Playing (`components/NowPlaying.tsx`)
Full-screen; background = blurred artwork + dominant colour wash (desktop `utils/color.ts`). Top bar: chevron-down, "Now playing" + context name, ⋯. Big artwork (rounded 24, shrinks slightly when paused). Title (marquee), artist (tap → artist page), like heart. Scrubber (custom glass slider, `Slider.tsx`) with elapsed / remaining. Controls: shuffle, prev, big play/pause (accent circle), next, repeat (off/all/one icon). Bottom row: lyrics toggle, sleep timer, EQ (Android only), queue.
Lyrics mode: artwork shrinks to a header row; lines list with the active line full-opacity and larger, others dim; auto-scroll centred; tap = seek; long-press = sync line to now (toast "Synced"). Footnote `np.accuracyNote`. No lyrics → `np.noLyrics`. Loading → 3 shimmer lines.

### 4.11 Queue (`components/QueuePanel.tsx`)
Sheet: "Now playing" row, "Next up" reorderable list with swipe-to-remove, Autoplay toggle row (`queue.autoplay`), footer actions: Save queue as playlist, Clear (two-tap confirm `queue.clearQuestion`). Empty: `queue.empty`; end hint `queue.endHint`.

### 4.12 Track menu (⋯) sheet (`TrackTable.tsx`)
Header row (art, title, artist). Actions: Like/Unlike, Add to playlist → sub-sheet (New playlist + list), Add to queue, Play next, Start radio, Go to artist, Go to album, Download / Remove download / progress, Share link (replaces Copy link; also copies). Local playlist context adds "Remove from playlist".

### 4.13 Import (`components/ImportPlaylist.tsx`)
Sheet: URL field ("Spotify or YouTube Music playlist link") + Import button; divider; "Choose CSV or .freebify.json file" button with hint. Errors inline under the field. On success the sheet closes and navigates to the new playlist.

### 4.14 Equalizer (`components/EqPopover.tsx`) (Android)
Sheet: enable switch, preset chips (Flat, Bass, Bright, Vocal, V-shape, Custom), vertical glass sliders per device band with Hz labels, Reset. Normalize volume switch, Crossfade slider (0–12 s, "off" at 0). On iOS this entry is hidden; Normalize and Crossfade move into Settings → Playback.

### 4.15 Sleep timer sheet
Options: Off, 5, 15, 30, 45, 60 min, End of track. Shows "in {n} min" when active.

### 4.16 Settings (`pages/Settings.tsx`)
Grouped inset glass lists:
- Playback: Autoplay, Normalize volume, Crossfade, Equalizer (Android), Stream quality, Wi-Fi-only downloads.
- Appearance: Theme (System/Light/Dark), Reduce transparency, Language (System/English/Español/العربية).
- Library: "{liked} liked · {playlists} playlists", Clear cache, Export backup, Import backup.
- About: version, "Based on Freebify by govu — github.com/govu/freebify" (tappable, required by license), Check for updates (Android), Share logs, Contribute, Legal (Disclaimer, Terms, Privacy).

## 5. Global states and overlays
- Offline banner: thin glass strip under status bar, `app.offline`.
- Toasts: GlassToast.
- Update available (Android): glass card on Home top `app.updateAvail` with Download.
- Error screen (`ErrorBoundary.tsx`): `error.title`, `error.body`, button `error.reload` (re-creates ProviderScope).

## 6. RTL & Arabic rules
- `MaterialApp.supportedLocales: [en, es, ar]`; `Directionality` comes from locale automatically.
- Mirror chevrons, back gestures, progress direction; DO NOT mirror the media control icons' meaning (prev stays "previous"; icons flip visually with `Directionality`, which matches iOS/Android Arabic conventions).
- Song titles and artist names: wrap in `Text(..., textDirection: Bidi.detectRtlDirectionality(s) ? rtl : ltr)` so Latin titles stay readable in Arabic UI.
- Durations use Western digits `0-9` in all locales (music app convention); counts use `NumberFormat.compact(locale)`.

## 7. Screenshots acceptance
For checkpoint reviews produce golden PNGs for: Home, Search results, Artist, Playlist, Now Playing (+lyrics), Library, Stats, Settings, each in dark-en, light-en, dark-ar.

<!-- ===== tasks.md ===== -->

# Tasks

**How to use this file (agent):** do tasks strictly in order, one per turn. For each task:
1. Re-read the referenced spec sections.
2. Create/modify only the listed files (plus generated files).
3. Run the **Verify** command(s). All must pass.
4. Tick the task in `docs/PROGRESS.md` (`- [x] T-xx`), commit with message `T-xx: <title>`.
5. At a **CHECKPOINT**, stop and report to the human with the requested evidence. Do not continue until told.

Default verify (`V`) = `dart run build_runner build -d && dart format --set-exit-if-changed . && flutter analyze && flutter test`.
Upstream reference repo: clone `https://github.com/govu/freebify` into `../freebify-ref` (read-only) in T-01 so you can read the original TypeScript cited in each task.

---
## Phase 0: Project setup
**T-01 Create project.** `flutter create --org com.awady --project-name awady_music --platforms android,ios awady_music`. Clone upstream to `../freebify-ref`. Copy upstream `LICENSE` verbatim; create `NOTICE` (attribution line from constitution §1.7); `README.md` (one paragraph + attribution); `docs/DECISIONS.md`, `docs/PROGRESS.md` (list T-01…T-70 unchecked). DoD: `flutter run` shows the counter app. Verify: `flutter analyze && flutter build apk --debug`.

**T-02 Dependencies.** `flutter pub add` every package in constitution §2 (runtime + dev). Add `analysis_options.yaml` with very_good_analysis. Delete counter app; `lib/main.dart` shows a blank `MaterialApp`. Verify: V.

**T-03 Folder skeleton.** Create every folder in constitution §3 with a `.gitkeep`. Add `lib/core/util/log.dart` (file logger, 1 MB rotation ×3, `Log.i/w/e`). Test: writes and rotates. Verify: V.

**T-04 Fonts & assets.** Bundle Inter (variable) and IBM Plex Sans Arabic in `assets/fonts/`, declare in pubspec, `fontFamilyFallback` for Arabic. Placeholder app icon in `assets/icon/`. Verify: V.

**T-05 l10n.** `l10n.yaml` (arb-dir `lib/core/l10n`, output-class `L10n`). Create `app_en.arb` by porting ALL keys from upstream `src/i18n/locales/en/*.ts` (convert `{n}` placeholders to ICU, rename dots to camelCase e.g. `home.greeting.morning` → `homeGreetingMorning`, keep a comment with the original key). Port `es` the same way. Create `app_ar.arb` with Arabic translations of every key. Add mobile-only keys used in ui.md (theme, reduce transparency, import backup, share logs, synced, etc.) in all three. Verify: V + `flutter gen-l10n` passes with no untranslated warnings.

**T-06 CI.** `.github/workflows/ci.yml` exactly as plan.md §9. Verify: `act`-free; just YAML lint: `dart run yaml_lint` not required. Push and confirm green run (or report if no remote yet).

### CHECKPOINT A: report: package versions resolved (`flutter pub deps --style=compact | head -60`), CI status.

---
## Phase 1: Design system
**T-07 Tokens.** `lib/core/theme/tokens.dart` with every token in ui.md §1 as `ThemeExtension<GlassTokens>` (dark + light, `lerp` implemented). Test: both instances non-null, lerp works. V.

**T-08 ThemeData.** `lib/core/theme/app_theme.dart`: `AppTheme.dark()`, `AppTheme.light()` (Material 3, colourScheme from tokens, text theme from ui.md type scale, `splashFactory: NoSplash`). V.

**T-09 GlassSurface.** `lib/core/theme/glass.dart` per ui.md §2 incl. reduce-transparency fallback (reads a Riverpod `reduceTransparencyProvider` + `MediaQuery.highContrastOf`). Golden test dark/light. V.

**T-10 Shared widgets A.** `widgets/artwork_image.dart` (fallback chain), `widgets/skeletons.dart`, `widgets/glass_toast.dart` + `toastProvider`, `widgets/live_bars.dart`. Widget tests: ArtworkImage tries next URL on error (use a fake image provider). V.

**T-11 Shared widgets B.** `widgets/track_tile.dart`, `widgets/media_card.dart`, `widgets/artist_card.dart`, `widgets/collage_cover.dart`, `widgets/section_header.dart`, `widgets/large_title_scaffold.dart`, `widgets/glass_sheet.dart`, `widgets/glass_slider.dart`. Golden tests for TrackTile states (normal, playing, pending, downloaded) in dark/light/RTL. V.

**T-12 App shell & router.** `core/router/app_router.dart` with every route in ui.md §3 pointing to placeholder screens (`Text(routeName)`); `widgets/glass_tab_bar.dart`; `app.dart` with `MaterialApp.router`, theme mode + locale from `settingsProvider` (shared_preferences). Widget test: tapping tabs switches branch and preserves state. V + `flutter build apk --debug`.

### CHECKPOINT B: send screenshots (goldens) of tab bar + TrackTile + cards in dark-en, light-en, dark-ar.

---
## Phase 2: Data layer
**T-13 Models.** `data/models/*.dart` exactly as plan.md §2 (freezed + json). `hasArtistPage`. Tests: JSON round trip; parse a sample desktop `.freebify.json` export. V.

**T-14 Validators.** `data/models/track_validator.dart`: port `isValidTrack`, `isValidUser`, `repairTrack`, `slimTrack`, `sanitizeTrackList` from upstream `src/store/storage.ts`. Port the cases in `storage.test.ts` to `test/data/track_validator_test.dart`. V.

**T-15 Database.** `data/db/app_database.dart` + tables in plan.md §3 + DAOs (`LibraryDao`, `PlaylistDao`, `DownloadsDao`, `StatsDao`, `CacheDao`). Use `drift_flutter` `driftDatabase(name: 'app')`. In-memory tests (`NativeDatabase.memory()`) for each DAO. V.

**T-16 Http core.** `data/sources/http.dart`: dio factory with timeouts (connect 8 s, receive 15 s), retry interceptor (2 retries on network errors/5xx, not 4xx), logging to Log, `Semaphore` utility (`core/util/semaphore.dart`) with tests. V.

**T-17 Innertube base.** `data/sources/innertube/innertube_client.dart`: session bootstrap (GET `https://music.youtube.com/` parse `ytcfg.set({...})` for `INNERTUBE_CLIENT_VERSION`, `VISITOR_DATA`, `INNERTUBE_API_KEY`), `post(endpoint, body)`, `dig()` helper, limiter 4. Script `tool/record_fixture.dart` that saves raw responses to `test/fixtures/innertube/`. Record fixtures for: search "adele", artist (Adele channel), album, playlist, home, explore, charts, new releases, moods, one mood, next(videoId), suggestions. Tests use fixtures only (no network). V.

**T-18 Innertube parsers: search & suggest.** `parsers/search_parser.dart` → `SearchResults{top, songs, artists, playlists}`; filter non-originals like upstream (read `electron/youtube.cjs` search ~line 1050). Tests on fixture. V.

**T-19 Parsers: artist.** `parsers/artist_parser.dart` (name, verified, monthly listeners, top songs + play counts, albums, singles, bio; MPAD discography follow-up). Port from `youtube.cjs` artist section (~line 1370). Tests. V.

**T-20 Parsers: album/playlist.** VL-prefix strip/retry. Tests. V.

**T-21 Parsers: home/explore/charts/new releases/moods/mood/upNext.** Note `flex_columns[1].title.runs`. `upNext` maps `PlaylistPanelVideo`. Tests. V.

**T-22 Import matcher.** `innertube/matcher.dart`: port `cleanText` normalisation and the scoring of `yt:match` (title/artist/duration) from `youtube.cjs` ~line 2507 & 1349. Pure-function tests with tricky cases ("(feat. X)", "- Remastered 2011", accents). V.

**T-23 StreamResolver.** `data/sources/ytstream/`: `client_constants.dart`, `visionos_resolver.dart` (plan.md §4.2 step 1; port from `youtube.cjs` lines ~270–420), `explode_resolver.dart` (step 2), `stream_resolver_impl.dart` (chain, cache memory+DB, expiry from `expire=`, inflight dedup, prefer m4a on iOS). Unit tests with mocked dio + fake explode. Manual test script `tool/try_stream.dart <videoId>` printing the URL. V.

**T-24 Audius client.** `data/sources/audius/audius_client.dart` + mapper to `Track/Artist/RemotePlaylist` (plan.md §4.3). Host rotation test. V.

**T-25 Deezer radio.** `data/sources/deezer/deezer_client.dart` (plan.md §4.4). Tests with http_mock_adapter. V.

**T-26 CatalogRepository.** `data/repositories/catalog_repository.dart`: every Innertube method with Audius fallback where upstream has one (search, trending, playlists, artist), `fromFallback` flag in results. Riverpod providers in `catalog_providers.dart` (`FutureProvider.family` with keepAlive 5 min). Tests with fakes. V.

**T-27 LibraryRepository.** Port all `LibraryState` actions from `src/store/library.ts` (like, follow, recents cap, create/rename/delete/add/remove/move/sort playlists, resolveTracks, dropTracks, `playlistExportJson`). Port `library.test.ts` cases. V.

### CHECKPOINT C: report test count + output of `dart run tool/try_stream.dart dQw4w9WgXcQ` and a live `search adele` dump (first 5 songs).

---
## Phase 3: Player
**T-28 AudioHandler.** `player/audio_handler.dart` (plan.md §5), init in `main.dart` via `AudioService.init` (Android notification channel "Playback", ongoing). Android manifest + iOS Info.plist changes from plan.md §7. V + `flutter build apk --debug`.

**T-29 PlayerController core.** `player/player_controller.dart`: state fields from upstream `PlayerState` (`src/store/player.ts` line ~104) minus desktop-only; `playContext`, `playTrack`, `toggle`, `next`, `prev` (>3 s → restart), `seek`, `shuffle`, `cycleRepeat`, `jumpTo`, `enqueue`, `playNextUp`, `removeAt`, `clearQueue`, `moveInQueue`. Fake handler tests for queue semantics incl. shuffle history and repeat-one. V.

**T-30 Load pipeline & fallback.** `loadAt` with `loadSeq` staleness, downloaded-file first, resolver, retry-once, Audius fallback, `failAdvance` circuit breaker (3). Tests with fake resolver that fails N times. V.

**T-31 Prefetch.** Next-track prefetch at 50 %, top-3 search/home prefetch hook `usePrefetchOnVisible` (VisibilityDetector-free: prefetch first 3 items when list builds). V.

**T-32 Radio/autoplay.** `maybeFillRadio` (< 4 remaining, dedupe), Deezer fallback, `startRadio(track)`. Tests. V.

**T-33 Persistence of player.** Save queue/index/position to `queue_state` (debounced 2 s, and on pause/background); restore on launch paused. Volume/shuffle/repeat/autoplay to prefs. V.

**T-34 Sleep timer, fade, normalisation.** Per plan.md §5. Tests with fake clock (`fake_async`). V.

**T-35 Android EQ.** `player/eq.dart`: AndroidEqualizer wiring, preset gain tables (port presets from upstream `EqPopover.tsx`), band mapping. Platform guard: no-op on iOS. V.

**T-36 Stats recorder.** `data/repositories/stats_repository.dart` + `StatsRecorder`: port `src/store/stats.ts` (local-day keys, caps, eviction lowest-ms-first, month buckets, 15 s flush). Port `stats.test.ts`. V.

**T-37 Rewind builder.** Port `buildRewind`, `isRewindSeen`, gating constants from `src/store/rewind.ts`; port `rewind.test.ts`. V.

### CHECKPOINT D: install debug APK on a phone; record: search-free test via a hard-coded debug button "Play dQw4w9WgXcQ" → plays, background + lock-screen controls work, next/prev from notification works. Report device + Android version.

---
## Phase 4: Screens
Each screen task: implement per ui.md section, with loading/empty/error states, l10n strings, RTL-safe paddings, a widget test per state with fake providers, and goldens (dark-en, light-en, dark-ar).

**T-38 Mini player** (ui.md §2) overlay in shell. **T-39 Now Playing** (§4.10, no lyrics yet). **T-40 Queue sheet** (§4.11). **T-41 Track menu sheet + add-to-playlist** (§4.12). **T-42 Home** (§4.1). **T-43 Search** (§4.2, suggestions debounce 250 ms). **T-44 Genre + Mood** (§4.3). **T-45 Artist** (§4.4). **T-46 Playlist/Album/Liked/Local** (§4.5, edit mode, sort, rename, delete confirm, Save to Library). **T-47 Library** (§4.6). **T-48 Stats** (§4.8, custom painter bar chart). **T-49 Rewind stories** (§4.9). **T-50 Sleep timer sheet** (§4.15). **T-51 Equalizer sheet** (§4.14). **T-52 Settings** (§4.16, incl. attribution line). **T-53 Legal screen** (render bundled DISCLAIMER/TERMS/PRIVACY markdown adapted to the new app name; use `flutter_markdown`-free simple renderer or add `markdown_widget` and log decision). **T-54 Offline banner + update banner + global error screen** (§5).
Verify for each: V. After T-46 and after T-54 also `flutter build apk --debug`.

### CHECKPOINT E: send goldens for all screens in 3 variants + a 30-second screen recording of real use on device.

---
## Phase 5: Lyrics
**T-55 LRC parser + fingerprint.** `data/sources/lyrics/lrc.dart` (`[mm:ss.xx]` multi-stamps, offsets tag), tests. **T-56 YTM timed lyrics client** (plan.md §4.4), fixture tests. **T-57 Musixmatch client** (token cache in prefs, 8 s timeout). **T-58 LRCLIB client** (3 parallel query shapes + /api/get, ±25 s duration trust; port `pickLrc` logic from `NowPlaying.tsx` ~lines 840–1000). **T-59 LyricsRepository + offsets** (order, manual pin, `lyric_offsets` table). **T-60 Lyrics UI** in Now Playing (auto-scroll, tap seek, long-press sync). Verify each: V.

---
## Phase 6: Import, downloads, backup
**T-61 Spotify importer.** Port `electron/spotify.cjs` (embed token, pathfinder paging, `limited`). Fixture tests using a recorded embed page. **T-62 YT Music playlist import** via `list=` regex → `playlist()`. **T-63 CSV + .freebify.json parsing** (port `csvRows` and JSON reader from `ImportPlaylist.tsx`). **T-64 ImportQueue** (port `src/store/resolve.ts`: pending rows, concurrency 3, in order, `song_matches` cache, tap-to-resolve jump, drop after retry, resume on open). **T-65 Import sheet UI** (§4.13) + share-intent / deep-link entry (app_links + Android `ACTION_SEND`). **T-66 Downloads** (`DownloadsRepository`: dio download of resolved stream to `documents/downloads/<sanitized Artist - Title>.m4a`, `.part` then rename, concurrency 2, Wi-Fi-only option, progress stream, delete, prune missing files on start) + Downloads screen (§4.7) + menu wiring. **T-67 Backup export/import** (single JSON: liked, followed, playlists, stats, settings; import merges; share_plus/file_picker). Verify each: V.

### CHECKPOINT F: on device: import a public Spotify playlist of ~50 songs (report matched/total and time), download 3 songs, play them in airplane mode.

---
## Phase 7: Polish & release
**T-68 Accessibility pass.** Semantics labels on all icon buttons, 200 % text scale goldens for Home/Now Playing, reduce motion. **T-69 Performance pass.** `flutter run --profile`; 1 000-track playlist scroll without jank; image `memCacheWidth`; move big JSON parse to `compute`. Report frame stats. **T-70 Release config.** App name/icon per Q1, Android release signing via `key.properties` + CI secrets, versioning `1.0.0+1`, release workflow on tag `v*` uploading split APKs; Android `UpdateChecker` (plan.md §4.4). Verify: `flutter build apk --release --split-per-abi` and `flutter build ios --release --no-codesign` (CI).

### CHECKPOINT G (final): APKs, iOS unsigned build artifact, test count, open questions still unanswered.

<!-- ===== prompts.md ===== -->

# Prompts for Antigravity (Gemini Flash)

Put all 7 spec files in the new repo under `spec/` before starting. Paste the prompts below one at a time. Wait for each CHECKPOINT report before pasting the next phase prompt.

## 0. Kickoff (paste once)
```
You are building a Flutter (Android + iOS) port of the desktop music app Freebify (https://github.com/govu/freebify).
Before writing any code, read these files fully, in order: spec/README.md, spec/constitution.md, spec/spec.md, spec/plan.md, spec/ui.md, spec/tasks.md.

Rules:
- The constitution overrides everything. Use only the packages it lists.
- Work through spec/tasks.md strictly in order, ONE task at a time. Do not skip ahead, do not merge tasks.
- For each task: read the cited spec sections and the cited upstream source file in ../freebify-ref; change only the listed files; run the task's Verify command; fix until it passes; tick it in docs/PROGRESS.md; commit "T-xx: <title>".
- Never invent features. If something is ambiguous, choose the simplest option consistent with the spec, write it in docs/DECISIONS.md, and continue.
- Never weaken a test to make it pass. Never commit secrets.
- All UI strings go in ARB files (en, es, ar). Use directional paddings only (RTL).
- Stop at every CHECKPOINT and give me the evidence it asks for.
Start now with Phase 0 (T-01 to T-06), then stop at CHECKPOINT A.
```

## 1. Phase 1: Design system
```
Checkpoint A approved. Continue with Phase 1 (T-07 to T-12) from spec/tasks.md, following spec/ui.md §1–§3 exactly (Liquid Glass tokens, dark + light, reduce-transparency fallback, RTL). One task at a time, verify each. Stop at CHECKPOINT B and show the golden images.
```

## 2. Phase 2: Data layer
```
Checkpoint B approved. Do Phase 2 (T-13 to T-27). Port logic from the cited upstream files in ../freebify-ref (storage.ts, library.ts, electron/youtube.cjs, audius.ts, deezer.cjs) instead of guessing. Innertube parsers must be tested against recorded fixtures only and must never throw on missing fields (use dig()). Stop at CHECKPOINT C.
```

## 3. Phase 3: Player
```
Checkpoint C approved. Do Phase 3 (T-28 to T-37) per spec/plan.md §5 and §7. Keep a single PlayerController as source of truth; resolve stream URLs lazily per track; implement the 3-failure circuit breaker and the Audius fallback. Port stats.ts and rewind.ts with their tests. Stop at CHECKPOINT D with on-device evidence.
```

## 4. Phase 4: Screens
```
Checkpoint D approved. Do Phase 4 (T-38 to T-54). Each screen follows its spec/ui.md section exactly, has loading (skeleton), empty, error (Retry) and data states, widget tests per state, and goldens in dark-en, light-en, dark-ar. Respect the anti-slop design rules in spec/constitution.md §6. Stop at CHECKPOINT E.
```

## 5. Phase 5: Lyrics
```
Checkpoint E approved. Do Phase 5 (T-55 to T-60). Source order: YouTube Music timed lyrics, then Musixmatch, then LRCLIB, then plain. Port the LRCLIB selection rules from ../freebify-ref/src/components/NowPlaying.tsx. Long-press a line pins it to the current time, stored per track + sheet fingerprint.
```

## 6. Phase 6: Import, downloads, backup
```
Phase 5 done. Do Phase 6 (T-61 to T-67). Port electron/spotify.cjs and src/store/resolve.ts faithfully (instant pending rows, background matching in order, concurrency 3, cache, drop after one retry). Downloads go to the app documents folder, max 2 at a time. Stop at CHECKPOINT F with device evidence.
```

## 7. Phase 7: Polish & release
```
Checkpoint F approved. Do Phase 7 (T-68 to T-70). App name: <FILL IN FROM Q1>. Package id: <FILL IN>. Keep the attribution line "Based on Freebify by govu — https://github.com/govu/freebify" in Settings → About and in README/NOTICE. Stop at CHECKPOINT G with artifacts and the list of still-open questions.
```

## Recovery prompt (if the agent drifts)
```
Stop. Re-read spec/constitution.md and spec/tasks.md. Tell me which task ID you are on, what its DoD and Verify command are, and whether Verify currently passes. Revert any change not listed in that task's files, then continue with that task only.
```
