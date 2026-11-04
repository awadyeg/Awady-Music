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

## In Progress
- T-14: Validators

## Next
- T-15: Database

## Left
- 57 tasks remaining (T-14 to T-70)
