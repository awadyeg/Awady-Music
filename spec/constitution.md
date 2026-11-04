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
