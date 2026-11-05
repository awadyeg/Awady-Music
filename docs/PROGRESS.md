# Implementation Progress

## Phase 0: Project setup
- [x] T-01 Create project
- [x] T-02 Dependencies
- [x] T-03 Folder skeleton
- [x] T-04 Fonts & assets
- [x] T-05 l10n
- [x] T-06 CI
- **CHECKPOINT A**

## Phase 1: Design system
- [x] T-07 Tokens
- [x] T-08 ThemeData
- [x] T-09 GlassSurface
- [x] T-10 Shared widgets A
- [x] T-11 Shared widgets B
- [x] T-12 App shell & router
- **CHECKPOINT B**

## Phase 2: Data layer
- [x] T-13 Models
- [x] T-14 Validators
- [x] T-15 Database
- [x] T-16 Http core
- [x] T-17 Innertube base
- [x] T-18 Innertube parsers: search & suggest
- [x] T-19 Parsers: artist
- [x] T-20 Parsers: album/playlist
- [x] T-21 Parsers: home/explore/charts/new releases/moods/mood/upNext
- [x] T-22 Import matcher
- [x] T-23 StreamResolver
- [x] T-24 Audius client
- [x] T-25 Deezer radio
- [x] T-26 CatalogRepository
- [x] T-27 LibraryRepository
- **CHECKPOINT C: Complete (159 tests passed, stream & search verified)**

## Phase 3: Player
- [x] T-28 AudioHandler
- [x] T-29 PlayerController core
- [x] T-30 Load pipeline & fallback
- [x] T-31 Prefetch
- [x] T-32 Radio/autoplay
- [x] T-33 Persistence of player
- [x] T-34 Sleep timer, fade, normalisation
- [x] T-35 Android EQ
- [x] T-36 Stats recorder
- [x] T-37 Rewind builder
- **CHECKPOINT D: Complete (Phase 3 Player fully verified, 227 tests green)**

## Phase 4: Screens
- [x] T-38 Mini player
- [x] T-39 Now Playing
- [x] T-40 Queue sheet
- [x] T-41 Track menu sheet + add-to-playlist
- [x] T-42 Home
- [x] T-43 Search
- [x] T-44 Genre + Mood
- [x] T-45 Artist
- [x] T-46 Playlist/Album/Liked/Local
- [x] T-47 Library
- [x] T-48 Stats
- [x] T-49 Rewind stories
- [x] T-50 Sleep timer sheet
- [x] T-51 Equalizer sheet
- [x] T-52 Settings
- [x] T-53 Legal screen
- [x] T-54 Offline banner + update banner + global error screen
- **CHECKPOINT E: Complete (all screens & overlays, 324 tests passing, debug APK built)**

## Phase 5: Lyrics
- [x] T-55 LRC parser + fingerprint
- [x] T-56 YTM timed lyrics client
- [x] T-57 Musixmatch client
- [x] T-58 LRCLIB client
- [x] T-59 LyricsRepository + offsets
- [x] T-60 Lyrics UI
- **Phase 5 done (361 tests passing)**

## Phase 6: Import, downloads, backup
- [x] T-61 Spotify importer
- [x] T-62 YT Music playlist import
- [ ] T-63 CSV + .freebify.json parsing
- [ ] T-64 ImportQueue
- [ ] T-65 Import sheet UI
- [ ] T-66 Downloads
- [ ] T-67 Backup export/import
- **CHECKPOINT F**

## Phase 7: Polish & release
- [ ] T-68 Accessibility pass
- [ ] T-69 Performance pass
- [ ] T-70 Release config
- **CHECKPOINT G**
