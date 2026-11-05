import 'dart:convert';

import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late StatsRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = StatsRepository(prefs: prefs);
  });

  group('T-36 recordMs + flush', () {
    test('buffers ms until flush lands it in every bucket', () {
      final t = mkTrack('t1');
      repo.recordMs(t, 5000);
      // nothing in state yet - recordMs only buffers
      expect(repo.state.totalMs, 0);

      repo
        ..recordMs(t, 3000)
        ..flush();

      final s = repo.state;
      expect(s.totalMs, 8000);
      expect(s.days[dayKey()], 8000);
      expect(s.months[monthKey()]?.ms, 8000);
      expect(s.months[monthKey()]?.tracks['t1']?.ms, 8000);
      expect(s.months[monthKey()]?.artists['Artist']?.ms, 8000);
      expect(s.tracks['t1']?.ms, 8000);
      expect(s.artists['Artist']?.ms, 8000);
    });

    test('ignores non-positive and non-finite ms', () {
      final t = mkTrack('t1');
      repo
        ..recordMs(t, 0)
        ..recordMs(t, -5)
        ..flush();

      expect(repo.state.totalMs, 0);
      expect(repo.state.tracks.isEmpty, isTrue);
    });
  });

  group('T-36 recordPlay', () {
    test('increments play counters everywhere', () {
      final t = mkTrack('t1');
      repo
        ..recordPlay(t)
        ..recordPlay(t);

      final s = repo.state;
      final mk = monthKey();
      expect(s.totalPlays, 2);
      expect(s.months[mk]?.plays, 2);
      expect(s.months[mk]?.tracks['t1']?.plays, 2);
      expect(s.months[mk]?.artists['Artist']?.plays, 2);
      expect(s.tracks['t1']?.plays, 2);
      expect(s.artists['Artist']?.plays, 2);
    });

    test('caps the month track bucket at 60 entries', () {
      final mk = monthKey();
      for (var i = 0; i < 65; i++) {
        repo.recordPlay(mkTrack('cap-$i'));
      }
      final m = repo.state.months[mk]!;
      expect(m.plays, 65);
      expect(m.tracks.length, lessThanOrEqualTo(60));
    });
  });

  group('T-36 hydration & validation', () {
    test('keeps valid persisted entries and drops corrupt ones', () async {
      final persistedJson = jsonEncode({
        'version': 2,
        'state': {
          'tracks': {
            't1': {'track': mkTrack('t1').toJson(), 'plays': 3, 'ms': 9000},
            'bad': {
              'track': {'x': 1},
            },
          },
          'months': {
            '2026-09': {
              'ms': 600000,
              'plays': 9,
              'tracks': {
                't1': {'track': mkTrack('t1').toJson(), 'plays': 3, 'ms': 9000},
              },
              'artists': {
                'Artist': {
                  'name': 'Artist',
                  'art': null,
                  'plays': 3,
                  'ms': 9000,
                },
              },
            },
          },
          'totalMs': 600000,
          'totalPlays': 9,
        },
      });

      SharedPreferences.setMockInitialValues({'freebify-stats': persistedJson});
      final p = await SharedPreferences.getInstance();
      final freshRepo = StatsRepository(prefs: p);

      final s = freshRepo.state;
      expect(s.tracks['t1']?.plays, 3);
      expect(s.tracks['t1']?.ms, 9000);
      expect(s.tracks['bad'], isNull);
      expect(s.months['2026-09']?.ms, 600000);
      expect(s.months['2026-09']?.plays, 9);
      expect(s.months['2026-09']?.tracks['t1']?.plays, 3);
      expect(s.months['2026-09']?.artists['Artist']?.plays, 3);
      expect(s.totalMs, 600000);
      expect(s.totalPlays, 9);
    });

    test('keeps zeroed state on a garbage persisted blob', () async {
      SharedPreferences.setMockInitialValues({
        'awady_stats': jsonEncode({'nope': true}),
      });
      final p = await SharedPreferences.getInstance();
      final freshRepo = StatsRepository(prefs: p);

      final s = freshRepo.state;
      expect(s.tracks, isEmpty);
      expect(s.artists, isEmpty);
      expect(s.days, isEmpty);
      expect(s.months, isEmpty);
      expect(s.totalMs, 0);
      expect(s.totalPlays, 0);
    });
  });

  group('T-36 StatsRecorder playback tick integration', () {
    test('records ms and triggers recordPlay when passing 30 seconds', () {
      final recorder = StatsRecorder(repository: repo);
      final t = mkTrack('t1', duration: 300);

      // Advance 5 seconds
      recorder
        ..onTick(currentTrack: t, currentTimeSeconds: 0, isPlaying: true)
        ..onTick(currentTrack: t, currentTimeSeconds: 5, isPlaying: true);
      repo.flush();
      expect(repo.state.totalMs, 5000);
      expect(repo.state.totalPlays, 0);

      // Advance by 26 more seconds (total 31s)
      for (var sec = 6; sec <= 31; sec += 5) {
        recorder.onTick(
          currentTrack: t,
          currentTimeSeconds: sec.toDouble(),
          isPlaying: true,
        );
      }
      repo.flush();
      expect(repo.state.totalPlays, 1);
      expect(repo.state.tracks['t1']?.plays, 1);
    });

    test('records play at 50% for shorter tracks', () {
      final recorder = StatsRecorder(repository: repo);
      // 20-second track: 50% is 10s
      final shortTrack = mkTrack('short1', duration: 20);

      recorder.onTick(
        currentTrack: shortTrack,
        currentTimeSeconds: 0,
        isPlaying: true,
      );

      for (var sec = 2; sec <= 11; sec += 2) {
        recorder.onTick(
          currentTrack: shortTrack,
          currentTimeSeconds: sec.toDouble(),
          isPlaying: true,
        );
      }
      repo.flush();
      expect(repo.state.totalPlays, 1);
    });

    test('ignores seeking delta > 6 seconds', () {
      final recorder = StatsRecorder(repository: repo);
      final t = mkTrack('t1');

      // Sudden jump from 1s to 50s (delta = 49s > 6s)
      recorder
        ..onTick(currentTrack: t, currentTimeSeconds: 1, isPlaying: true)
        ..onTick(currentTrack: t, currentTimeSeconds: 50, isPlaying: true);
      repo.flush();
      expect(repo.state.totalMs, 0);
    });
  });
}
