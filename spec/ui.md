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
