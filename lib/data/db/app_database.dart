import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

// Tables
class TracksTable extends Table {
  @override
  String get tableName => 'tracks';
  TextColumn get id => text()();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class LikedTable extends Table {
  @override
  String get tableName => 'liked';
  TextColumn get trackId => text()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {trackId};
}

class RecentsTable extends Table {
  @override
  String get tableName => 'recents';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackId => text()();
  DateTimeColumn get playedAt => dateTime()();
}

class FollowedTable extends Table {
  @override
  String get tableName => 'followed';
  TextColumn get artistId => text()();
  TextColumn get json => text()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {artistId};
}

class PlaylistsTable extends Table {
  @override
  String get tableName => 'playlists';
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlaylistTracksTable extends Table {
  @override
  String get tableName => 'playlist_tracks';
  TextColumn get playlistId => text()();
  IntColumn get position => integer()();
  TextColumn get trackId => text()();
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {playlistId, position};
}

class DownloadsTable extends Table {
  @override
  String get tableName => 'downloads';
  TextColumn get trackId => text()();
  TextColumn get filePath => text()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {trackId};
}

class StreamCacheTable extends Table {
  @override
  String get tableName => 'stream_cache';
  TextColumn get videoId => text()();
  TextColumn get url => text()();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column> get primaryKey => {videoId};
}

class SongMatchesTable extends Table {
  @override
  String get tableName => 'song_matches';
  TextColumn get key => text()();
  TextColumn get trackJson => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class StatsTracksTable extends Table {
  @override
  String get tableName => 'stats_tracks';
  TextColumn get trackId => text()();
  IntColumn get plays => integer().withDefault(const Constant(0))();
  IntColumn get ms => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {trackId};
}

class StatsArtistsTable extends Table {
  @override
  String get tableName => 'stats_artists';
  TextColumn get artistId => text()();
  TextColumn get name => text()();
  TextColumn get art => text().nullable()();
  IntColumn get plays => integer().withDefault(const Constant(0))();
  IntColumn get ms => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {artistId};
}

class StatsDaysTable extends Table {
  @override
  String get tableName => 'stats_days';
  TextColumn get day => text()();
  IntColumn get ms => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {day};
}

class StatsMonthsTable extends Table {
  @override
  String get tableName => 'stats_months';
  TextColumn get month => text()();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {month};
}

class LyricOffsetsTable extends Table {
  @override
  String get tableName => 'lyric_offsets';
  TextColumn get key => text()();
  IntColumn get ms => integer()();
  BoolColumn get manual => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {key};
}

class QueueStateTable extends Table {
  @override
  String get tableName => 'queue_state';
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// DAOs
@DriftAccessor(tables: [TracksTable, LikedTable, RecentsTable, FollowedTable])
class LibraryDao extends DatabaseAccessor<AppDatabase> with _$LibraryDaoMixin {
  LibraryDao(super.attachedDatabase);

  Future<void> upsertTrack(String id, String json) {
    return into(
      tracksTable,
    ).insertOnConflictUpdate(TracksTableCompanion.insert(id: id, json: json));
  }

  Future<String?> getTrackJson(String id) async {
    final query = select(tracksTable)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row?.json;
  }

  Future<void> likeTrack(String trackId, DateTime addedAt) {
    return into(likedTable).insertOnConflictUpdate(
      LikedTableCompanion.insert(trackId: trackId, addedAt: addedAt),
    );
  }

  Future<void> unlikeTrack(String trackId) {
    return (delete(likedTable)..where((t) => t.trackId.equals(trackId))).go();
  }

  Future<bool> isLiked(String trackId) async {
    final query = select(likedTable)..where((t) => t.trackId.equals(trackId));
    final row = await query.getSingleOrNull();
    return row != null;
  }

  Stream<List<String>> watchLikedTrackIds() {
    return (select(likedTable)..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
        .map((r) => r.trackId)
        .watch();
  }

  Future<List<String>> getLikedTrackIds() {
    return (select(likedTable)..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
        .map((r) => r.trackId)
        .get();
  }

  Future<void> addRecent(String trackId, DateTime playedAt) async {
    await transaction(() async {
      await into(recentsTable).insert(
        RecentsTableCompanion.insert(trackId: trackId, playedAt: playedAt),
      );
      // Cap at 50 rows
      final countQuery = selectOnly(recentsTable)..addColumns([countAll()]);
      final count = await countQuery
          .map((row) => row.read(countAll())!)
          .getSingle();
      if (count > 50) {
        final toRemove = count - 50;
        final oldestIds =
            await (select(recentsTable)
                  ..orderBy([(t) => OrderingTerm.asc(t.playedAt)])
                  ..limit(toRemove))
                .map((r) => r.id)
                .get();
        await (delete(recentsTable)..where((t) => t.id.isIn(oldestIds))).go();
      }
    });
  }

  Future<List<String>> getRecentTrackIds(int limit) async {
    final rows = await (select(
      recentsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.playedAt)])).get();
    final seen = <String>{};
    final result = <String>[];
    for (final r in rows) {
      if (seen.add(r.trackId)) {
        result.add(r.trackId);
        if (result.length >= limit) break;
      }
    }
    return result;
  }

  Future<void> followArtist(String artistId, String json, DateTime addedAt) {
    return into(followedTable).insertOnConflictUpdate(
      FollowedTableCompanion.insert(
        artistId: artistId,
        json: json,
        addedAt: addedAt,
      ),
    );
  }

  Future<void> unfollowArtist(String artistId) {
    return (delete(
      followedTable,
    )..where((t) => t.artistId.equals(artistId))).go();
  }

  Future<bool> isFollowed(String artistId) async {
    final query = select(followedTable)
      ..where((t) => t.artistId.equals(artistId));
    final row = await query.getSingleOrNull();
    return row != null;
  }

  Future<List<String>> getFollowedArtistJsons() {
    return (select(
      followedTable,
    )..orderBy([(t) => OrderingTerm.desc(t.addedAt)])).map((r) => r.json).get();
  }

  Stream<List<String>> watchFollowedArtistJsons() {
    return (select(followedTable)
          ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
        .map((r) => r.json)
        .watch();
  }
}

@DriftAccessor(tables: [PlaylistsTable, PlaylistTracksTable])
class PlaylistDao extends DatabaseAccessor<AppDatabase>
    with _$PlaylistDaoMixin {
  PlaylistDao(super.attachedDatabase);

  Future<void> createPlaylist(String id, String name, DateTime createdAt) {
    return into(playlistsTable).insertOnConflictUpdate(
      PlaylistsTableCompanion.insert(id: id, name: name, createdAt: createdAt),
    );
  }

  Future<void> renamePlaylist(String id, String newName) {
    return (update(playlistsTable)..where((t) => t.id.equals(id))).write(
      PlaylistsTableCompanion(name: Value(newName)),
    );
  }

  Future<void> deletePlaylist(String id) async {
    await transaction(() async {
      await (delete(
        playlistTracksTable,
      )..where((t) => t.playlistId.equals(id))).go();
      await (delete(playlistsTable)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<List<PlaylistsTableData>> getAllPlaylists() {
    return (select(
      playlistsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Stream<List<PlaylistsTableData>> watchAllPlaylists() {
    return (select(
      playlistsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Future<void> addTrackToPlaylist(
    String playlistId,
    String trackId,
    int position, {
    bool pending = false,
  }) {
    return into(playlistTracksTable).insertOnConflictUpdate(
      PlaylistTracksTableCompanion.insert(
        playlistId: playlistId,
        position: position,
        trackId: trackId,
        pending: Value(pending),
      ),
    );
  }

  Future<void> removeTrackFromPlaylist(String playlistId, int position) async {
    await transaction(() async {
      await (delete(playlistTracksTable)..where(
            (t) =>
                t.playlistId.equals(playlistId) & t.position.equals(position),
          ))
          .go();
      // Re-compact positions
      final remaining =
          await (select(playlistTracksTable)
                ..where((t) => t.playlistId.equals(playlistId))
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();
      for (var i = 0; i < remaining.length; i++) {
        if (remaining[i].position != i) {
          await (update(playlistTracksTable)..where(
                (t) =>
                    t.playlistId.equals(playlistId) &
                    t.position.equals(remaining[i].position),
              ))
              .write(PlaylistTracksTableCompanion(position: Value(i)));
        }
      }
    });
  }

  Future<List<PlaylistTracksTableData>> getPlaylistTracks(String playlistId) {
    return (select(playlistTracksTable)
          ..where((t) => t.playlistId.equals(playlistId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
  }

  Future<void> clearPlaylistTracks(String playlistId) {
    return (delete(
      playlistTracksTable,
    )..where((t) => t.playlistId.equals(playlistId))).go();
  }

  Future<void> setPlaylistTracks(
    String playlistId,
    List<({String trackId, bool pending})> tracks,
  ) async {
    await transaction(() async {
      await clearPlaylistTracks(playlistId);
      for (var i = 0; i < tracks.length; i++) {
        await into(playlistTracksTable).insert(
          PlaylistTracksTableCompanion.insert(
            playlistId: playlistId,
            position: i,
            trackId: tracks[i].trackId,
            pending: Value(tracks[i].pending),
          ),
        );
      }
    });
  }
}

@DriftAccessor(tables: [DownloadsTable])
class DownloadsDao extends DatabaseAccessor<AppDatabase>
    with _$DownloadsDaoMixin {
  DownloadsDao(super.attachedDatabase);

  Future<void> insertDownload(
    String trackId,
    String filePath,
    DateTime addedAt,
  ) {
    return into(downloadsTable).insertOnConflictUpdate(
      DownloadsTableCompanion.insert(
        trackId: trackId,
        filePath: filePath,
        addedAt: addedAt,
      ),
    );
  }

  Future<void> deleteDownload(String trackId) {
    return (delete(
      downloadsTable,
    )..where((t) => t.trackId.equals(trackId))).go();
  }

  Future<DownloadsTableData?> getDownload(String trackId) {
    final query = select(downloadsTable)
      ..where((t) => t.trackId.equals(trackId));
    return query.getSingleOrNull();
  }

  Future<List<DownloadsTableData>> getAllDownloads() {
    return (select(
      downloadsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.addedAt)])).get();
  }

  Stream<List<DownloadsTableData>> watchAllDownloads() {
    return (select(
      downloadsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.addedAt)])).watch();
  }
}

@DriftAccessor(
  tables: [
    StatsTracksTable,
    StatsArtistsTable,
    StatsDaysTable,
    StatsMonthsTable,
  ],
)
class StatsDao extends DatabaseAccessor<AppDatabase> with _$StatsDaoMixin {
  StatsDao(super.attachedDatabase);

  Future<void> recordPlay({
    required String trackId,
    required String artistId,
    required String artistName,
    required int ms,
    required String dayKey,
    String? artistArt,
  }) async {
    await transaction(() async {
      // 1. stats_tracks
      final existingTrack = await (select(
        statsTracksTable,
      )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();
      if (existingTrack == null) {
        await into(statsTracksTable).insert(
          StatsTracksTableCompanion.insert(
            trackId: trackId,
            plays: const Value(1),
            ms: Value(ms),
          ),
        );
      } else {
        await (update(
          statsTracksTable,
        )..where((t) => t.trackId.equals(trackId))).write(
          StatsTracksTableCompanion(
            plays: Value(existingTrack.plays + 1),
            ms: Value(existingTrack.ms + ms),
          ),
        );
      }

      // 2. stats_artists
      final existingArtist = await (select(
        statsArtistsTable,
      )..where((t) => t.artistId.equals(artistId))).getSingleOrNull();
      if (existingArtist == null) {
        await into(statsArtistsTable).insert(
          StatsArtistsTableCompanion.insert(
            artistId: artistId,
            name: artistName,
            art: Value(artistArt),
            plays: const Value(1),
            ms: Value(ms),
          ),
        );
      } else {
        await (update(
          statsArtistsTable,
        )..where((t) => t.artistId.equals(artistId))).write(
          StatsArtistsTableCompanion(
            plays: Value(existingArtist.plays + 1),
            ms: Value(existingArtist.ms + ms),
            name: Value(artistName),
            art: artistArt != null ? Value(artistArt) : const Value.absent(),
          ),
        );
      }

      // 3. stats_days
      final existingDay = await (select(
        statsDaysTable,
      )..where((t) => t.day.equals(dayKey))).getSingleOrNull();
      if (existingDay == null) {
        await into(statsDaysTable)
            .insert(StatsDaysTableCompanion.insert(day: dayKey, ms: Value(ms)));
      } else {
        await (update(statsDaysTable)..where((t) => t.day.equals(dayKey)))
            .write(StatsDaysTableCompanion(ms: Value(existingDay.ms + ms)));
      }
    });
  }

  Future<List<StatsTracksTableData>> getTopTracks(int limit) {
    return (select(statsTracksTable)
          ..orderBy([
            (t) => OrderingTerm.desc(t.plays),
            (t) => OrderingTerm.desc(t.ms),
          ])
          ..limit(limit))
        .get();
  }

  Future<List<StatsArtistsTableData>> getTopArtists(int limit) {
    return (select(statsArtistsTable)
          ..orderBy([
            (t) => OrderingTerm.desc(t.plays),
            (t) => OrderingTerm.desc(t.ms),
          ])
          ..limit(limit))
        .get();
  }

  Future<int> getDayMs(String day) async {
    final query = select(statsDaysTable)..where((t) => t.day.equals(day));
    final row = await query.getSingleOrNull();
    return row?.ms ?? 0;
  }

  Future<List<StatsDaysTableData>> getRecentDays(int limit) {
    return (select(statsDaysTable)
          ..orderBy([(t) => OrderingTerm.desc(t.day)])
          ..limit(limit))
        .get();
  }

  Future<void> upsertMonth(String month, String json) {
    return into(statsMonthsTable).insertOnConflictUpdate(
      StatsMonthsTableCompanion.insert(month: month, json: json),
    );
  }

  Future<String?> getMonthJson(String month) async {
    final query = select(statsMonthsTable)..where((t) => t.month.equals(month));
    final row = await query.getSingleOrNull();
    return row?.json;
  }
}

@DriftAccessor(
  tables: [
    StreamCacheTable,
    SongMatchesTable,
    QueueStateTable,
    LyricOffsetsTable,
  ],
)
class CacheDao extends DatabaseAccessor<AppDatabase> with _$CacheDaoMixin {
  CacheDao(super.attachedDatabase);

  Future<void> putStreamUrl(String videoId, String url, DateTime expiresAt) {
    return into(streamCacheTable).insertOnConflictUpdate(
      StreamCacheTableCompanion.insert(
        videoId: videoId,
        url: url,
        expiresAt: expiresAt,
      ),
    );
  }

  Future<String?> getStreamUrl(String videoId) async {
    final now = DateTime.now();
    final query = select(streamCacheTable)
      ..where(
        (t) => t.videoId.equals(videoId) & t.expiresAt.isBiggerThanValue(now),
      );
    final row = await query.getSingleOrNull();
    return row?.url;
  }

  Future<void> pruneExpiredStreams() {
    final now = DateTime.now();
    return (delete(
      streamCacheTable,
    )..where((t) => t.expiresAt.isSmallerOrEqualValue(now))).go();
  }

  Future<void> putSongMatch(String key, String trackJson) {
    return into(songMatchesTable).insertOnConflictUpdate(
      SongMatchesTableCompanion.insert(key: key, trackJson: trackJson),
    );
  }

  Future<String?> getSongMatch(String key) async {
    final query = select(songMatchesTable)..where((t) => t.key.equals(key));
    final row = await query.getSingleOrNull();
    return row?.trackJson;
  }

  Future<void> saveQueueState(String json) {
    return into(queueStateTable).insertOnConflictUpdate(
      QueueStateTableCompanion.insert(id: const Value(1), json: json),
    );
  }

  Future<String?> getQueueState() async {
    final query = select(queueStateTable)..where((t) => t.id.equals(1));
    final row = await query.getSingleOrNull();
    return row?.json;
  }

  Future<void> putLyricOffset(String key, int ms, {bool manual = false}) {
    return into(lyricOffsetsTable).insertOnConflictUpdate(
      LyricOffsetsTableCompanion.insert(
        key: key,
        ms: ms,
        manual: Value(manual),
      ),
    );
  }

  Future<LyricOffsetsTableData?> getLyricOffset(String key) {
    final query = select(lyricOffsetsTable)..where((t) => t.key.equals(key));
    return query.getSingleOrNull();
  }
}

// Database
@DriftDatabase(
  tables: [
    TracksTable,
    LikedTable,
    RecentsTable,
    FollowedTable,
    PlaylistsTable,
    PlaylistTracksTable,
    DownloadsTable,
    StreamCacheTable,
    SongMatchesTable,
    StatsTracksTable,
    StatsArtistsTable,
    StatsDaysTable,
    StatsMonthsTable,
    LyricOffsetsTable,
    QueueStateTable,
  ],
  daos: [LibraryDao, PlaylistDao, DownloadsDao, StatsDao, CacheDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? driftDatabase(name: 'app'));

  @override
  int get schemaVersion => 1;
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
