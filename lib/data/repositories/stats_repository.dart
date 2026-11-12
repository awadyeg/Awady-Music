import 'dart:async';
import 'dart:convert';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/stats_models.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/models/track_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int maxTracks = 300;
const int maxArtists = 200;
const int maxDays = 120;
const int maxMonths = 14;
const int maxMonthTracks = 60;
const int maxMonthArtists = 40;
const int flushIntervalMs = 15000;

/// Returns the local calendar day in `YYYY-MM-DD` format.
String dayKey([DateTime? d]) {
  final dt = d ?? DateTime.now();
  final year = dt.year.toString();
  final month = dt.month.toString().padLeft(2, '0');
  final day = dt.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Returns the local calendar month in `YYYY-MM` format.
String monthKey([DateTime? d]) {
  final dt = d ?? DateTime.now();
  final year = dt.year.toString();
  final month = dt.month.toString().padLeft(2, '0');
  return '$year-$month';
}

/// Prunes map entries keeping the highest entries by `msOf` up to [cap].
Map<String, T> prune<T extends Object>(
  Map<String, T> rec,
  int cap,
  int Function(T) msOf,
) {
  if (rec.length <= cap) return Map.from(rec);
  final keys = rec.keys.toList()
    ..sort((a, b) => msOf(rec[b]!).compareTo(msOf(rec[a]!)));
  final keep = keys.take(cap).toSet();
  final out = <String, T>{};
  for (final k in rec.keys) {
    if (keep.contains(k)) {
      out[k] = rec[k]!;
    }
  }
  return out;
}

/// Prunes day buckets keeping the newest [maxDays] days.
Map<String, int> pruneDays(Map<String, int> days) {
  if (days.length <= maxDays) return Map.from(days);
  final keys = days.keys.toList()..sort();
  final keep = keys.skip(keys.length - maxDays).toSet();
  final out = <String, int>{};
  for (final k in days.keys) {
    if (keep.contains(k)) {
      out[k] = days[k]!;
    }
  }
  return out;
}

/// Prunes month buckets keeping the newest [maxMonths] months.
Map<String, MonthAgg> pruneMonths(Map<String, MonthAgg> months) {
  if (months.length <= maxMonths) return Map.from(months);
  final keys = months.keys.toList()..sort();
  final keep = keys.skip(keys.length - maxMonths).toSet();
  final out = <String, MonthAgg>{};
  for (final k in months.keys) {
    if (keep.contains(k)) {
      out[k] = months[k]!;
    }
  }
  return out;
}

/// Validates and sanitizes a map of track aggregates.
Map<String, TrackAgg> sanTracks(dynamic v, int cap) {
  final out = <String, TrackAgg>{};
  if (v is Map) {
    for (final entry in v.entries) {
      final a = entry.value;
      if (a is Map) {
        final rawTrack = a['track'];
        if (rawTrack is Map<String, dynamic> && isValidTrack(rawTrack)) {
          final t = slimTrack(repairTrack(Track.fromJson(rawTrack)));
          final plays = (a['plays'] is num && (a['plays'] as num) >= 0)
              ? (a['plays'] as num).toInt()
              : 0;
          final ms = (a['ms'] is num && (a['ms'] as num) >= 0)
              ? (a['ms'] as num).toInt()
              : 0;
          out[entry.key.toString()] = TrackAgg(track: t, plays: plays, ms: ms);
        }
      }
    }
  }
  return prune(out, cap, (x) => x.ms);
}

/// Validates and sanitizes a map of artist aggregates.
Map<String, ArtistAgg> sanArtists(dynamic v, int cap) {
  final out = <String, ArtistAgg>{};
  if (v is Map) {
    for (final entry in v.entries) {
      final a = entry.value;
      if (a is Map && a['name'] is String) {
        final name = a['name'] as String;
        final art = a['art'] is String ? a['art'] as String : null;
        final plays = (a['plays'] is num && (a['plays'] as num) >= 0)
            ? (a['plays'] as num).toInt()
            : 0;
        final ms = (a['ms'] is num && (a['ms'] as num) >= 0)
            ? (a['ms'] as num).toInt()
            : 0;
        out[entry.key.toString()] = ArtistAgg(
          name: name,
          art: art,
          plays: plays,
          ms: ms,
        );
      }
    }
  }
  return prune(out, cap, (x) => x.ms);
}

/// Immutable aggregated stats state.
class StatsState {
  const StatsState({
    this.tracks = const {},
    this.artists = const {},
    this.days = const {},
    this.months = const {},
    this.totalMs = 0,
    this.totalPlays = 0,
  });

  final Map<String, TrackAgg> tracks;
  final Map<String, ArtistAgg> artists;
  final Map<String, int> days;
  final Map<String, MonthAgg> months;
  final int totalMs;
  final int totalPlays;

  StatsState copyWith({
    Map<String, TrackAgg>? tracks,
    Map<String, ArtistAgg>? artists,
    Map<String, int>? days,
    Map<String, MonthAgg>? months,
    int? totalMs,
    int? totalPlays,
  }) {
    return StatsState(
      tracks: tracks ?? this.tracks,
      artists: artists ?? this.artists,
      days: days ?? this.days,
      months: months ?? this.months,
      totalMs: totalMs ?? this.totalMs,
      totalPlays: totalPlays ?? this.totalPlays,
    );
  }

  Map<String, dynamic> toJson() => {
    'tracks': tracks.map((k, v) => MapEntry(k, v.toJson())),
    'artists': artists.map((k, v) => MapEntry(k, v.toJson())),
    'days': days,
    'months': months.map((k, v) => MapEntry(k, v.toJson())),
    'totalMs': totalMs,
    'totalPlays': totalPlays,
  };
}

/// Merges persisted stats JSON into [current], validating all fields.
StatsState mergePersisted(
  dynamic persisted, [
  StatsState current = const StatsState(),
]) {
  if (persisted is! Map) return current;
  final p = persisted['state'] is Map ? (persisted['state'] as Map) : persisted;

  final days = <String, int>{};
  if (p['days'] is Map) {
    for (final entry in (p['days'] as Map).entries) {
      final k = entry.key.toString();
      final v = entry.value;
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(k) && v is num && v >= 0) {
        days[k] = v.toInt();
      }
    }
  }

  final months = <String, MonthAgg>{};
  if (p['months'] is Map) {
    for (final entry in (p['months'] as Map).entries) {
      final k = entry.key.toString();
      final v = entry.value;
      if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(k) || v is! Map) continue;
      final mMs = (v['ms'] is num && (v['ms'] as num) >= 0)
          ? (v['ms'] as num).toInt()
          : 0;
      final mPlays = (v['plays'] is num && (v['plays'] as num) >= 0)
          ? (v['plays'] as num).toInt()
          : 0;
      months[k] = MonthAgg(
        ms: mMs,
        plays: mPlays,
        tracks: sanTracks(v['tracks'], maxMonthTracks),
        artists: sanArtists(v['artists'], maxMonthArtists),
      );
    }
  }

  final totMs = (p['totalMs'] is num && (p['totalMs'] as num) >= 0)
      ? (p['totalMs'] as num).toInt()
      : 0;
  final totPlays = (p['totalPlays'] is num && (p['totalPlays'] as num) >= 0)
      ? (p['totalPlays'] as num).toInt()
      : 0;

  return current.copyWith(
    tracks: sanTracks(p['tracks'], maxTracks),
    artists: sanArtists(p['artists'], maxArtists),
    days: pruneDays(days),
    months: pruneMonths(months),
    totalMs: totMs,
    totalPlays: totPlays,
  );
}

/// Repository responsible for aggregate listening statistics.
class StatsRepository {
  StatsRepository({this.prefs, this.db}) {
    _hydrate();
  }

  final SharedPreferences? prefs;
  final AppDatabase? db;

  StatsState _state = const StatsState();
  StatsState get state => _state;

  List<Track> get mostPlayedTracks {
    final entries = _state.tracks.values.toList()
      ..sort((a, b) {
        final scoreA = a.plays * 60000 + a.ms;
        final scoreB = b.plays * 60000 + b.ms;
        return scoreB.compareTo(scoreA);
      });
    return entries.map((e) => e.track).toList();
  }

  void recordImportedFavorites(List<Track> tracks) {
    if (tracks.isEmpty) return;
    final updatedTracks = Map<String, TrackAgg>.from(_state.tracks);
    final updatedArtists = Map<String, ArtistAgg>.from(_state.artists);

    for (final track in tracks) {
      final slimmed = slimTrack(track);
      final prev = updatedTracks[track.id];
      updatedTracks[track.id] = TrackAgg(
        track: slimmed,
        plays: (prev?.plays ?? 0) + 3,
        ms: (prev?.ms ?? 0) + 180000,
      );

      final artistName = track.artist.name.trim().isNotEmpty
          ? track.artist.name.trim()
          : 'Unknown artist';
      final prevArt = updatedArtists[artistName];
      final art =
          track.artwork?.s480 ?? track.artwork?.s150 ?? track.artwork?.fallback;
      updatedArtists[artistName] = ArtistAgg(
        name: artistName,
        plays: (prevArt?.plays ?? 0) + 3,
        ms: (prevArt?.ms ?? 0) + 180000,
        art: prevArt?.art ?? art,
      );
    }

    _state = _state.copyWith(
      tracks: prune(updatedTracks, maxTracks, (t) => t.ms),
      artists: prune(updatedArtists, maxArtists, (a) => a.ms),
    );
    _controller.add(_state);
    _persist();
  }

  final StreamController<StatsState> _controller =
      StreamController<StatsState>.broadcast();
  Stream<StatsState> get stream => _controller.stream;

  // Pending deltas accumulated between flushes
  final Map<String, int> _pendMs = {};
  final Map<String, Track> _pendTracks = {};
  int _pendDays = 0;
  int _pendTotal = 0;
  Timer? _flushTimer;

  void _hydrate() {
    if (prefs == null) return;
    try {
      final raw =
          prefs!.getString('awady_stats') ?? prefs!.getString('freebify-stats');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        _state = mergePersisted(decoded);
        _controller.add(_state);
      }
    } on Object catch (e, st) {
      Log.w('Failed hydrating stats: $e', e, st);
    }
  }

  /// Sets state directly (useful for tests or imports).
  void setState(StatsState newState) {
    _state = newState;
    _controller.add(_state);
    _persist();
  }

  /// Accumulates listening time in milliseconds for [track].
  void recordMs(Track? track, int ms) {
    if (track == null || ms <= 0) return;
    _pendMs[track.id] = (_pendMs[track.id] ?? 0) + ms;
    if (!_pendTracks.containsKey(track.id)) {
      _pendTracks[track.id] = slimTrack(track);
    }
    _pendDays += ms;
    _pendTotal += ms;
    _scheduleFlush();
  }

  /// Increments play count counters for [track].
  void recordPlay(Track? track) {
    if (track == null) return;
    final slimmed = slimTrack(track);
    final artistName = track.artist.name.trim().isNotEmpty
        ? track.artist.name.trim()
        : 'Unknown artist';
    final art =
        track.artwork?.s480 ?? track.artwork?.s150 ?? track.artwork?.fallback;

    final prevTrack = _state.tracks[track.id];
    final prevArtist = _state.artists[artistName];

    final updatedTracks = prune(
      {
        ..._state.tracks,
        track.id: TrackAgg(
          track: slimmed,
          plays: (prevTrack?.plays ?? 0) + 1,
          ms: prevTrack?.ms ?? 0,
        ),
      },
      maxTracks,
      (v) => v.ms,
    );

    final updatedArtists = prune(
      {
        ..._state.artists,
        artistName: ArtistAgg(
          name: artistName,
          art: prevArtist?.art ?? art,
          plays: (prevArtist?.plays ?? 0) + 1,
          ms: prevArtist?.ms ?? 0,
        ),
      },
      maxArtists,
      (v) => v.ms,
    );

    final mk = monthKey();
    final curMonth = _state.months[mk] ?? MonthAgg();
    final prevMonthTrack = curMonth.tracks[track.id];
    final prevMonthArtist = curMonth.artists[artistName];

    final updatedMonthTracks = prune(
      {
        ...curMonth.tracks,
        track.id: TrackAgg(
          track: slimmed,
          plays: (prevMonthTrack?.plays ?? 0) + 1,
          ms: prevMonthTrack?.ms ?? 0,
        ),
      },
      maxMonthTracks,
      (v) => v.ms,
    );

    final updatedMonthArtists = prune(
      {
        ...curMonth.artists,
        artistName: ArtistAgg(
          name: artistName,
          art: prevMonthArtist?.art ?? art,
          plays: (prevMonthArtist?.plays ?? 0) + 1,
          ms: prevMonthArtist?.ms ?? 0,
        ),
      },
      maxMonthArtists,
      (v) => v.ms,
    );

    final updatedMonths = pruneMonths({
      ..._state.months,
      mk: MonthAgg(
        ms: curMonth.ms,
        plays: curMonth.plays + 1,
        tracks: updatedMonthTracks,
        artists: updatedMonthArtists,
      ),
    });

    _state = _state.copyWith(
      totalPlays: _state.totalPlays + 1,
      tracks: updatedTracks,
      artists: updatedArtists,
      months: updatedMonths,
    );
    _controller.add(_state);
    _persist();
  }

  /// Flushes buffered ms into state and persistent storage.
  void flush() {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (_pendMs.isEmpty && _pendTotal == 0) return;

    final msTotal = _pendTotal;
    final dayMs = _pendDays;
    final dk = dayKey();
    final mk = monthKey();

    final tracks = Map<String, TrackAgg>.from(_state.tracks);
    final artists = Map<String, ArtistAgg>.from(_state.artists);

    final monthObj = _state.months[mk];
    final mo = monthObj != null
        ? MonthAgg(
            ms: monthObj.ms,
            plays: monthObj.plays,
            tracks: Map<String, TrackAgg>.from(monthObj.tracks),
            artists: Map<String, ArtistAgg>.from(monthObj.artists),
          )
        : MonthAgg();

    for (final entry in _pendMs.entries) {
      final id = entry.key;
      final ms = entry.value;
      final t = _pendTracks[id];
      if (t == null) continue;

      final prev = tracks[id];
      tracks[id] = TrackAgg(
        track: t,
        plays: prev?.plays ?? 0,
        ms: (prev?.ms ?? 0) + ms,
      );

      final artistName = t.artist.name.trim().isNotEmpty
          ? t.artist.name.trim()
          : 'Unknown artist';
      final prevA = artists[artistName];
      final art =
          prevA?.art ??
          t.artwork?.s480 ??
          t.artwork?.s150 ??
          t.artwork?.fallback;

      artists[artistName] = ArtistAgg(
        name: artistName,
        art: art,
        plays: prevA?.plays ?? 0,
        ms: (prevA?.ms ?? 0) + ms,
      );

      final prevMT = mo.tracks[id];
      mo.tracks[id] = TrackAgg(
        track: t,
        plays: prevMT?.plays ?? 0,
        ms: (prevMT?.ms ?? 0) + ms,
      );

      final prevMA = mo.artists[artistName];
      mo.artists[artistName] = ArtistAgg(
        name: artistName,
        art: prevMA?.art ?? art,
        plays: prevMA?.plays ?? 0,
        ms: (prevMA?.ms ?? 0) + ms,
      );
    }

    mo.ms += msTotal;
    _pendMs.clear();
    _pendTracks.clear();
    _pendDays = 0;
    _pendTotal = 0;

    final updatedMonths = Map<String, MonthAgg>.from(_state.months)
      ..[mk] = MonthAgg(
        ms: mo.ms,
        plays: mo.plays,
        tracks: prune(mo.tracks, maxMonthTracks, (v) => v.ms),
        artists: prune(mo.artists, maxMonthArtists, (v) => v.ms),
      );

    final updatedDays = Map<String, int>.from(_state.days)
      ..[dk] = (_state.days[dk] ?? 0) + dayMs;

    _state = _state.copyWith(
      totalMs: _state.totalMs + msTotal,
      days: pruneDays(updatedDays),
      months: pruneMonths(updatedMonths),
      tracks: prune(tracks, maxTracks, (v) => v.ms),
      artists: prune(artists, maxArtists, (v) => v.ms),
    );

    _controller.add(_state);
    _persist();
  }

  void _scheduleFlush() {
    if (_flushTimer != null) return;
    _flushTimer = Timer(const Duration(milliseconds: flushIntervalMs), () {
      _flushTimer = null;
      try {
        flush();
      } on Object catch (_) {}
    });
  }

  void _persist() {
    if (prefs == null) return;
    try {
      final jsonString = jsonEncode({'version': 2, 'state': _state.toJson()});
      unawaited(prefs!.setString('awady_stats', jsonString));
    } on Object catch (e, st) {
      Log.w('Failed persisting stats to prefs: $e', e, st);
    }

    // Also persist snapshot to StatsDao if db is available
    if (db != null) {
      try {
        final mk = monthKey();
        final currentMonth = _state.months[mk];
        if (currentMonth != null) {
          unawaited(
            db!.statsDao.upsertMonth(mk, jsonEncode(currentMonth.toJson())),
          );
        }
      } on Object catch (_) {}
    }
  }

  void dispose() {
    _flushTimer?.cancel();
    _flushTimer = null;
    flush();
    unawaited(_controller.close());
  }
}

/// Bridges player playback position ticks to [StatsRepository].
class StatsRecorder {
  StatsRecorder({required this.repository});

  final StatsRepository repository;

  double _lastTime = 0;
  String? _lastId;
  String? _countedForId;
  int _accMs = 0;

  void onTick({
    required Track? currentTrack,
    required double currentTimeSeconds,
    required bool isPlaying,
  }) {
    try {
      if (currentTrack == null) {
        _lastId = null;
        return;
      }

      if (currentTrack.id != _lastId) {
        repository.flush();
        _lastId = currentTrack.id;
        _countedForId = null;
        _accMs = 0;
        _lastTime = currentTimeSeconds;
      }

      if (!isPlaying) {
        _lastTime = currentTimeSeconds;
        repository.flush();
        return;
      }

      final dt = currentTimeSeconds - _lastTime;
      _lastTime = currentTimeSeconds;
      if (dt <= 0 || dt > 6) return; // seek or stall

      final ms = (dt * 1000).round();
      _accMs += ms;
      repository.recordMs(currentTrack, ms);

      final qualifies30s = _accMs >= 30000;
      final qualifies50p =
          currentTrack.duration > 0 &&
          _accMs >= (currentTrack.duration * 1000 * 0.5).round();

      if (_countedForId != currentTrack.id && (qualifies30s || qualifies50p)) {
        _countedForId = currentTrack.id;
        repository.recordPlay(currentTrack);
      }
    } on Object catch (e, st) {
      Log.w('StatsRecorder onTick error: $e', e, st);
    }
  }
}

/// Provider for [StatsRepository].
final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final db = ref.watch(appDatabaseProvider);
  final repo = StatsRepository(prefs: prefs, db: db);
  ref.onDispose(repo.dispose);
  return repo;
});

/// Provider exposing current [StatsState] as a stream.
final statsStateProvider = StreamProvider<StatsState>((ref) {
  final repo = ref.watch(statsRepositoryProvider);
  return repo.stream;
});
