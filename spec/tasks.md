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
