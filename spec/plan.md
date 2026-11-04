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
