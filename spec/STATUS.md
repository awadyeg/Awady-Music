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

## In Progress
- Phase 3: Player (T-28 AudioHandler)

## Next
- T-29: PlayerController core

## Left
- 43 tasks remaining (T-28 to T-70)
