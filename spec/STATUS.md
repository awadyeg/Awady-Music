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

## In Progress
- T-18: Innertube parsers: search & suggest

## Next
- T-19: Parsers: artist

## Left
- 53 tasks remaining (T-18 to T-70)
