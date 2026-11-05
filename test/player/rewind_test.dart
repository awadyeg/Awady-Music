import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/stats_models.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/player/rewind.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Track mkTrack(String id, {int duration = 200, String artistName = 'Artist'}) {
  return Track(
    id: id,
    title: 'Song $id',
    duration: duration,
    artist: Artist(id: 'a1', name: artistName),
  );
}

TrackAgg mkTrackAgg(String id, int plays, int ms) =>
    TrackAgg(track: mkTrack(id), plays: plays, ms: ms);

ArtistAgg mkArtistAgg(String name, int plays, int ms) =>
    ArtistAgg(name: name, plays: plays, ms: ms);

MonthAgg mkMonth({
  int ms = 600000,
  int plays = 9,
  Map<String, TrackAgg>? tracks,
  Map<String, ArtistAgg>? artists,
}) {
  return MonthAgg(
    ms: ms,
    plays: plays,
    tracks:
        tracks ??
        {'t1': mkTrackAgg('t1', 5, 300000), 't2': mkTrackAgg('t2', 4, 200000)},
    artists: artists ?? {'Artist': mkArtistAgg('Artist', 9, 500000)},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('T-37 buildRewind', () {
    test('builds a sorted rewind for a qualifying month', () {
      final tracks = <String, TrackAgg>{};
      for (var i = 1; i <= 6; i++) {
        tracks['t$i'] = mkTrackAgg('t$i', i, i * 100000);
      }
      final stats = StatsState(months: {'2020-09': mkMonth(tracks: tracks)});

      final r = buildRewind('2020-09', stats: stats, locale: 'en');
      expect(r, isNotNull);
      expect(r?.key, '2020-09');
      expect(r?.partial, isFalse);
      expect(r?.ms, 600000);
      expect(r?.plays, 9);
      expect(r?.tracks.length, 5);
      expect(r?.tracks.map((t) => t.track.id).toList(), [
        't6',
        't5',
        't4',
        't3',
        't2',
      ]);
      expect(r?.artists.map((a) => a.name).toList(), ['Artist']);
      expect(r?.trackCount, 6);
      expect(r?.artistCount, 1);

      expect(r?.label, 'September');
      expect(r?.full, 'September 2020');
    });

    test('returns null below the closed-edition thresholds', () {
      final stats = StatsState(
        months: {
          '2020-08': mkMonth(ms: 599999), // enough plays, not enough ms
          '2020-09': mkMonth(plays: 4), // enough ms, not enough plays
        },
      );
      expect(buildRewind('2020-08', stats: stats), isNull);
      expect(buildRewind('2020-09', stats: stats), isNull);
    });

    test('partial edition only needs 3 plays', () {
      final stats = StatsState(
        months: {
          '2020-09': mkMonth(ms: 0, plays: 3),
          '2020-10': mkMonth(ms: 0, plays: 2),
        },
      );
      final ok = buildRewind('2020-09', stats: stats, partial: true);
      expect(ok, isNotNull);
      expect(ok?.partial, isTrue);
      expect(buildRewind('2020-10', stats: stats, partial: true), isNull);
    });

    test('returns null for an unknown or empty month', () {
      final stats = StatsState(months: {'2020-09': mkMonth(tracks: {})});
      expect(buildRewind('1999-01', stats: stats), isNull);
      expect(buildRewind('2020-09', stats: stats), isNull);
    });
  });

  group('T-37 latestRewind', () {
    test('picks the newest month strictly before the current one', () {
      final cur = monthKey();
      final stats = StatsState(
        months: {
          '2020-01': mkMonth(),
          '2020-03': mkMonth(),
          cur: mkMonth(),
          '2999-01': mkMonth(),
        },
      );
      final r = latestRewind(stats: stats);
      expect(r?.key, '2020-03');
      expect(r?.partial, isFalse);
    });

    test('returns null when no closed month qualifies', () {
      final stats = StatsState(months: {'2020-03': mkMonth(plays: 2)});
      expect(latestRewind(stats: stats), isNull);
    });
  });

  group('T-37 currentRewind', () {
    test('returns the in-progress month as a partial edition', () {
      final cur = monthKey();
      final stats = StatsState(months: {cur: mkMonth(ms: 0, plays: 3)});
      final r = currentRewind(stats: stats);
      expect(r?.key, cur);
      expect(r?.partial, isTrue);
    });

    test('returns null while current month is below threshold', () {
      final cur = monthKey();
      final stats = StatsState(months: {cur: mkMonth(ms: 0, plays: 1)});
      expect(currentRewind(stats: stats), isNull);
    });
  });

  group('T-37 availableRewind', () {
    test('prefers the latest closed month over current partial', () {
      final cur = monthKey();
      final stats = StatsState(
        months: {'2020-05': mkMonth(), cur: mkMonth(ms: 0, plays: 3)},
      );
      final r = availableRewind(stats: stats);
      expect(r?.key, '2020-05');
      expect(r?.partial, isFalse);
    });

    test('falls back to current partial when nothing closed qualifies', () {
      final cur = monthKey();
      final stats = StatsState(months: {cur: mkMonth(ms: 0, plays: 3)});
      final r = availableRewind(stats: stats);
      expect(r?.key, cur);
      expect(r?.partial, isTrue);
    });

    test('falls back when the only closed month is below threshold', () {
      final cur = monthKey();
      final stats = StatsState(
        months: {
          '2020-05': mkMonth(ms: 0, plays: 4),
          cur: mkMonth(ms: 0, plays: 3),
        },
      );
      final r = availableRewind(stats: stats);
      expect(r?.key, cur);
      expect(r?.partial, isTrue);
    });
  });

  group('T-37 isRewindSeen and markRewindSeen', () {
    test(
      'marks and checks seen state accurately with legacy fallback',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        expect(isRewindSeen('2026-10', prefs), isFalse);

        await markRewindSeen('2026-10', prefs);
        expect(isRewindSeen('2026-10', prefs), isTrue);
        expect(isRewindSeen('2026-11', prefs), isFalse);

        // Legacy fallback
        SharedPreferences.setMockInitialValues({
          'freebify-rewind-seen': '2025-12',
        });
        final legacyPrefs = await SharedPreferences.getInstance();
        expect(isRewindSeen('2025-12', legacyPrefs), isTrue);
      },
    );
  });
}
