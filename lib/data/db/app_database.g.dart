// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$LibraryDaoMixin on DatabaseAccessor<AppDatabase> {
  $TracksTableTable get tracksTable => attachedDatabase.tracksTable;
  $LikedTableTable get likedTable => attachedDatabase.likedTable;
  $RecentsTableTable get recentsTable => attachedDatabase.recentsTable;
  $FollowedTableTable get followedTable => attachedDatabase.followedTable;
  LibraryDaoManager get managers => LibraryDaoManager(this);
}

class LibraryDaoManager {
  final _$LibraryDaoMixin _db;
  LibraryDaoManager(this._db);
  $$TracksTableTableTableManager get tracksTable =>
      $$TracksTableTableTableManager(_db.attachedDatabase, _db.tracksTable);
  $$LikedTableTableTableManager get likedTable =>
      $$LikedTableTableTableManager(_db.attachedDatabase, _db.likedTable);
  $$RecentsTableTableTableManager get recentsTable =>
      $$RecentsTableTableTableManager(_db.attachedDatabase, _db.recentsTable);
  $$FollowedTableTableTableManager get followedTable =>
      $$FollowedTableTableTableManager(_db.attachedDatabase, _db.followedTable);
}

mixin _$PlaylistDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlaylistsTableTable get playlistsTable => attachedDatabase.playlistsTable;
  $PlaylistTracksTableTable get playlistTracksTable =>
      attachedDatabase.playlistTracksTable;
  PlaylistDaoManager get managers => PlaylistDaoManager(this);
}

class PlaylistDaoManager {
  final _$PlaylistDaoMixin _db;
  PlaylistDaoManager(this._db);
  $$PlaylistsTableTableTableManager get playlistsTable =>
      $$PlaylistsTableTableTableManager(
        _db.attachedDatabase,
        _db.playlistsTable,
      );
  $$PlaylistTracksTableTableTableManager get playlistTracksTable =>
      $$PlaylistTracksTableTableTableManager(
        _db.attachedDatabase,
        _db.playlistTracksTable,
      );
}

mixin _$DownloadsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DownloadsTableTable get downloadsTable => attachedDatabase.downloadsTable;
  DownloadsDaoManager get managers => DownloadsDaoManager(this);
}

class DownloadsDaoManager {
  final _$DownloadsDaoMixin _db;
  DownloadsDaoManager(this._db);
  $$DownloadsTableTableTableManager get downloadsTable =>
      $$DownloadsTableTableTableManager(
        _db.attachedDatabase,
        _db.downloadsTable,
      );
}

mixin _$StatsDaoMixin on DatabaseAccessor<AppDatabase> {
  $StatsTracksTableTable get statsTracksTable =>
      attachedDatabase.statsTracksTable;
  $StatsArtistsTableTable get statsArtistsTable =>
      attachedDatabase.statsArtistsTable;
  $StatsDaysTableTable get statsDaysTable => attachedDatabase.statsDaysTable;
  $StatsMonthsTableTable get statsMonthsTable =>
      attachedDatabase.statsMonthsTable;
  StatsDaoManager get managers => StatsDaoManager(this);
}

class StatsDaoManager {
  final _$StatsDaoMixin _db;
  StatsDaoManager(this._db);
  $$StatsTracksTableTableTableManager get statsTracksTable =>
      $$StatsTracksTableTableTableManager(
        _db.attachedDatabase,
        _db.statsTracksTable,
      );
  $$StatsArtistsTableTableTableManager get statsArtistsTable =>
      $$StatsArtistsTableTableTableManager(
        _db.attachedDatabase,
        _db.statsArtistsTable,
      );
  $$StatsDaysTableTableTableManager get statsDaysTable =>
      $$StatsDaysTableTableTableManager(
        _db.attachedDatabase,
        _db.statsDaysTable,
      );
  $$StatsMonthsTableTableTableManager get statsMonthsTable =>
      $$StatsMonthsTableTableTableManager(
        _db.attachedDatabase,
        _db.statsMonthsTable,
      );
}

mixin _$CacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $StreamCacheTableTable get streamCacheTable =>
      attachedDatabase.streamCacheTable;
  $SongMatchesTableTable get songMatchesTable =>
      attachedDatabase.songMatchesTable;
  $QueueStateTableTable get queueStateTable => attachedDatabase.queueStateTable;
  $LyricOffsetsTableTable get lyricOffsetsTable =>
      attachedDatabase.lyricOffsetsTable;
  CacheDaoManager get managers => CacheDaoManager(this);
}

class CacheDaoManager {
  final _$CacheDaoMixin _db;
  CacheDaoManager(this._db);
  $$StreamCacheTableTableTableManager get streamCacheTable =>
      $$StreamCacheTableTableTableManager(
        _db.attachedDatabase,
        _db.streamCacheTable,
      );
  $$SongMatchesTableTableTableManager get songMatchesTable =>
      $$SongMatchesTableTableTableManager(
        _db.attachedDatabase,
        _db.songMatchesTable,
      );
  $$QueueStateTableTableTableManager get queueStateTable =>
      $$QueueStateTableTableTableManager(
        _db.attachedDatabase,
        _db.queueStateTable,
      );
  $$LyricOffsetsTableTableTableManager get lyricOffsetsTable =>
      $$LyricOffsetsTableTableTableManager(
        _db.attachedDatabase,
        _db.lyricOffsetsTable,
      );
}

class $TracksTableTable extends TracksTable
    with TableInfo<$TracksTableTable, TracksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TracksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TracksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TracksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $TracksTableTable createAlias(String alias) {
    return $TracksTableTable(attachedDatabase, alias);
  }
}

class TracksTableData extends DataClass implements Insertable<TracksTableData> {
  final String id;
  final String json;
  const TracksTableData({required this.id, required this.json});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    return map;
  }

  TracksTableCompanion toCompanion(bool nullToAbsent) {
    return TracksTableCompanion(id: Value(id), json: Value(json));
  }

  factory TracksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TracksTableData(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
    };
  }

  TracksTableData copyWith({String? id, String? json}) =>
      TracksTableData(id: id ?? this.id, json: json ?? this.json);
  TracksTableData copyWithCompanion(TracksTableCompanion data) {
    return TracksTableData(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TracksTableData(')
          ..write('id: $id, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TracksTableData &&
          other.id == this.id &&
          other.json == this.json);
}

class TracksTableCompanion extends UpdateCompanion<TracksTableData> {
  final Value<String> id;
  final Value<String> json;
  final Value<int> rowid;
  const TracksTableCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TracksTableCompanion.insert({
    required String id,
    required String json,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<TracksTableData> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TracksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return TracksTableCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksTableCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LikedTableTable extends LikedTable
    with TableInfo<$LikedTableTable, LikedTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LikedTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [trackId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'liked';
  @override
  VerificationContext validateIntegrity(
    Insertable<LikedTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  LikedTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LikedTableData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $LikedTableTable createAlias(String alias) {
    return $LikedTableTable(attachedDatabase, alias);
  }
}

class LikedTableData extends DataClass implements Insertable<LikedTableData> {
  final String trackId;
  final DateTime addedAt;
  const LikedTableData({required this.trackId, required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  LikedTableCompanion toCompanion(bool nullToAbsent) {
    return LikedTableCompanion(
      trackId: Value(trackId),
      addedAt: Value(addedAt),
    );
  }

  factory LikedTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LikedTableData(
      trackId: serializer.fromJson<String>(json['trackId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  LikedTableData copyWith({String? trackId, DateTime? addedAt}) =>
      LikedTableData(
        trackId: trackId ?? this.trackId,
        addedAt: addedAt ?? this.addedAt,
      );
  LikedTableData copyWithCompanion(LikedTableCompanion data) {
    return LikedTableData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LikedTableData(')
          ..write('trackId: $trackId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LikedTableData &&
          other.trackId == this.trackId &&
          other.addedAt == this.addedAt);
}

class LikedTableCompanion extends UpdateCompanion<LikedTableData> {
  final Value<String> trackId;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const LikedTableCompanion({
    this.trackId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LikedTableCompanion.insert({
    required String trackId,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       addedAt = Value(addedAt);
  static Insertable<LikedTableData> custom({
    Expression<String>? trackId,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LikedTableCompanion copyWith({
    Value<String>? trackId,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return LikedTableCompanion(
      trackId: trackId ?? this.trackId,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LikedTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentsTableTable extends RecentsTable
    with TableInfo<$RecentsTableTable, RecentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, trackId, playedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recents';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
    );
  }

  @override
  $RecentsTableTable createAlias(String alias) {
    return $RecentsTableTable(attachedDatabase, alias);
  }
}

class RecentsTableData extends DataClass
    implements Insertable<RecentsTableData> {
  final int id;
  final String trackId;
  final DateTime playedAt;
  const RecentsTableData({
    required this.id,
    required this.trackId,
    required this.playedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['track_id'] = Variable<String>(trackId);
    map['played_at'] = Variable<DateTime>(playedAt);
    return map;
  }

  RecentsTableCompanion toCompanion(bool nullToAbsent) {
    return RecentsTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      playedAt: Value(playedAt),
    );
  }

  factory RecentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentsTableData(
      id: serializer.fromJson<int>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackId': serializer.toJson<String>(trackId),
      'playedAt': serializer.toJson<DateTime>(playedAt),
    };
  }

  RecentsTableData copyWith({int? id, String? trackId, DateTime? playedAt}) =>
      RecentsTableData(
        id: id ?? this.id,
        trackId: trackId ?? this.trackId,
        playedAt: playedAt ?? this.playedAt,
      );
  RecentsTableData copyWithCompanion(RecentsTableCompanion data) {
    return RecentsTableData(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentsTableData(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, trackId, playedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentsTableData &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.playedAt == this.playedAt);
}

class RecentsTableCompanion extends UpdateCompanion<RecentsTableData> {
  final Value<int> id;
  final Value<String> trackId;
  final Value<DateTime> playedAt;
  const RecentsTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.playedAt = const Value.absent(),
  });
  RecentsTableCompanion.insert({
    this.id = const Value.absent(),
    required String trackId,
    required DateTime playedAt,
  }) : trackId = Value(trackId),
       playedAt = Value(playedAt);
  static Insertable<RecentsTableData> custom({
    Expression<int>? id,
    Expression<String>? trackId,
    Expression<DateTime>? playedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (playedAt != null) 'played_at': playedAt,
    });
  }

  RecentsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? trackId,
    Value<DateTime>? playedAt,
  }) {
    return RecentsTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentsTableCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }
}

class $FollowedTableTable extends FollowedTable
    with TableInfo<$FollowedTableTable, FollowedTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowedTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [artistId, json, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'followed';
  @override
  VerificationContext validateIntegrity(
    Insertable<FollowedTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {artistId};
  @override
  FollowedTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FollowedTableData(
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $FollowedTableTable createAlias(String alias) {
    return $FollowedTableTable(attachedDatabase, alias);
  }
}

class FollowedTableData extends DataClass
    implements Insertable<FollowedTableData> {
  final String artistId;
  final String json;
  final DateTime addedAt;
  const FollowedTableData({
    required this.artistId,
    required this.json,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['artist_id'] = Variable<String>(artistId);
    map['json'] = Variable<String>(json);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FollowedTableCompanion toCompanion(bool nullToAbsent) {
    return FollowedTableCompanion(
      artistId: Value(artistId),
      json: Value(json),
      addedAt: Value(addedAt),
    );
  }

  factory FollowedTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FollowedTableData(
      artistId: serializer.fromJson<String>(json['artistId']),
      json: serializer.fromJson<String>(json['json']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'artistId': serializer.toJson<String>(artistId),
      'json': serializer.toJson<String>(json),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  FollowedTableData copyWith({
    String? artistId,
    String? json,
    DateTime? addedAt,
  }) => FollowedTableData(
    artistId: artistId ?? this.artistId,
    json: json ?? this.json,
    addedAt: addedAt ?? this.addedAt,
  );
  FollowedTableData copyWithCompanion(FollowedTableCompanion data) {
    return FollowedTableData(
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      json: data.json.present ? data.json.value : this.json,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FollowedTableData(')
          ..write('artistId: $artistId, ')
          ..write('json: $json, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(artistId, json, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowedTableData &&
          other.artistId == this.artistId &&
          other.json == this.json &&
          other.addedAt == this.addedAt);
}

class FollowedTableCompanion extends UpdateCompanion<FollowedTableData> {
  final Value<String> artistId;
  final Value<String> json;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const FollowedTableCompanion({
    this.artistId = const Value.absent(),
    this.json = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FollowedTableCompanion.insert({
    required String artistId,
    required String json,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : artistId = Value(artistId),
       json = Value(json),
       addedAt = Value(addedAt);
  static Insertable<FollowedTableData> custom({
    Expression<String>? artistId,
    Expression<String>? json,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (artistId != null) 'artist_id': artistId,
      if (json != null) 'json': json,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FollowedTableCompanion copyWith({
    Value<String>? artistId,
    Value<String>? json,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return FollowedTableCompanion(
      artistId: artistId ?? this.artistId,
      json: json ?? this.json,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FollowedTableCompanion(')
          ..write('artistId: $artistId, ')
          ..write('json: $json, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTableTable extends PlaylistsTable
    with TableInfo<$PlaylistsTableTable, PlaylistsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlaylistsTableTable createAlias(String alias) {
    return $PlaylistsTableTable(attachedDatabase, alias);
  }
}

class PlaylistsTableData extends DataClass
    implements Insertable<PlaylistsTableData> {
  final String id;
  final String name;
  final DateTime createdAt;
  const PlaylistsTableData({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlaylistsTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsTableCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory PlaylistsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlaylistsTableData copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) => PlaylistsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  PlaylistsTableData copyWithCompanion(PlaylistsTableCompanion data) {
    return PlaylistsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PlaylistsTableCompanion extends UpdateCompanion<PlaylistsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlaylistsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsTableCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<PlaylistsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlaylistsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTracksTableTable extends PlaylistTracksTable
    with TableInfo<$PlaylistTracksTableTable, PlaylistTracksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTracksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    playlistId,
    position,
    trackId,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistTracksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, position};
  @override
  PlaylistTracksTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTracksTableData(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
    );
  }

  @override
  $PlaylistTracksTableTable createAlias(String alias) {
    return $PlaylistTracksTableTable(attachedDatabase, alias);
  }
}

class PlaylistTracksTableData extends DataClass
    implements Insertable<PlaylistTracksTableData> {
  final String playlistId;
  final int position;
  final String trackId;
  final bool pending;
  const PlaylistTracksTableData({
    required this.playlistId,
    required this.position,
    required this.trackId,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['position'] = Variable<int>(position);
    map['track_id'] = Variable<String>(trackId);
    map['pending'] = Variable<bool>(pending);
    return map;
  }

  PlaylistTracksTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTracksTableCompanion(
      playlistId: Value(playlistId),
      position: Value(position),
      trackId: Value(trackId),
      pending: Value(pending),
    );
  }

  factory PlaylistTracksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTracksTableData(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      position: serializer.fromJson<int>(json['position']),
      trackId: serializer.fromJson<String>(json['trackId']),
      pending: serializer.fromJson<bool>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'position': serializer.toJson<int>(position),
      'trackId': serializer.toJson<String>(trackId),
      'pending': serializer.toJson<bool>(pending),
    };
  }

  PlaylistTracksTableData copyWith({
    String? playlistId,
    int? position,
    String? trackId,
    bool? pending,
  }) => PlaylistTracksTableData(
    playlistId: playlistId ?? this.playlistId,
    position: position ?? this.position,
    trackId: trackId ?? this.trackId,
    pending: pending ?? this.pending,
  );
  PlaylistTracksTableData copyWithCompanion(PlaylistTracksTableCompanion data) {
    return PlaylistTracksTableData(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      position: data.position.present ? data.position.value : this.position,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTracksTableData(')
          ..write('playlistId: $playlistId, ')
          ..write('position: $position, ')
          ..write('trackId: $trackId, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, position, trackId, pending);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTracksTableData &&
          other.playlistId == this.playlistId &&
          other.position == this.position &&
          other.trackId == this.trackId &&
          other.pending == this.pending);
}

class PlaylistTracksTableCompanion
    extends UpdateCompanion<PlaylistTracksTableData> {
  final Value<String> playlistId;
  final Value<int> position;
  final Value<String> trackId;
  final Value<bool> pending;
  final Value<int> rowid;
  const PlaylistTracksTableCompanion({
    this.playlistId = const Value.absent(),
    this.position = const Value.absent(),
    this.trackId = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistTracksTableCompanion.insert({
    required String playlistId,
    required int position,
    required String trackId,
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       position = Value(position),
       trackId = Value(trackId);
  static Insertable<PlaylistTracksTableData> custom({
    Expression<String>? playlistId,
    Expression<int>? position,
    Expression<String>? trackId,
    Expression<bool>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (position != null) 'position': position,
      if (trackId != null) 'track_id': trackId,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistTracksTableCompanion copyWith({
    Value<String>? playlistId,
    Value<int>? position,
    Value<String>? trackId,
    Value<bool>? pending,
    Value<int>? rowid,
  }) {
    return PlaylistTracksTableCompanion(
      playlistId: playlistId ?? this.playlistId,
      position: position ?? this.position,
      trackId: trackId ?? this.trackId,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTracksTableCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('position: $position, ')
          ..write('trackId: $trackId, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadsTableTable extends DownloadsTable
    with TableInfo<$DownloadsTableTable, DownloadsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [trackId, filePath, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  DownloadsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadsTableData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $DownloadsTableTable createAlias(String alias) {
    return $DownloadsTableTable(attachedDatabase, alias);
  }
}

class DownloadsTableData extends DataClass
    implements Insertable<DownloadsTableData> {
  final String trackId;
  final String filePath;
  final DateTime addedAt;
  const DownloadsTableData({
    required this.trackId,
    required this.filePath,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['file_path'] = Variable<String>(filePath);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  DownloadsTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadsTableCompanion(
      trackId: Value(trackId),
      filePath: Value(filePath),
      addedAt: Value(addedAt),
    );
  }

  factory DownloadsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadsTableData(
      trackId: serializer.fromJson<String>(json['trackId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'filePath': serializer.toJson<String>(filePath),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  DownloadsTableData copyWith({
    String? trackId,
    String? filePath,
    DateTime? addedAt,
  }) => DownloadsTableData(
    trackId: trackId ?? this.trackId,
    filePath: filePath ?? this.filePath,
    addedAt: addedAt ?? this.addedAt,
  );
  DownloadsTableData copyWithCompanion(DownloadsTableCompanion data) {
    return DownloadsTableData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsTableData(')
          ..write('trackId: $trackId, ')
          ..write('filePath: $filePath, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, filePath, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadsTableData &&
          other.trackId == this.trackId &&
          other.filePath == this.filePath &&
          other.addedAt == this.addedAt);
}

class DownloadsTableCompanion extends UpdateCompanion<DownloadsTableData> {
  final Value<String> trackId;
  final Value<String> filePath;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const DownloadsTableCompanion({
    this.trackId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadsTableCompanion.insert({
    required String trackId,
    required String filePath,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       filePath = Value(filePath),
       addedAt = Value(addedAt);
  static Insertable<DownloadsTableData> custom({
    Expression<String>? trackId,
    Expression<String>? filePath,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (filePath != null) 'file_path': filePath,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadsTableCompanion copyWith({
    Value<String>? trackId,
    Value<String>? filePath,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return DownloadsTableCompanion(
      trackId: trackId ?? this.trackId,
      filePath: filePath ?? this.filePath,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('filePath: $filePath, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StreamCacheTableTable extends StreamCacheTable
    with TableInfo<$StreamCacheTableTable, StreamCacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreamCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
    'video_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [videoId, url, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stream_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreamCacheTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {videoId};
  @override
  StreamCacheTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreamCacheTableData(
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $StreamCacheTableTable createAlias(String alias) {
    return $StreamCacheTableTable(attachedDatabase, alias);
  }
}

class StreamCacheTableData extends DataClass
    implements Insertable<StreamCacheTableData> {
  final String videoId;
  final String url;
  final DateTime expiresAt;
  const StreamCacheTableData({
    required this.videoId,
    required this.url,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['video_id'] = Variable<String>(videoId);
    map['url'] = Variable<String>(url);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  StreamCacheTableCompanion toCompanion(bool nullToAbsent) {
    return StreamCacheTableCompanion(
      videoId: Value(videoId),
      url: Value(url),
      expiresAt: Value(expiresAt),
    );
  }

  factory StreamCacheTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreamCacheTableData(
      videoId: serializer.fromJson<String>(json['videoId']),
      url: serializer.fromJson<String>(json['url']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'videoId': serializer.toJson<String>(videoId),
      'url': serializer.toJson<String>(url),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  StreamCacheTableData copyWith({
    String? videoId,
    String? url,
    DateTime? expiresAt,
  }) => StreamCacheTableData(
    videoId: videoId ?? this.videoId,
    url: url ?? this.url,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  StreamCacheTableData copyWithCompanion(StreamCacheTableCompanion data) {
    return StreamCacheTableData(
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      url: data.url.present ? data.url.value : this.url,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreamCacheTableData(')
          ..write('videoId: $videoId, ')
          ..write('url: $url, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(videoId, url, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreamCacheTableData &&
          other.videoId == this.videoId &&
          other.url == this.url &&
          other.expiresAt == this.expiresAt);
}

class StreamCacheTableCompanion extends UpdateCompanion<StreamCacheTableData> {
  final Value<String> videoId;
  final Value<String> url;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const StreamCacheTableCompanion({
    this.videoId = const Value.absent(),
    this.url = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StreamCacheTableCompanion.insert({
    required String videoId,
    required String url,
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  }) : videoId = Value(videoId),
       url = Value(url),
       expiresAt = Value(expiresAt);
  static Insertable<StreamCacheTableData> custom({
    Expression<String>? videoId,
    Expression<String>? url,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (videoId != null) 'video_id': videoId,
      if (url != null) 'url': url,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StreamCacheTableCompanion copyWith({
    Value<String>? videoId,
    Value<String>? url,
    Value<DateTime>? expiresAt,
    Value<int>? rowid,
  }) {
    return StreamCacheTableCompanion(
      videoId: videoId ?? this.videoId,
      url: url ?? this.url,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreamCacheTableCompanion(')
          ..write('videoId: $videoId, ')
          ..write('url: $url, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongMatchesTableTable extends SongMatchesTable
    with TableInfo<$SongMatchesTableTable, SongMatchesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongMatchesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackJsonMeta = const VerificationMeta(
    'trackJson',
  );
  @override
  late final GeneratedColumn<String> trackJson = GeneratedColumn<String>(
    'track_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, trackJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_matches';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongMatchesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('track_json')) {
      context.handle(
        _trackJsonMeta,
        trackJson.isAcceptableOrUnknown(data['track_json']!, _trackJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_trackJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SongMatchesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongMatchesTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      trackJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_json'],
      )!,
    );
  }

  @override
  $SongMatchesTableTable createAlias(String alias) {
    return $SongMatchesTableTable(attachedDatabase, alias);
  }
}

class SongMatchesTableData extends DataClass
    implements Insertable<SongMatchesTableData> {
  final String key;
  final String trackJson;
  const SongMatchesTableData({required this.key, required this.trackJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['track_json'] = Variable<String>(trackJson);
    return map;
  }

  SongMatchesTableCompanion toCompanion(bool nullToAbsent) {
    return SongMatchesTableCompanion(
      key: Value(key),
      trackJson: Value(trackJson),
    );
  }

  factory SongMatchesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongMatchesTableData(
      key: serializer.fromJson<String>(json['key']),
      trackJson: serializer.fromJson<String>(json['trackJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'trackJson': serializer.toJson<String>(trackJson),
    };
  }

  SongMatchesTableData copyWith({String? key, String? trackJson}) =>
      SongMatchesTableData(
        key: key ?? this.key,
        trackJson: trackJson ?? this.trackJson,
      );
  SongMatchesTableData copyWithCompanion(SongMatchesTableCompanion data) {
    return SongMatchesTableData(
      key: data.key.present ? data.key.value : this.key,
      trackJson: data.trackJson.present ? data.trackJson.value : this.trackJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongMatchesTableData(')
          ..write('key: $key, ')
          ..write('trackJson: $trackJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, trackJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongMatchesTableData &&
          other.key == this.key &&
          other.trackJson == this.trackJson);
}

class SongMatchesTableCompanion extends UpdateCompanion<SongMatchesTableData> {
  final Value<String> key;
  final Value<String> trackJson;
  final Value<int> rowid;
  const SongMatchesTableCompanion({
    this.key = const Value.absent(),
    this.trackJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongMatchesTableCompanion.insert({
    required String key,
    required String trackJson,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       trackJson = Value(trackJson);
  static Insertable<SongMatchesTableData> custom({
    Expression<String>? key,
    Expression<String>? trackJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (trackJson != null) 'track_json': trackJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongMatchesTableCompanion copyWith({
    Value<String>? key,
    Value<String>? trackJson,
    Value<int>? rowid,
  }) {
    return SongMatchesTableCompanion(
      key: key ?? this.key,
      trackJson: trackJson ?? this.trackJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (trackJson.present) {
      map['track_json'] = Variable<String>(trackJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongMatchesTableCompanion(')
          ..write('key: $key, ')
          ..write('trackJson: $trackJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatsTracksTableTable extends StatsTracksTable
    with TableInfo<$StatsTracksTableTable, StatsTracksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatsTracksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playsMeta = const VerificationMeta('plays');
  @override
  late final GeneratedColumn<int> plays = GeneratedColumn<int>(
    'plays',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _msMeta = const VerificationMeta('ms');
  @override
  late final GeneratedColumn<int> ms = GeneratedColumn<int>(
    'ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [trackId, plays, ms];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stats_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatsTracksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('plays')) {
      context.handle(
        _playsMeta,
        plays.isAcceptableOrUnknown(data['plays']!, _playsMeta),
      );
    }
    if (data.containsKey('ms')) {
      context.handle(_msMeta, ms.isAcceptableOrUnknown(data['ms']!, _msMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  StatsTracksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatsTracksTableData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      plays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plays'],
      )!,
      ms: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ms'],
      )!,
    );
  }

  @override
  $StatsTracksTableTable createAlias(String alias) {
    return $StatsTracksTableTable(attachedDatabase, alias);
  }
}

class StatsTracksTableData extends DataClass
    implements Insertable<StatsTracksTableData> {
  final String trackId;
  final int plays;
  final int ms;
  const StatsTracksTableData({
    required this.trackId,
    required this.plays,
    required this.ms,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['plays'] = Variable<int>(plays);
    map['ms'] = Variable<int>(ms);
    return map;
  }

  StatsTracksTableCompanion toCompanion(bool nullToAbsent) {
    return StatsTracksTableCompanion(
      trackId: Value(trackId),
      plays: Value(plays),
      ms: Value(ms),
    );
  }

  factory StatsTracksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatsTracksTableData(
      trackId: serializer.fromJson<String>(json['trackId']),
      plays: serializer.fromJson<int>(json['plays']),
      ms: serializer.fromJson<int>(json['ms']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'plays': serializer.toJson<int>(plays),
      'ms': serializer.toJson<int>(ms),
    };
  }

  StatsTracksTableData copyWith({String? trackId, int? plays, int? ms}) =>
      StatsTracksTableData(
        trackId: trackId ?? this.trackId,
        plays: plays ?? this.plays,
        ms: ms ?? this.ms,
      );
  StatsTracksTableData copyWithCompanion(StatsTracksTableCompanion data) {
    return StatsTracksTableData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      plays: data.plays.present ? data.plays.value : this.plays,
      ms: data.ms.present ? data.ms.value : this.ms,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatsTracksTableData(')
          ..write('trackId: $trackId, ')
          ..write('plays: $plays, ')
          ..write('ms: $ms')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, plays, ms);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatsTracksTableData &&
          other.trackId == this.trackId &&
          other.plays == this.plays &&
          other.ms == this.ms);
}

class StatsTracksTableCompanion extends UpdateCompanion<StatsTracksTableData> {
  final Value<String> trackId;
  final Value<int> plays;
  final Value<int> ms;
  final Value<int> rowid;
  const StatsTracksTableCompanion({
    this.trackId = const Value.absent(),
    this.plays = const Value.absent(),
    this.ms = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatsTracksTableCompanion.insert({
    required String trackId,
    this.plays = const Value.absent(),
    this.ms = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId);
  static Insertable<StatsTracksTableData> custom({
    Expression<String>? trackId,
    Expression<int>? plays,
    Expression<int>? ms,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (plays != null) 'plays': plays,
      if (ms != null) 'ms': ms,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatsTracksTableCompanion copyWith({
    Value<String>? trackId,
    Value<int>? plays,
    Value<int>? ms,
    Value<int>? rowid,
  }) {
    return StatsTracksTableCompanion(
      trackId: trackId ?? this.trackId,
      plays: plays ?? this.plays,
      ms: ms ?? this.ms,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (plays.present) {
      map['plays'] = Variable<int>(plays.value);
    }
    if (ms.present) {
      map['ms'] = Variable<int>(ms.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatsTracksTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('plays: $plays, ')
          ..write('ms: $ms, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatsArtistsTableTable extends StatsArtistsTable
    with TableInfo<$StatsArtistsTableTable, StatsArtistsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatsArtistsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artMeta = const VerificationMeta('art');
  @override
  late final GeneratedColumn<String> art = GeneratedColumn<String>(
    'art',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playsMeta = const VerificationMeta('plays');
  @override
  late final GeneratedColumn<int> plays = GeneratedColumn<int>(
    'plays',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _msMeta = const VerificationMeta('ms');
  @override
  late final GeneratedColumn<int> ms = GeneratedColumn<int>(
    'ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [artistId, name, art, plays, ms];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stats_artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatsArtistsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('art')) {
      context.handle(
        _artMeta,
        art.isAcceptableOrUnknown(data['art']!, _artMeta),
      );
    }
    if (data.containsKey('plays')) {
      context.handle(
        _playsMeta,
        plays.isAcceptableOrUnknown(data['plays']!, _playsMeta),
      );
    }
    if (data.containsKey('ms')) {
      context.handle(_msMeta, ms.isAcceptableOrUnknown(data['ms']!, _msMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {artistId};
  @override
  StatsArtistsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatsArtistsTableData(
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      art: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}art'],
      ),
      plays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plays'],
      )!,
      ms: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ms'],
      )!,
    );
  }

  @override
  $StatsArtistsTableTable createAlias(String alias) {
    return $StatsArtistsTableTable(attachedDatabase, alias);
  }
}

class StatsArtistsTableData extends DataClass
    implements Insertable<StatsArtistsTableData> {
  final String artistId;
  final String name;
  final String? art;
  final int plays;
  final int ms;
  const StatsArtistsTableData({
    required this.artistId,
    required this.name,
    this.art,
    required this.plays,
    required this.ms,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['artist_id'] = Variable<String>(artistId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || art != null) {
      map['art'] = Variable<String>(art);
    }
    map['plays'] = Variable<int>(plays);
    map['ms'] = Variable<int>(ms);
    return map;
  }

  StatsArtistsTableCompanion toCompanion(bool nullToAbsent) {
    return StatsArtistsTableCompanion(
      artistId: Value(artistId),
      name: Value(name),
      art: art == null && nullToAbsent ? const Value.absent() : Value(art),
      plays: Value(plays),
      ms: Value(ms),
    );
  }

  factory StatsArtistsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatsArtistsTableData(
      artistId: serializer.fromJson<String>(json['artistId']),
      name: serializer.fromJson<String>(json['name']),
      art: serializer.fromJson<String?>(json['art']),
      plays: serializer.fromJson<int>(json['plays']),
      ms: serializer.fromJson<int>(json['ms']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'artistId': serializer.toJson<String>(artistId),
      'name': serializer.toJson<String>(name),
      'art': serializer.toJson<String?>(art),
      'plays': serializer.toJson<int>(plays),
      'ms': serializer.toJson<int>(ms),
    };
  }

  StatsArtistsTableData copyWith({
    String? artistId,
    String? name,
    Value<String?> art = const Value.absent(),
    int? plays,
    int? ms,
  }) => StatsArtistsTableData(
    artistId: artistId ?? this.artistId,
    name: name ?? this.name,
    art: art.present ? art.value : this.art,
    plays: plays ?? this.plays,
    ms: ms ?? this.ms,
  );
  StatsArtistsTableData copyWithCompanion(StatsArtistsTableCompanion data) {
    return StatsArtistsTableData(
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      name: data.name.present ? data.name.value : this.name,
      art: data.art.present ? data.art.value : this.art,
      plays: data.plays.present ? data.plays.value : this.plays,
      ms: data.ms.present ? data.ms.value : this.ms,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatsArtistsTableData(')
          ..write('artistId: $artistId, ')
          ..write('name: $name, ')
          ..write('art: $art, ')
          ..write('plays: $plays, ')
          ..write('ms: $ms')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(artistId, name, art, plays, ms);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatsArtistsTableData &&
          other.artistId == this.artistId &&
          other.name == this.name &&
          other.art == this.art &&
          other.plays == this.plays &&
          other.ms == this.ms);
}

class StatsArtistsTableCompanion
    extends UpdateCompanion<StatsArtistsTableData> {
  final Value<String> artistId;
  final Value<String> name;
  final Value<String?> art;
  final Value<int> plays;
  final Value<int> ms;
  final Value<int> rowid;
  const StatsArtistsTableCompanion({
    this.artistId = const Value.absent(),
    this.name = const Value.absent(),
    this.art = const Value.absent(),
    this.plays = const Value.absent(),
    this.ms = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatsArtistsTableCompanion.insert({
    required String artistId,
    required String name,
    this.art = const Value.absent(),
    this.plays = const Value.absent(),
    this.ms = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : artistId = Value(artistId),
       name = Value(name);
  static Insertable<StatsArtistsTableData> custom({
    Expression<String>? artistId,
    Expression<String>? name,
    Expression<String>? art,
    Expression<int>? plays,
    Expression<int>? ms,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (artistId != null) 'artist_id': artistId,
      if (name != null) 'name': name,
      if (art != null) 'art': art,
      if (plays != null) 'plays': plays,
      if (ms != null) 'ms': ms,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatsArtistsTableCompanion copyWith({
    Value<String>? artistId,
    Value<String>? name,
    Value<String?>? art,
    Value<int>? plays,
    Value<int>? ms,
    Value<int>? rowid,
  }) {
    return StatsArtistsTableCompanion(
      artistId: artistId ?? this.artistId,
      name: name ?? this.name,
      art: art ?? this.art,
      plays: plays ?? this.plays,
      ms: ms ?? this.ms,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    if (plays.present) {
      map['plays'] = Variable<int>(plays.value);
    }
    if (ms.present) {
      map['ms'] = Variable<int>(ms.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatsArtistsTableCompanion(')
          ..write('artistId: $artistId, ')
          ..write('name: $name, ')
          ..write('art: $art, ')
          ..write('plays: $plays, ')
          ..write('ms: $ms, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatsDaysTableTable extends StatsDaysTable
    with TableInfo<$StatsDaysTableTable, StatsDaysTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatsDaysTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _msMeta = const VerificationMeta('ms');
  @override
  late final GeneratedColumn<int> ms = GeneratedColumn<int>(
    'ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [day, ms];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stats_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatsDaysTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('ms')) {
      context.handle(_msMeta, ms.isAcceptableOrUnknown(data['ms']!, _msMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  StatsDaysTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatsDaysTableData(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      ms: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ms'],
      )!,
    );
  }

  @override
  $StatsDaysTableTable createAlias(String alias) {
    return $StatsDaysTableTable(attachedDatabase, alias);
  }
}

class StatsDaysTableData extends DataClass
    implements Insertable<StatsDaysTableData> {
  final String day;
  final int ms;
  const StatsDaysTableData({required this.day, required this.ms});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['ms'] = Variable<int>(ms);
    return map;
  }

  StatsDaysTableCompanion toCompanion(bool nullToAbsent) {
    return StatsDaysTableCompanion(day: Value(day), ms: Value(ms));
  }

  factory StatsDaysTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatsDaysTableData(
      day: serializer.fromJson<String>(json['day']),
      ms: serializer.fromJson<int>(json['ms']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'ms': serializer.toJson<int>(ms),
    };
  }

  StatsDaysTableData copyWith({String? day, int? ms}) =>
      StatsDaysTableData(day: day ?? this.day, ms: ms ?? this.ms);
  StatsDaysTableData copyWithCompanion(StatsDaysTableCompanion data) {
    return StatsDaysTableData(
      day: data.day.present ? data.day.value : this.day,
      ms: data.ms.present ? data.ms.value : this.ms,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatsDaysTableData(')
          ..write('day: $day, ')
          ..write('ms: $ms')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, ms);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatsDaysTableData &&
          other.day == this.day &&
          other.ms == this.ms);
}

class StatsDaysTableCompanion extends UpdateCompanion<StatsDaysTableData> {
  final Value<String> day;
  final Value<int> ms;
  final Value<int> rowid;
  const StatsDaysTableCompanion({
    this.day = const Value.absent(),
    this.ms = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatsDaysTableCompanion.insert({
    required String day,
    this.ms = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day);
  static Insertable<StatsDaysTableData> custom({
    Expression<String>? day,
    Expression<int>? ms,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (ms != null) 'ms': ms,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatsDaysTableCompanion copyWith({
    Value<String>? day,
    Value<int>? ms,
    Value<int>? rowid,
  }) {
    return StatsDaysTableCompanion(
      day: day ?? this.day,
      ms: ms ?? this.ms,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (ms.present) {
      map['ms'] = Variable<int>(ms.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatsDaysTableCompanion(')
          ..write('day: $day, ')
          ..write('ms: $ms, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatsMonthsTableTable extends StatsMonthsTable
    with TableInfo<$StatsMonthsTableTable, StatsMonthsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatsMonthsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [month, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stats_months';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatsMonthsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {month};
  @override
  StatsMonthsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatsMonthsTableData(
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $StatsMonthsTableTable createAlias(String alias) {
    return $StatsMonthsTableTable(attachedDatabase, alias);
  }
}

class StatsMonthsTableData extends DataClass
    implements Insertable<StatsMonthsTableData> {
  final String month;
  final String json;
  const StatsMonthsTableData({required this.month, required this.json});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['month'] = Variable<String>(month);
    map['json'] = Variable<String>(json);
    return map;
  }

  StatsMonthsTableCompanion toCompanion(bool nullToAbsent) {
    return StatsMonthsTableCompanion(month: Value(month), json: Value(json));
  }

  factory StatsMonthsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatsMonthsTableData(
      month: serializer.fromJson<String>(json['month']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'month': serializer.toJson<String>(month),
      'json': serializer.toJson<String>(json),
    };
  }

  StatsMonthsTableData copyWith({String? month, String? json}) =>
      StatsMonthsTableData(month: month ?? this.month, json: json ?? this.json);
  StatsMonthsTableData copyWithCompanion(StatsMonthsTableCompanion data) {
    return StatsMonthsTableData(
      month: data.month.present ? data.month.value : this.month,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatsMonthsTableData(')
          ..write('month: $month, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(month, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatsMonthsTableData &&
          other.month == this.month &&
          other.json == this.json);
}

class StatsMonthsTableCompanion extends UpdateCompanion<StatsMonthsTableData> {
  final Value<String> month;
  final Value<String> json;
  final Value<int> rowid;
  const StatsMonthsTableCompanion({
    this.month = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatsMonthsTableCompanion.insert({
    required String month,
    required String json,
    this.rowid = const Value.absent(),
  }) : month = Value(month),
       json = Value(json);
  static Insertable<StatsMonthsTableData> custom({
    Expression<String>? month,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (month != null) 'month': month,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatsMonthsTableCompanion copyWith({
    Value<String>? month,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return StatsMonthsTableCompanion(
      month: month ?? this.month,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatsMonthsTableCompanion(')
          ..write('month: $month, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LyricOffsetsTableTable extends LyricOffsetsTable
    with TableInfo<$LyricOffsetsTableTable, LyricOffsetsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LyricOffsetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _msMeta = const VerificationMeta('ms');
  @override
  late final GeneratedColumn<int> ms = GeneratedColumn<int>(
    'ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manualMeta = const VerificationMeta('manual');
  @override
  late final GeneratedColumn<bool> manual = GeneratedColumn<bool>(
    'manual',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("manual" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [key, ms, manual];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lyric_offsets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LyricOffsetsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('ms')) {
      context.handle(_msMeta, ms.isAcceptableOrUnknown(data['ms']!, _msMeta));
    } else if (isInserting) {
      context.missing(_msMeta);
    }
    if (data.containsKey('manual')) {
      context.handle(
        _manualMeta,
        manual.isAcceptableOrUnknown(data['manual']!, _manualMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LyricOffsetsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LyricOffsetsTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      ms: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ms'],
      )!,
      manual: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}manual'],
      )!,
    );
  }

  @override
  $LyricOffsetsTableTable createAlias(String alias) {
    return $LyricOffsetsTableTable(attachedDatabase, alias);
  }
}

class LyricOffsetsTableData extends DataClass
    implements Insertable<LyricOffsetsTableData> {
  final String key;
  final int ms;
  final bool manual;
  const LyricOffsetsTableData({
    required this.key,
    required this.ms,
    required this.manual,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['ms'] = Variable<int>(ms);
    map['manual'] = Variable<bool>(manual);
    return map;
  }

  LyricOffsetsTableCompanion toCompanion(bool nullToAbsent) {
    return LyricOffsetsTableCompanion(
      key: Value(key),
      ms: Value(ms),
      manual: Value(manual),
    );
  }

  factory LyricOffsetsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LyricOffsetsTableData(
      key: serializer.fromJson<String>(json['key']),
      ms: serializer.fromJson<int>(json['ms']),
      manual: serializer.fromJson<bool>(json['manual']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'ms': serializer.toJson<int>(ms),
      'manual': serializer.toJson<bool>(manual),
    };
  }

  LyricOffsetsTableData copyWith({String? key, int? ms, bool? manual}) =>
      LyricOffsetsTableData(
        key: key ?? this.key,
        ms: ms ?? this.ms,
        manual: manual ?? this.manual,
      );
  LyricOffsetsTableData copyWithCompanion(LyricOffsetsTableCompanion data) {
    return LyricOffsetsTableData(
      key: data.key.present ? data.key.value : this.key,
      ms: data.ms.present ? data.ms.value : this.ms,
      manual: data.manual.present ? data.manual.value : this.manual,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LyricOffsetsTableData(')
          ..write('key: $key, ')
          ..write('ms: $ms, ')
          ..write('manual: $manual')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, ms, manual);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LyricOffsetsTableData &&
          other.key == this.key &&
          other.ms == this.ms &&
          other.manual == this.manual);
}

class LyricOffsetsTableCompanion
    extends UpdateCompanion<LyricOffsetsTableData> {
  final Value<String> key;
  final Value<int> ms;
  final Value<bool> manual;
  final Value<int> rowid;
  const LyricOffsetsTableCompanion({
    this.key = const Value.absent(),
    this.ms = const Value.absent(),
    this.manual = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LyricOffsetsTableCompanion.insert({
    required String key,
    required int ms,
    this.manual = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       ms = Value(ms);
  static Insertable<LyricOffsetsTableData> custom({
    Expression<String>? key,
    Expression<int>? ms,
    Expression<bool>? manual,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (ms != null) 'ms': ms,
      if (manual != null) 'manual': manual,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LyricOffsetsTableCompanion copyWith({
    Value<String>? key,
    Value<int>? ms,
    Value<bool>? manual,
    Value<int>? rowid,
  }) {
    return LyricOffsetsTableCompanion(
      key: key ?? this.key,
      ms: ms ?? this.ms,
      manual: manual ?? this.manual,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (ms.present) {
      map['ms'] = Variable<int>(ms.value);
    }
    if (manual.present) {
      map['manual'] = Variable<bool>(manual.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LyricOffsetsTableCompanion(')
          ..write('key: $key, ')
          ..write('ms: $ms, ')
          ..write('manual: $manual, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueueStateTableTable extends QueueStateTable
    with TableInfo<$QueueStateTableTable, QueueStateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueStateTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueStateTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueStateTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $QueueStateTableTable createAlias(String alias) {
    return $QueueStateTableTable(attachedDatabase, alias);
  }
}

class QueueStateTableData extends DataClass
    implements Insertable<QueueStateTableData> {
  final int id;
  final String json;
  const QueueStateTableData({required this.id, required this.json});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['json'] = Variable<String>(json);
    return map;
  }

  QueueStateTableCompanion toCompanion(bool nullToAbsent) {
    return QueueStateTableCompanion(id: Value(id), json: Value(json));
  }

  factory QueueStateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueStateTableData(
      id: serializer.fromJson<int>(json['id']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'json': serializer.toJson<String>(json),
    };
  }

  QueueStateTableData copyWith({int? id, String? json}) =>
      QueueStateTableData(id: id ?? this.id, json: json ?? this.json);
  QueueStateTableData copyWithCompanion(QueueStateTableCompanion data) {
    return QueueStateTableData(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueStateTableData(')
          ..write('id: $id, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueStateTableData &&
          other.id == this.id &&
          other.json == this.json);
}

class QueueStateTableCompanion extends UpdateCompanion<QueueStateTableData> {
  final Value<int> id;
  final Value<String> json;
  const QueueStateTableCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
  });
  QueueStateTableCompanion.insert({
    this.id = const Value.absent(),
    required String json,
  }) : json = Value(json);
  static Insertable<QueueStateTableData> custom({
    Expression<int>? id,
    Expression<String>? json,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
    });
  }

  QueueStateTableCompanion copyWith({Value<int>? id, Value<String>? json}) {
    return QueueStateTableCompanion(id: id ?? this.id, json: json ?? this.json);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueStateTableCompanion(')
          ..write('id: $id, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TracksTableTable tracksTable = $TracksTableTable(this);
  late final $LikedTableTable likedTable = $LikedTableTable(this);
  late final $RecentsTableTable recentsTable = $RecentsTableTable(this);
  late final $FollowedTableTable followedTable = $FollowedTableTable(this);
  late final $PlaylistsTableTable playlistsTable = $PlaylistsTableTable(this);
  late final $PlaylistTracksTableTable playlistTracksTable =
      $PlaylistTracksTableTable(this);
  late final $DownloadsTableTable downloadsTable = $DownloadsTableTable(this);
  late final $StreamCacheTableTable streamCacheTable = $StreamCacheTableTable(
    this,
  );
  late final $SongMatchesTableTable songMatchesTable = $SongMatchesTableTable(
    this,
  );
  late final $StatsTracksTableTable statsTracksTable = $StatsTracksTableTable(
    this,
  );
  late final $StatsArtistsTableTable statsArtistsTable =
      $StatsArtistsTableTable(this);
  late final $StatsDaysTableTable statsDaysTable = $StatsDaysTableTable(this);
  late final $StatsMonthsTableTable statsMonthsTable = $StatsMonthsTableTable(
    this,
  );
  late final $LyricOffsetsTableTable lyricOffsetsTable =
      $LyricOffsetsTableTable(this);
  late final $QueueStateTableTable queueStateTable = $QueueStateTableTable(
    this,
  );
  late final LibraryDao libraryDao = LibraryDao(this as AppDatabase);
  late final PlaylistDao playlistDao = PlaylistDao(this as AppDatabase);
  late final DownloadsDao downloadsDao = DownloadsDao(this as AppDatabase);
  late final StatsDao statsDao = StatsDao(this as AppDatabase);
  late final CacheDao cacheDao = CacheDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tracksTable,
    likedTable,
    recentsTable,
    followedTable,
    playlistsTable,
    playlistTracksTable,
    downloadsTable,
    streamCacheTable,
    songMatchesTable,
    statsTracksTable,
    statsArtistsTable,
    statsDaysTable,
    statsMonthsTable,
    lyricOffsetsTable,
    queueStateTable,
  ];
}

typedef $$TracksTableTableCreateCompanionBuilder =
    TracksTableCompanion Function({
      required String id,
      required String json,
      Value<int> rowid,
    });
typedef $$TracksTableTableUpdateCompanionBuilder =
    TracksTableCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<int> rowid,
    });

class $$TracksTableTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTableTable> {
  $$TracksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TracksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTableTable> {
  $$TracksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TracksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTableTable> {
  $$TracksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$TracksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TracksTableTable,
          TracksTableData,
          $$TracksTableTableFilterComposer,
          $$TracksTableTableOrderingComposer,
          $$TracksTableTableAnnotationComposer,
          $$TracksTableTableCreateCompanionBuilder,
          $$TracksTableTableUpdateCompanionBuilder,
          (
            TracksTableData,
            BaseReferences<_$AppDatabase, $TracksTableTable, TracksTableData>,
          ),
          TracksTableData,
          PrefetchHooks Function()
        > {
  $$TracksTableTableTableManager(_$AppDatabase db, $TracksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> json = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => TracksTableCompanion(id: id, json: json, rowid: rowid),
          createCompanionCallback: ({
            required String id,
            required String json,
            Value<int> rowid = const Value.absent(),
          }) => TracksTableCompanion.insert(id: id, json: json, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TracksTableTable, TracksTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TracksTableTable,
                    TracksTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TracksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TracksTableTable,
      TracksTableData,
      $$TracksTableTableFilterComposer,
      $$TracksTableTableOrderingComposer,
      $$TracksTableTableAnnotationComposer,
      $$TracksTableTableCreateCompanionBuilder,
      $$TracksTableTableUpdateCompanionBuilder,
      (
        TracksTableData,
        BaseReferences<_$AppDatabase, $TracksTableTable, TracksTableData>,
      ),
      TracksTableData,
      PrefetchHooks Function()
    >;
typedef $$LikedTableTableCreateCompanionBuilder = LikedTableCompanion Function({
  required String trackId,
  required DateTime addedAt,
  Value<int> rowid,
});
typedef $$LikedTableTableUpdateCompanionBuilder = LikedTableCompanion Function({
  Value<String> trackId,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

class $$LikedTableTableFilterComposer
    extends Composer<_$AppDatabase, $LikedTableTable> {
  $$LikedTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LikedTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LikedTableTable> {
  $$LikedTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LikedTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LikedTableTable> {
  $$LikedTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$LikedTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LikedTableTable,
          LikedTableData,
          $$LikedTableTableFilterComposer,
          $$LikedTableTableOrderingComposer,
          $$LikedTableTableAnnotationComposer,
          $$LikedTableTableCreateCompanionBuilder,
          $$LikedTableTableUpdateCompanionBuilder,
          (
            LikedTableData,
            BaseReferences<_$AppDatabase, $LikedTableTable, LikedTableData>,
          ),
          LikedTableData,
          PrefetchHooks Function()
        > {
  $$LikedTableTableTableManager(_$AppDatabase db, $LikedTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LikedTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LikedTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LikedTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LikedTableCompanion(
                trackId: trackId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => LikedTableCompanion.insert(
                trackId: trackId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LikedTableTable, LikedTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LikedTableTable,
                    LikedTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LikedTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LikedTableTable,
      LikedTableData,
      $$LikedTableTableFilterComposer,
      $$LikedTableTableOrderingComposer,
      $$LikedTableTableAnnotationComposer,
      $$LikedTableTableCreateCompanionBuilder,
      $$LikedTableTableUpdateCompanionBuilder,
      (
        LikedTableData,
        BaseReferences<_$AppDatabase, $LikedTableTable, LikedTableData>,
      ),
      LikedTableData,
      PrefetchHooks Function()
    >;
typedef $$RecentsTableTableCreateCompanionBuilder =
    RecentsTableCompanion Function({
      Value<int> id,
      required String trackId,
      required DateTime playedAt,
    });
typedef $$RecentsTableTableUpdateCompanionBuilder =
    RecentsTableCompanion Function({
      Value<int> id,
      Value<String> trackId,
      Value<DateTime> playedAt,
    });

class $$RecentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecentsTableTable> {
  $$RecentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentsTableTable> {
  $$RecentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentsTableTable> {
  $$RecentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);
}

class $$RecentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentsTableTable,
          RecentsTableData,
          $$RecentsTableTableFilterComposer,
          $$RecentsTableTableOrderingComposer,
          $$RecentsTableTableAnnotationComposer,
          $$RecentsTableTableCreateCompanionBuilder,
          $$RecentsTableTableUpdateCompanionBuilder,
          (
            RecentsTableData,
            BaseReferences<_$AppDatabase, $RecentsTableTable, RecentsTableData>,
          ),
          RecentsTableData,
          PrefetchHooks Function()
        > {
  $$RecentsTableTableTableManager(_$AppDatabase db, $RecentsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
              }) => RecentsTableCompanion(
                id: id,
                trackId: trackId,
                playedAt: playedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String trackId,
                required DateTime playedAt,
              }) => RecentsTableCompanion.insert(
                id: id,
                trackId: trackId,
                playedAt: playedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentsTableTable, RecentsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecentsTableTable,
                    RecentsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentsTableTable,
      RecentsTableData,
      $$RecentsTableTableFilterComposer,
      $$RecentsTableTableOrderingComposer,
      $$RecentsTableTableAnnotationComposer,
      $$RecentsTableTableCreateCompanionBuilder,
      $$RecentsTableTableUpdateCompanionBuilder,
      (
        RecentsTableData,
        BaseReferences<_$AppDatabase, $RecentsTableTable, RecentsTableData>,
      ),
      RecentsTableData,
      PrefetchHooks Function()
    >;
typedef $$FollowedTableTableCreateCompanionBuilder =
    FollowedTableCompanion Function({
      required String artistId,
      required String json,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$FollowedTableTableUpdateCompanionBuilder =
    FollowedTableCompanion Function({
      Value<String> artistId,
      Value<String> json,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

class $$FollowedTableTableFilterComposer
    extends Composer<_$AppDatabase, $FollowedTableTable> {
  $$FollowedTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FollowedTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FollowedTableTable> {
  $$FollowedTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FollowedTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FollowedTableTable> {
  $$FollowedTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$FollowedTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FollowedTableTable,
          FollowedTableData,
          $$FollowedTableTableFilterComposer,
          $$FollowedTableTableOrderingComposer,
          $$FollowedTableTableAnnotationComposer,
          $$FollowedTableTableCreateCompanionBuilder,
          $$FollowedTableTableUpdateCompanionBuilder,
          (
            FollowedTableData,
            BaseReferences<
              _$AppDatabase,
              $FollowedTableTable,
              FollowedTableData
            >,
          ),
          FollowedTableData,
          PrefetchHooks Function()
        > {
  $$FollowedTableTableTableManager(_$AppDatabase db, $FollowedTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FollowedTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FollowedTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FollowedTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> artistId = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FollowedTableCompanion(
                artistId: artistId,
                json: json,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String artistId,
                required String json,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => FollowedTableCompanion.insert(
                artistId: artistId,
                json: json,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FollowedTableTable, FollowedTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FollowedTableTable,
                    FollowedTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FollowedTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FollowedTableTable,
      FollowedTableData,
      $$FollowedTableTableFilterComposer,
      $$FollowedTableTableOrderingComposer,
      $$FollowedTableTableAnnotationComposer,
      $$FollowedTableTableCreateCompanionBuilder,
      $$FollowedTableTableUpdateCompanionBuilder,
      (
        FollowedTableData,
        BaseReferences<_$AppDatabase, $FollowedTableTable, FollowedTableData>,
      ),
      FollowedTableData,
      PrefetchHooks Function()
    >;
typedef $$PlaylistsTableTableCreateCompanionBuilder =
    PlaylistsTableCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PlaylistsTableTableUpdateCompanionBuilder =
    PlaylistsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PlaylistsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlaylistsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTableTable,
          PlaylistsTableData,
          $$PlaylistsTableTableFilterComposer,
          $$PlaylistsTableTableOrderingComposer,
          $$PlaylistsTableTableAnnotationComposer,
          $$PlaylistsTableTableCreateCompanionBuilder,
          $$PlaylistsTableTableUpdateCompanionBuilder,
          (
            PlaylistsTableData,
            BaseReferences<
              _$AppDatabase,
              $PlaylistsTableTable,
              PlaylistsTableData
            >,
          ),
          PlaylistsTableData,
          PrefetchHooks Function()
        > {
  $$PlaylistsTableTableTableManager(
    _$AppDatabase db,
    $PlaylistsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistsTableTable, PlaylistsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlaylistsTableTable,
                    PlaylistsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTableTable,
      PlaylistsTableData,
      $$PlaylistsTableTableFilterComposer,
      $$PlaylistsTableTableOrderingComposer,
      $$PlaylistsTableTableAnnotationComposer,
      $$PlaylistsTableTableCreateCompanionBuilder,
      $$PlaylistsTableTableUpdateCompanionBuilder,
      (
        PlaylistsTableData,
        BaseReferences<_$AppDatabase, $PlaylistsTableTable, PlaylistsTableData>,
      ),
      PlaylistsTableData,
      PrefetchHooks Function()
    >;
typedef $$PlaylistTracksTableTableCreateCompanionBuilder =
    PlaylistTracksTableCompanion Function({
      required String playlistId,
      required int position,
      required String trackId,
      Value<bool> pending,
      Value<int> rowid,
    });
typedef $$PlaylistTracksTableTableUpdateCompanionBuilder =
    PlaylistTracksTableCompanion Function({
      Value<String> playlistId,
      Value<int> position,
      Value<String> trackId,
      Value<bool> pending,
      Value<int> rowid,
    });

class $$PlaylistTracksTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTableTable> {
  $$PlaylistTracksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistTracksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTableTable> {
  $$PlaylistTracksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistTracksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTableTable> {
  $$PlaylistTracksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);
}

class $$PlaylistTracksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistTracksTableTable,
          PlaylistTracksTableData,
          $$PlaylistTracksTableTableFilterComposer,
          $$PlaylistTracksTableTableOrderingComposer,
          $$PlaylistTracksTableTableAnnotationComposer,
          $$PlaylistTracksTableTableCreateCompanionBuilder,
          $$PlaylistTracksTableTableUpdateCompanionBuilder,
          (
            PlaylistTracksTableData,
            BaseReferences<
              _$AppDatabase,
              $PlaylistTracksTableTable,
              PlaylistTracksTableData
            >,
          ),
          PlaylistTracksTableData,
          PrefetchHooks Function()
        > {
  $$PlaylistTracksTableTableTableManager(
    _$AppDatabase db,
    $PlaylistTracksTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTracksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTracksTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaylistTracksTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTracksTableCompanion(
                playlistId: playlistId,
                position: position,
                trackId: trackId,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required int position,
                required String trackId,
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTracksTableCompanion.insert(
                playlistId: playlistId,
                position: position,
                trackId: trackId,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $PlaylistTracksTableTable,
                    PlaylistTracksTableData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlaylistTracksTableTable,
                    PlaylistTracksTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistTracksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistTracksTableTable,
      PlaylistTracksTableData,
      $$PlaylistTracksTableTableFilterComposer,
      $$PlaylistTracksTableTableOrderingComposer,
      $$PlaylistTracksTableTableAnnotationComposer,
      $$PlaylistTracksTableTableCreateCompanionBuilder,
      $$PlaylistTracksTableTableUpdateCompanionBuilder,
      (
        PlaylistTracksTableData,
        BaseReferences<
          _$AppDatabase,
          $PlaylistTracksTableTable,
          PlaylistTracksTableData
        >,
      ),
      PlaylistTracksTableData,
      PrefetchHooks Function()
    >;
typedef $$DownloadsTableTableCreateCompanionBuilder =
    DownloadsTableCompanion Function({
      required String trackId,
      required String filePath,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$DownloadsTableTableUpdateCompanionBuilder =
    DownloadsTableCompanion Function({
      Value<String> trackId,
      Value<String> filePath,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

class $$DownloadsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadsTableTable> {
  $$DownloadsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadsTableTable> {
  $$DownloadsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadsTableTable> {
  $$DownloadsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$DownloadsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadsTableTable,
          DownloadsTableData,
          $$DownloadsTableTableFilterComposer,
          $$DownloadsTableTableOrderingComposer,
          $$DownloadsTableTableAnnotationComposer,
          $$DownloadsTableTableCreateCompanionBuilder,
          $$DownloadsTableTableUpdateCompanionBuilder,
          (
            DownloadsTableData,
            BaseReferences<
              _$AppDatabase,
              $DownloadsTableTable,
              DownloadsTableData
            >,
          ),
          DownloadsTableData,
          PrefetchHooks Function()
        > {
  $$DownloadsTableTableTableManager(
    _$AppDatabase db,
    $DownloadsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadsTableCompanion(
                trackId: trackId,
                filePath: filePath,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String filePath,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => DownloadsTableCompanion.insert(
                trackId: trackId,
                filePath: filePath,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadsTableTable, DownloadsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DownloadsTableTable,
                    DownloadsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadsTableTable,
      DownloadsTableData,
      $$DownloadsTableTableFilterComposer,
      $$DownloadsTableTableOrderingComposer,
      $$DownloadsTableTableAnnotationComposer,
      $$DownloadsTableTableCreateCompanionBuilder,
      $$DownloadsTableTableUpdateCompanionBuilder,
      (
        DownloadsTableData,
        BaseReferences<_$AppDatabase, $DownloadsTableTable, DownloadsTableData>,
      ),
      DownloadsTableData,
      PrefetchHooks Function()
    >;
typedef $$StreamCacheTableTableCreateCompanionBuilder =
    StreamCacheTableCompanion Function({
      required String videoId,
      required String url,
      required DateTime expiresAt,
      Value<int> rowid,
    });
typedef $$StreamCacheTableTableUpdateCompanionBuilder =
    StreamCacheTableCompanion Function({
      Value<String> videoId,
      Value<String> url,
      Value<DateTime> expiresAt,
      Value<int> rowid,
    });

class $$StreamCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $StreamCacheTableTable> {
  $$StreamCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreamCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StreamCacheTableTable> {
  $$StreamCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreamCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreamCacheTableTable> {
  $$StreamCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$StreamCacheTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreamCacheTableTable,
          StreamCacheTableData,
          $$StreamCacheTableTableFilterComposer,
          $$StreamCacheTableTableOrderingComposer,
          $$StreamCacheTableTableAnnotationComposer,
          $$StreamCacheTableTableCreateCompanionBuilder,
          $$StreamCacheTableTableUpdateCompanionBuilder,
          (
            StreamCacheTableData,
            BaseReferences<
              _$AppDatabase,
              $StreamCacheTableTable,
              StreamCacheTableData
            >,
          ),
          StreamCacheTableData,
          PrefetchHooks Function()
        > {
  $$StreamCacheTableTableTableManager(
    _$AppDatabase db,
    $StreamCacheTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreamCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreamCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreamCacheTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> videoId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StreamCacheTableCompanion(
                videoId: videoId,
                url: url,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String videoId,
                required String url,
                required DateTime expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => StreamCacheTableCompanion.insert(
                videoId: videoId,
                url: url,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StreamCacheTableTable, StreamCacheTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $StreamCacheTableTable,
                    StreamCacheTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreamCacheTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreamCacheTableTable,
      StreamCacheTableData,
      $$StreamCacheTableTableFilterComposer,
      $$StreamCacheTableTableOrderingComposer,
      $$StreamCacheTableTableAnnotationComposer,
      $$StreamCacheTableTableCreateCompanionBuilder,
      $$StreamCacheTableTableUpdateCompanionBuilder,
      (
        StreamCacheTableData,
        BaseReferences<
          _$AppDatabase,
          $StreamCacheTableTable,
          StreamCacheTableData
        >,
      ),
      StreamCacheTableData,
      PrefetchHooks Function()
    >;
typedef $$SongMatchesTableTableCreateCompanionBuilder =
    SongMatchesTableCompanion Function({
      required String key,
      required String trackJson,
      Value<int> rowid,
    });
typedef $$SongMatchesTableTableUpdateCompanionBuilder =
    SongMatchesTableCompanion Function({
      Value<String> key,
      Value<String> trackJson,
      Value<int> rowid,
    });

class $$SongMatchesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SongMatchesTableTable> {
  $$SongMatchesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackJson => $composableBuilder(
    column: $table.trackJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongMatchesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SongMatchesTableTable> {
  $$SongMatchesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackJson => $composableBuilder(
    column: $table.trackJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongMatchesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongMatchesTableTable> {
  $$SongMatchesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get trackJson =>
      $composableBuilder(column: $table.trackJson, builder: (column) => column);
}

class $$SongMatchesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongMatchesTableTable,
          SongMatchesTableData,
          $$SongMatchesTableTableFilterComposer,
          $$SongMatchesTableTableOrderingComposer,
          $$SongMatchesTableTableAnnotationComposer,
          $$SongMatchesTableTableCreateCompanionBuilder,
          $$SongMatchesTableTableUpdateCompanionBuilder,
          (
            SongMatchesTableData,
            BaseReferences<
              _$AppDatabase,
              $SongMatchesTableTable,
              SongMatchesTableData
            >,
          ),
          SongMatchesTableData,
          PrefetchHooks Function()
        > {
  $$SongMatchesTableTableTableManager(
    _$AppDatabase db,
    $SongMatchesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongMatchesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongMatchesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongMatchesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> trackJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongMatchesTableCompanion(
                key: key,
                trackJson: trackJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String trackJson,
                Value<int> rowid = const Value.absent(),
              }) => SongMatchesTableCompanion.insert(
                key: key,
                trackJson: trackJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SongMatchesTableTable, SongMatchesTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $SongMatchesTableTable,
                    SongMatchesTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongMatchesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongMatchesTableTable,
      SongMatchesTableData,
      $$SongMatchesTableTableFilterComposer,
      $$SongMatchesTableTableOrderingComposer,
      $$SongMatchesTableTableAnnotationComposer,
      $$SongMatchesTableTableCreateCompanionBuilder,
      $$SongMatchesTableTableUpdateCompanionBuilder,
      (
        SongMatchesTableData,
        BaseReferences<
          _$AppDatabase,
          $SongMatchesTableTable,
          SongMatchesTableData
        >,
      ),
      SongMatchesTableData,
      PrefetchHooks Function()
    >;
typedef $$StatsTracksTableTableCreateCompanionBuilder =
    StatsTracksTableCompanion Function({
      required String trackId,
      Value<int> plays,
      Value<int> ms,
      Value<int> rowid,
    });
typedef $$StatsTracksTableTableUpdateCompanionBuilder =
    StatsTracksTableCompanion Function({
      Value<String> trackId,
      Value<int> plays,
      Value<int> ms,
      Value<int> rowid,
    });

class $$StatsTracksTableTableFilterComposer
    extends Composer<_$AppDatabase, $StatsTracksTableTable> {
  $$StatsTracksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plays => $composableBuilder(
    column: $table.plays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ms => $composableBuilder(
    column: $table.ms,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StatsTracksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StatsTracksTableTable> {
  $$StatsTracksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plays => $composableBuilder(
    column: $table.plays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ms => $composableBuilder(
    column: $table.ms,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatsTracksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatsTracksTableTable> {
  $$StatsTracksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<int> get plays =>
      $composableBuilder(column: $table.plays, builder: (column) => column);

  GeneratedColumn<int> get ms =>
      $composableBuilder(column: $table.ms, builder: (column) => column);
}

class $$StatsTracksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatsTracksTableTable,
          StatsTracksTableData,
          $$StatsTracksTableTableFilterComposer,
          $$StatsTracksTableTableOrderingComposer,
          $$StatsTracksTableTableAnnotationComposer,
          $$StatsTracksTableTableCreateCompanionBuilder,
          $$StatsTracksTableTableUpdateCompanionBuilder,
          (
            StatsTracksTableData,
            BaseReferences<
              _$AppDatabase,
              $StatsTracksTableTable,
              StatsTracksTableData
            >,
          ),
          StatsTracksTableData,
          PrefetchHooks Function()
        > {
  $$StatsTracksTableTableTableManager(
    _$AppDatabase db,
    $StatsTracksTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatsTracksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatsTracksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatsTracksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<int> plays = const Value.absent(),
                Value<int> ms = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatsTracksTableCompanion(
                trackId: trackId,
                plays: plays,
                ms: ms,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                Value<int> plays = const Value.absent(),
                Value<int> ms = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatsTracksTableCompanion.insert(
                trackId: trackId,
                plays: plays,
                ms: ms,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StatsTracksTableTable, StatsTracksTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $StatsTracksTableTable,
                    StatsTracksTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StatsTracksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatsTracksTableTable,
      StatsTracksTableData,
      $$StatsTracksTableTableFilterComposer,
      $$StatsTracksTableTableOrderingComposer,
      $$StatsTracksTableTableAnnotationComposer,
      $$StatsTracksTableTableCreateCompanionBuilder,
      $$StatsTracksTableTableUpdateCompanionBuilder,
      (
        StatsTracksTableData,
        BaseReferences<
          _$AppDatabase,
          $StatsTracksTableTable,
          StatsTracksTableData
        >,
      ),
      StatsTracksTableData,
      PrefetchHooks Function()
    >;
typedef $$StatsArtistsTableTableCreateCompanionBuilder =
    StatsArtistsTableCompanion Function({
      required String artistId,
      required String name,
      Value<String?> art,
      Value<int> plays,
      Value<int> ms,
      Value<int> rowid,
    });
typedef $$StatsArtistsTableTableUpdateCompanionBuilder =
    StatsArtistsTableCompanion Function({
      Value<String> artistId,
      Value<String> name,
      Value<String?> art,
      Value<int> plays,
      Value<int> ms,
      Value<int> rowid,
    });

class $$StatsArtistsTableTableFilterComposer
    extends Composer<_$AppDatabase, $StatsArtistsTableTable> {
  $$StatsArtistsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get art => $composableBuilder(
    column: $table.art,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plays => $composableBuilder(
    column: $table.plays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ms => $composableBuilder(
    column: $table.ms,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StatsArtistsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StatsArtistsTableTable> {
  $$StatsArtistsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get art => $composableBuilder(
    column: $table.art,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plays => $composableBuilder(
    column: $table.plays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ms => $composableBuilder(
    column: $table.ms,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatsArtistsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatsArtistsTableTable> {
  $$StatsArtistsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get art =>
      $composableBuilder(column: $table.art, builder: (column) => column);

  GeneratedColumn<int> get plays =>
      $composableBuilder(column: $table.plays, builder: (column) => column);

  GeneratedColumn<int> get ms =>
      $composableBuilder(column: $table.ms, builder: (column) => column);
}

class $$StatsArtistsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatsArtistsTableTable,
          StatsArtistsTableData,
          $$StatsArtistsTableTableFilterComposer,
          $$StatsArtistsTableTableOrderingComposer,
          $$StatsArtistsTableTableAnnotationComposer,
          $$StatsArtistsTableTableCreateCompanionBuilder,
          $$StatsArtistsTableTableUpdateCompanionBuilder,
          (
            StatsArtistsTableData,
            BaseReferences<
              _$AppDatabase,
              $StatsArtistsTableTable,
              StatsArtistsTableData
            >,
          ),
          StatsArtistsTableData,
          PrefetchHooks Function()
        > {
  $$StatsArtistsTableTableTableManager(
    _$AppDatabase db,
    $StatsArtistsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatsArtistsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatsArtistsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatsArtistsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> artistId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> art = const Value.absent(),
                Value<int> plays = const Value.absent(),
                Value<int> ms = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatsArtistsTableCompanion(
                artistId: artistId,
                name: name,
                art: art,
                plays: plays,
                ms: ms,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String artistId,
                required String name,
                Value<String?> art = const Value.absent(),
                Value<int> plays = const Value.absent(),
                Value<int> ms = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatsArtistsTableCompanion.insert(
                artistId: artistId,
                name: name,
                art: art,
                plays: plays,
                ms: ms,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StatsArtistsTableTable, StatsArtistsTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $StatsArtistsTableTable,
                    StatsArtistsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StatsArtistsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatsArtistsTableTable,
      StatsArtistsTableData,
      $$StatsArtistsTableTableFilterComposer,
      $$StatsArtistsTableTableOrderingComposer,
      $$StatsArtistsTableTableAnnotationComposer,
      $$StatsArtistsTableTableCreateCompanionBuilder,
      $$StatsArtistsTableTableUpdateCompanionBuilder,
      (
        StatsArtistsTableData,
        BaseReferences<
          _$AppDatabase,
          $StatsArtistsTableTable,
          StatsArtistsTableData
        >,
      ),
      StatsArtistsTableData,
      PrefetchHooks Function()
    >;
typedef $$StatsDaysTableTableCreateCompanionBuilder =
    StatsDaysTableCompanion Function({
      required String day,
      Value<int> ms,
      Value<int> rowid,
    });
typedef $$StatsDaysTableTableUpdateCompanionBuilder =
    StatsDaysTableCompanion Function({
      Value<String> day,
      Value<int> ms,
      Value<int> rowid,
    });

class $$StatsDaysTableTableFilterComposer
    extends Composer<_$AppDatabase, $StatsDaysTableTable> {
  $$StatsDaysTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ms => $composableBuilder(
    column: $table.ms,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StatsDaysTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StatsDaysTableTable> {
  $$StatsDaysTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ms => $composableBuilder(
    column: $table.ms,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatsDaysTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatsDaysTableTable> {
  $$StatsDaysTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get ms =>
      $composableBuilder(column: $table.ms, builder: (column) => column);
}

class $$StatsDaysTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatsDaysTableTable,
          StatsDaysTableData,
          $$StatsDaysTableTableFilterComposer,
          $$StatsDaysTableTableOrderingComposer,
          $$StatsDaysTableTableAnnotationComposer,
          $$StatsDaysTableTableCreateCompanionBuilder,
          $$StatsDaysTableTableUpdateCompanionBuilder,
          (
            StatsDaysTableData,
            BaseReferences<
              _$AppDatabase,
              $StatsDaysTableTable,
              StatsDaysTableData
            >,
          ),
          StatsDaysTableData,
          PrefetchHooks Function()
        > {
  $$StatsDaysTableTableTableManager(
    _$AppDatabase db,
    $StatsDaysTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatsDaysTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatsDaysTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatsDaysTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> day = const Value.absent(),
            Value<int> ms = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => StatsDaysTableCompanion(day: day, ms: ms, rowid: rowid),
          createCompanionCallback: ({
            required String day,
            Value<int> ms = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => StatsDaysTableCompanion.insert(day: day, ms: ms, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StatsDaysTableTable, StatsDaysTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StatsDaysTableTable,
                    StatsDaysTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StatsDaysTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatsDaysTableTable,
      StatsDaysTableData,
      $$StatsDaysTableTableFilterComposer,
      $$StatsDaysTableTableOrderingComposer,
      $$StatsDaysTableTableAnnotationComposer,
      $$StatsDaysTableTableCreateCompanionBuilder,
      $$StatsDaysTableTableUpdateCompanionBuilder,
      (
        StatsDaysTableData,
        BaseReferences<_$AppDatabase, $StatsDaysTableTable, StatsDaysTableData>,
      ),
      StatsDaysTableData,
      PrefetchHooks Function()
    >;
typedef $$StatsMonthsTableTableCreateCompanionBuilder =
    StatsMonthsTableCompanion Function({
      required String month,
      required String json,
      Value<int> rowid,
    });
typedef $$StatsMonthsTableTableUpdateCompanionBuilder =
    StatsMonthsTableCompanion Function({
      Value<String> month,
      Value<String> json,
      Value<int> rowid,
    });

class $$StatsMonthsTableTableFilterComposer
    extends Composer<_$AppDatabase, $StatsMonthsTableTable> {
  $$StatsMonthsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StatsMonthsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StatsMonthsTableTable> {
  $$StatsMonthsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatsMonthsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatsMonthsTableTable> {
  $$StatsMonthsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$StatsMonthsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatsMonthsTableTable,
          StatsMonthsTableData,
          $$StatsMonthsTableTableFilterComposer,
          $$StatsMonthsTableTableOrderingComposer,
          $$StatsMonthsTableTableAnnotationComposer,
          $$StatsMonthsTableTableCreateCompanionBuilder,
          $$StatsMonthsTableTableUpdateCompanionBuilder,
          (
            StatsMonthsTableData,
            BaseReferences<
              _$AppDatabase,
              $StatsMonthsTableTable,
              StatsMonthsTableData
            >,
          ),
          StatsMonthsTableData,
          PrefetchHooks Function()
        > {
  $$StatsMonthsTableTableTableManager(
    _$AppDatabase db,
    $StatsMonthsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatsMonthsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatsMonthsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatsMonthsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> month = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatsMonthsTableCompanion(
                month: month,
                json: json,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String month,
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => StatsMonthsTableCompanion.insert(
                month: month,
                json: json,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StatsMonthsTableTable, StatsMonthsTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $StatsMonthsTableTable,
                    StatsMonthsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StatsMonthsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatsMonthsTableTable,
      StatsMonthsTableData,
      $$StatsMonthsTableTableFilterComposer,
      $$StatsMonthsTableTableOrderingComposer,
      $$StatsMonthsTableTableAnnotationComposer,
      $$StatsMonthsTableTableCreateCompanionBuilder,
      $$StatsMonthsTableTableUpdateCompanionBuilder,
      (
        StatsMonthsTableData,
        BaseReferences<
          _$AppDatabase,
          $StatsMonthsTableTable,
          StatsMonthsTableData
        >,
      ),
      StatsMonthsTableData,
      PrefetchHooks Function()
    >;
typedef $$LyricOffsetsTableTableCreateCompanionBuilder =
    LyricOffsetsTableCompanion Function({
      required String key,
      required int ms,
      Value<bool> manual,
      Value<int> rowid,
    });
typedef $$LyricOffsetsTableTableUpdateCompanionBuilder =
    LyricOffsetsTableCompanion Function({
      Value<String> key,
      Value<int> ms,
      Value<bool> manual,
      Value<int> rowid,
    });

class $$LyricOffsetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $LyricOffsetsTableTable> {
  $$LyricOffsetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ms => $composableBuilder(
    column: $table.ms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get manual => $composableBuilder(
    column: $table.manual,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LyricOffsetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LyricOffsetsTableTable> {
  $$LyricOffsetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ms => $composableBuilder(
    column: $table.ms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get manual => $composableBuilder(
    column: $table.manual,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LyricOffsetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LyricOffsetsTableTable> {
  $$LyricOffsetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get ms =>
      $composableBuilder(column: $table.ms, builder: (column) => column);

  GeneratedColumn<bool> get manual =>
      $composableBuilder(column: $table.manual, builder: (column) => column);
}

class $$LyricOffsetsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LyricOffsetsTableTable,
          LyricOffsetsTableData,
          $$LyricOffsetsTableTableFilterComposer,
          $$LyricOffsetsTableTableOrderingComposer,
          $$LyricOffsetsTableTableAnnotationComposer,
          $$LyricOffsetsTableTableCreateCompanionBuilder,
          $$LyricOffsetsTableTableUpdateCompanionBuilder,
          (
            LyricOffsetsTableData,
            BaseReferences<
              _$AppDatabase,
              $LyricOffsetsTableTable,
              LyricOffsetsTableData
            >,
          ),
          LyricOffsetsTableData,
          PrefetchHooks Function()
        > {
  $$LyricOffsetsTableTableTableManager(
    _$AppDatabase db,
    $LyricOffsetsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LyricOffsetsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LyricOffsetsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LyricOffsetsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int> ms = const Value.absent(),
                Value<bool> manual = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LyricOffsetsTableCompanion(
                key: key,
                ms: ms,
                manual: manual,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required int ms,
                Value<bool> manual = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LyricOffsetsTableCompanion.insert(
                key: key,
                ms: ms,
                manual: manual,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LyricOffsetsTableTable, LyricOffsetsTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LyricOffsetsTableTable,
                    LyricOffsetsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LyricOffsetsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LyricOffsetsTableTable,
      LyricOffsetsTableData,
      $$LyricOffsetsTableTableFilterComposer,
      $$LyricOffsetsTableTableOrderingComposer,
      $$LyricOffsetsTableTableAnnotationComposer,
      $$LyricOffsetsTableTableCreateCompanionBuilder,
      $$LyricOffsetsTableTableUpdateCompanionBuilder,
      (
        LyricOffsetsTableData,
        BaseReferences<
          _$AppDatabase,
          $LyricOffsetsTableTable,
          LyricOffsetsTableData
        >,
      ),
      LyricOffsetsTableData,
      PrefetchHooks Function()
    >;
typedef $$QueueStateTableTableCreateCompanionBuilder =
    QueueStateTableCompanion Function({Value<int> id, required String json});
typedef $$QueueStateTableTableUpdateCompanionBuilder =
    QueueStateTableCompanion Function({Value<int> id, Value<String> json});

class $$QueueStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $QueueStateTableTable> {
  $$QueueStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueStateTableTable> {
  $$QueueStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueStateTableTable> {
  $$QueueStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$QueueStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueStateTableTable,
          QueueStateTableData,
          $$QueueStateTableTableFilterComposer,
          $$QueueStateTableTableOrderingComposer,
          $$QueueStateTableTableAnnotationComposer,
          $$QueueStateTableTableCreateCompanionBuilder,
          $$QueueStateTableTableUpdateCompanionBuilder,
          (
            QueueStateTableData,
            BaseReferences<
              _$AppDatabase,
              $QueueStateTableTable,
              QueueStateTableData
            >,
          ),
          QueueStateTableData,
          PrefetchHooks Function()
        > {
  $$QueueStateTableTableTableManager(
    _$AppDatabase db,
    $QueueStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueStateTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> json = const Value.absent(),
          }) => QueueStateTableCompanion(id: id, json: json),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String json,
          }) => QueueStateTableCompanion.insert(id: id, json: json),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QueueStateTableTable, QueueStateTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $QueueStateTableTable,
                    QueueStateTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueStateTableTable,
      QueueStateTableData,
      $$QueueStateTableTableFilterComposer,
      $$QueueStateTableTableOrderingComposer,
      $$QueueStateTableTableAnnotationComposer,
      $$QueueStateTableTableCreateCompanionBuilder,
      $$QueueStateTableTableUpdateCompanionBuilder,
      (
        QueueStateTableData,
        BaseReferences<
          _$AppDatabase,
          $QueueStateTableTable,
          QueueStateTableData
        >,
      ),
      QueueStateTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TracksTableTableTableManager get tracksTable =>
      $$TracksTableTableTableManager(_db, _db.tracksTable);
  $$LikedTableTableTableManager get likedTable =>
      $$LikedTableTableTableManager(_db, _db.likedTable);
  $$RecentsTableTableTableManager get recentsTable =>
      $$RecentsTableTableTableManager(_db, _db.recentsTable);
  $$FollowedTableTableTableManager get followedTable =>
      $$FollowedTableTableTableManager(_db, _db.followedTable);
  $$PlaylistsTableTableTableManager get playlistsTable =>
      $$PlaylistsTableTableTableManager(_db, _db.playlistsTable);
  $$PlaylistTracksTableTableTableManager get playlistTracksTable =>
      $$PlaylistTracksTableTableTableManager(_db, _db.playlistTracksTable);
  $$DownloadsTableTableTableManager get downloadsTable =>
      $$DownloadsTableTableTableManager(_db, _db.downloadsTable);
  $$StreamCacheTableTableTableManager get streamCacheTable =>
      $$StreamCacheTableTableTableManager(_db, _db.streamCacheTable);
  $$SongMatchesTableTableTableManager get songMatchesTable =>
      $$SongMatchesTableTableTableManager(_db, _db.songMatchesTable);
  $$StatsTracksTableTableTableManager get statsTracksTable =>
      $$StatsTracksTableTableTableManager(_db, _db.statsTracksTable);
  $$StatsArtistsTableTableTableManager get statsArtistsTable =>
      $$StatsArtistsTableTableTableManager(_db, _db.statsArtistsTable);
  $$StatsDaysTableTableTableManager get statsDaysTable =>
      $$StatsDaysTableTableTableManager(_db, _db.statsDaysTable);
  $$StatsMonthsTableTableTableManager get statsMonthsTable =>
      $$StatsMonthsTableTableTableManager(_db, _db.statsMonthsTable);
  $$LyricOffsetsTableTableTableManager get lyricOffsetsTable =>
      $$LyricOffsetsTableTableTableManager(_db, _db.lyricOffsetsTable);
  $$QueueStateTableTableTableManager get queueStateTable =>
      $$QueueStateTableTableTableManager(_db, _db.queueStateTable);
}
