# Project Status

## Done
- Spec files read and understood
- Cloned upstream repository to `../freebify-ref`
- T-01: Create project
- T-02: Dependencies
- T-03: Folder skeleton
- T-04: Fonts & assets
- T-05: l10n
- T-06: CI
- T-07: Tokens
- T-08: ThemeData
- T-09: GlassSurface
- T-10: Shared widgets A (implemented ArtworkImage with multi-size & mirror fallback sequence, Skeletons, GlassToast with toastProvider, LiveBars animated jumping equalizer; unit & widget tests verified)
- T-11: Shared widgets B (implemented TrackTile with live bars/pending/download states, MediaCard, ArtistCard, CollageCover, SectionHeader, LargeTitleScaffold, GlassSheet, GlassSlider with scrubbing; unit and golden tests verified)
- T-12: App shell & router (implemented GoRouter appRouterProvider with StatefulShellRoute.indexedStack across /home, /search, /library, /stats, all shared & modal routes, GlassTabBar floating capsule, SettingsProvider with theme/locale/transparency via SharedPreferences, MaterialApp.router integration; tests & debug APK verified)
- CHECKPOINT B: Design system & app shell preview goldens in dark-en, light-en, dark-ar
- T-13: Models (implemented freezed + json models for Track, Artist with hasArtistPage, RemotePlaylist, LocalPlaylist, DownloadItem, StreamInfo, LyricLine, Lyrics, TrackAgg, ArtistAgg, MonthAgg, RewindData, PlaylistExport; tests for round trip and .freebify.json import passed)
- T-14: Validators (implemented isValidTrack, isValidUser, repairTrack, slimTrack, sanitizeTrackList in data/models/track_validator.dart; ported all test cases from storage.test.ts)
- T-15: Database (implemented Drift SQLite schema with 15 tables and DAOs: LibraryDao, PlaylistDao, DownloadsDao, StatsDao, CacheDao; in-memory SQLite unit tests verified)
- T-16: Http core (implemented Semaphore utility with concurrency tests; configured Dio factory with 8s connect / 15s receive timeouts, HttpLoggingInterceptor, and RetryInterceptor retrying 5xx/network errors but not 4xx)
- T-17: Innertube base (implemented InnertubeClient with session bootstrap from music.youtube.com ytcfg, WEB_REMIX context payload, limiter 4, defensive dig/digAs helpers; tool/record_fixture.dart recorded 12 real raw JSON fixtures in test/fixtures/innertube; fixture-backed tests verified)
- T-18: Innertube parsers: search & suggest (implemented SearchParser parsing top result card, song items with cleaned titles, duration, plays and album linkage, artist channels, and playlists/albums, suggestions parser; fixture unit and integration tests verified)
- T-19: Parsers: artist (implemented ArtistParser parsing profile metadata, top songs, album/single carousels, bio, and parseMpadDiscography; InnertubeClient.artist integration; fixture tests verified)
- T-20: Parsers: album/playlist (implemented PlaylistParser parsing albums and playlists with full metadata, artwork fallback, and track lists; InnertubeClient.album and InnertubeClient.playlist with VL-prefix strip/retry candidates; fixture and integration tests verified)
- T-21: Parsers: home/explore/charts/new releases/moods/mood/upNext (implemented BrowseParser and Mood models handling home/explore feeds, new releases, charts playlist resolution, 34-category mood directory, category pages, and upNext playlist panel videos; tests against all fixtures verified)
- T-22: Import matcher (implemented matcher.dart with diacritics folding, cleanText normalisation for feat/remaster/brackets/accents, firstArtist extractor, matchKey caching, scored candidate selection matchScore, and InnertubeClient.match batch resolver; tests verified)
- T-23: StreamResolver (implemented VisionOS player resolver + YouTubeExplode fallback, LRU memory cache + StreamCacheStorage SQLite DAO persistence, in-flight deduplication, prefetch & invalidate; tool/try_stream.dart CLI verified live googlevideo.com resolution; tests passed)
- T-24: Audius client (implemented AudiusClient with discovery node pool bootstrap, automatic host rotation on failure, deterministic 4xx fatal bail, ranking & originality filtering, mappers to Track/Artist/RemotePlaylist, streamUrl; unit tests passing)
- T-25: Deezer radio (implemented DeezerClient with public search/artist, related artists, top tracks round-robin, seed drop, deduplication, match integration via InnertubeClient; http_mock_adapter unit tests passing)
- T-26: CatalogRepository (implemented CatalogRepository and CatalogList with Innertube-to-Audius fallback for search, artist, album, playlist, home, trending, charts, newReleases; added fromFallback metadata flag; Riverpod FutureProvider and family with 5-minute keepAlive in catalog_providers.dart; unit tests passing)
- T-27: LibraryRepository (implemented LibraryRepository managing liked tracks, followed artists, recents capped at 50, playlists CRUD, reordering, in-place sort by title/artist/duration, placeholder resolution, dropped track cleanup, and playlistExportJson; ported all tests from library.test.ts; SQLite DAO hydration verified)

- CHECKPOINT C: Phase 2 review verified (159 passing tests, stream resolution verified via tool/try_stream.dart, live Innertube search dump verified)

- T-28: AudioHandler (implemented AwadyAudioHandler extending BaseAudioHandler with QueueHandler and SeekHandler integrating just_audio; configured AndroidManifest with audio_service, foreground service, intent filters, AudioServiceActivity in MainActivity.kt, minSdk 26; configured iOS Info.plist with UIBackgroundModes audio and awadymusic scheme; initialized in main.dart; debug APK assembled; 162 unit tests passing)

- T-29: PlayerController core (implemented PlayerController with Freezed PlayerState managing queue, history, shuffle with Spotify-style deck drain and dealing, repeat modes off/all/one, next with repeat & autoplay semantics, prev with >3s restart, seek, volume, mute, cycleRepeat, jumpTo, enqueue, playNextUp, removeAt, clearQueue, moveInQueue; unit tests passing)

- T-30: Load pipeline & fallback (implemented loadAt with loadSeq staleness prevention, downloaded-file priority via DownloadsDao, StreamResolver resolve and forceFresh cache invalidation retry, Audius search fallback on permanent stream error, and 3-auto-fail circuit breaker stop with core.noConnection notice; unit tests passing)

- T-31: Prefetch (implemented next-track prefetching at 50% playback duration with playback deduping, and VisibilityDetector-free prefetchTopTracks / prefetchTracksWithResolver helper for top 3 list items; unit tests passing)

- T-32: Radio/autoplay (implemented maybeFillRadio triggering when queue remaining < 4, normalized title and stream ID deduplication, pickRadioSeeds queue tail walking, DeezerClient radio fallback with Innertube match, and startRadio truncating upcoming queue with fresh genre mix and core.radioStarted notice; unit tests passing)

- T-33: Persistence of player (persisting sanitized queue list, index, and playback position to Drift queue_state table with 2s debounce and immediate flush on pause/background; cold boot restoration with paused state; volume, muted, shuffle, repeat, and autoplay persisted to SharedPreferences; unit tests passing)

- T-34: Sleep timer, fade, normalisation (implemented setSleepTimer with auto-pause and persistence flush verified with fake_async clock; rampVolume equal-power fade over fadeSecs/2; computeLoudnessGainDb clamping [-6, +6] dB and linear multiplier calculation; setNormOn & setFadeSecs with SharedPreferences persistence; unit tests passing)
- T-35: Android EQ (implemented lib/player/eq.dart with desktop 7-band frequencies [60, 250, 500, 1000, 4000, 8000, 14000] Hz, EqPopover.tsx presets [flat, bass, vocal, bright, vshape], mapDeviceBandToDesktopIndex nearest centre frequency mapping, detectEqPreset, platform guard safe no-op on non-Android, setEqBand, setEq, setEqPreset wired to PlayerController with SharedPreferences persistence; unit tests passing)
- T-36: Stats recorder (implemented lib/data/repositories/stats_repository.dart with StatsRepository & StatsRecorder; local dayKey and monthKey, 300 tracks & 200 artists caps with lowest-ms eviction, 120 days & 14 months caps, 15s debounced flusher, recordPlay at 30s or 50% duration; robust hydration with corrupted blob recovery; wired into PlayerController positionStream and playback state; unit tests passing)
- T-37: Rewind builder (implemented lib/player/rewind.dart with buildRewind, latestRewind, currentRewind, availableRewind, isRewindSeen, markRewindSeen, RewindController; gating constants 10 min / 5 plays closed, 3 plays partial; localized month formatting with fallback; unit tests passing)
- T-38: Mini player (implemented lib/widgets/mini_player.dart with 60h glass capsule, artwork 44 rounded 10, title/artist with Bidi RTL detection, play/pause and next controls, thin progress line at bottom edge clipped to capsule, tap to /now-playing, swipe next/prev with RTL awareness, and wired overlay in AppShell above GlassTabBar; unit & widget tests verified)
- T-39: Now Playing screen (implemented lib/features/now_playing/now_playing_screen.dart with blurred artwork background wash, top bar with close chevron and album context, big artwork with animated scale on play/pause, title/artist with Bidi RTL detection, like heart wired to LibraryRepository, GlassSlider scrubber with elapsed/remaining, shuffle/prev/big play accent circle/next/repeat controls, utility bottom row, empty pick-track state; wired to /now-playing route; widget tests verified)
- T-40: Queue sheet (implemented lib/features/queue/queue_screen.dart with Now Playing row, reorderable Next up list with Dismissible swipe-to-remove and jump-to-track, Autoplay toggle row wired to PlayerController.setAutoplay, Save queue as playlist wired to LibraryRepository, Clear queue with confirmation dialog wired to PlayerController.clearQueue; widget tests verified)
- T-41: Track menu sheet + add-to-playlist (implemented lib/widgets/track_menu_sheet.dart with track header info, Like/Unlike toggle, Add to playlist sub-sheet with user playlists and New playlist dialog, Add to queue, Play next, Start radio, Go to artist, Go to album, Share link via SharePlus & clipboard, and Remove from playlist for local playlists; wired into NowPlayingScreen and TrackTile; widget tests verified)
- T-42: Home screen (implemented lib/features/home/home_screen.dart with LargeTitleScaffold, localized greeting by hour of day, gear icon to /settings, rewind glass banner when availableRewind is present, 2x3 recently played grid with Bidi RTL support, trending tracks carousel with MediaCard, new releases carousel with RemotePlaylist cards, hot playlists carousel, CardsRowSkeleton loading state, error banner with retry button, and pull-to-refresh; 6 unit & widget tests passing)
- T-43: Search screen (implemented lib/features/search/search_screen.dart with pinned glass search input, clear button, 250ms debounced suggestions dropdown, empty browse state with Moods & moments and Browse genres grids, submitted search with 4 segmented filter chips All/Songs/Artists/Playlists, Top result card with one-tap play, Songs list with TrackTile and expandable 'More tracks', Artists horizontal carousel, Playlists horizontal carousel, empty search results state, error state with retry, and stream prefetching for top track; 9 widget tests passing)
- T-44: Genre + Mood screens (implemented lib/features/genre/genre_screen.dart with LargeTitleScaffold, kicker, segmented control for Top hits, Week, Month, All time, big Play button, track list with TrackTile; implemented lib/features/mood/mood_screen.dart with LargeTitleScaffold, playlists horizontal carousel, and top tracks list; wired routes /genre/:name, /mood/:params in app_router.dart; 7 unit & widget tests passing)
- T-45: Artist screen (implemented lib/features/artist/artist_screen.dart with stretchy header, cover photo / profile avatar, verified badge, monthly listeners, Play / Shuffle / Follow buttons, Popular tracks list with TrackTile and See all toggle, Albums horizontal carousel, Singles & EPs horizontal carousel, expandable About bio card; wired route /artist/:id in app_router.dart; 4 widget tests passing)
- T-46: Playlist/Album/Liked/Local screens (implemented lib/features/playlist/playlist_screen.dart supporting local user playlists, remote playlists, albums, liked songs, and recently played tracks; header with 220 cover, title, owner, track count, total duration, Play/Shuffle/Download all/⋯ actions; local playlist edit mode with reorderable list and delete actions; rename dialog, sort sheet by title/artist/duration, export JSON, and delete confirm dialog; Save to Library for remote playlists; pending import matching progress pill; empty local state with Find songs CTA; wired routes /playlist/:id, /library/liked, /library/recent in app_router.dart; debug APK built and verified; 9 unit & widget tests passing)
- T-47: Library screen (implemented lib/features/library/library_screen.dart with LargeTitleScaffold, import and settings header action buttons, filter chips All/Playlists/Artists/Downloads, pinned rows for Liked Songs, Downloads, and Recently played with live counts, user playlists list with CollageCover and track count, followed artists list with circular avatars, empty states, and floating glass "+ New playlist" capsule with create playlist dialog; wired into app_router.dart; 5 unit & widget tests passing)

## In Progress
- T-48: Stats screen (ui.md §4.8)

## Next
- T-49: Rewind stories (ui.md §4.9)

## Left
- 23 tasks remaining (T-48 to T-70)
