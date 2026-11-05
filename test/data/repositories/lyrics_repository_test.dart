import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/lyrics_repository.dart';
import 'package:awady_music/data/sources/lyrics/lrclib_client.dart';
import 'package:awady_music/data/sources/lyrics/musixmatch_client.dart';
import 'package:awady_music/data/sources/lyrics/ytm_lyrics_client.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeYtmLyricsClient extends YtmLyricsClient {
  _FakeYtmLyricsClient() : super();

  Lyrics? lyricsToReturn;
  int callCount = 0;

  @override
  Future<Lyrics?> timed(String videoId) async {
    callCount++;
    return lyricsToReturn;
  }
}

class _FakeMusixmatchClient extends MusixmatchClient {
  _FakeMusixmatchClient();

  SyncedLyrics? lyricsToReturn;
  int callCount = 0;

  @override
  Future<SyncedLyrics?> getLyrics(
    String title,
    String artist, {
    int? expectedDurationSec,
  }) async {
    callCount++;
    return lyricsToReturn;
  }
}

class _FakeLrclibClient extends LrclibClient {
  _FakeLrclibClient();

  Lyrics? lyricsToReturn;
  int callCount = 0;

  @override
  Future<Lyrics?> getLyrics(
    String rawTitle,
    String rawArtist, {
    int? durationSec,
  }) async {
    callCount++;
    return lyricsToReturn;
  }
}

void main() {
  late AppDatabase db;
  late _FakeYtmLyricsClient fakeYtm;
  late _FakeMusixmatchClient fakeMxm;
  late _FakeLrclibClient fakeLrclib;
  late LyricsRepository repo;

  const testTrack = Track(
    id: 'track-123',
    title: 'Test Song',
    artist: Artist(id: 'artist-1', name: 'Test Artist'),
    duration: 200,
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    fakeYtm = _FakeYtmLyricsClient();
    fakeMxm = _FakeMusixmatchClient();
    fakeLrclib = _FakeLrclibClient();
    repo = LyricsRepository(
      ytmLyricsClient: fakeYtm,
      musixmatchClient: fakeMxm,
      lrclibClient: fakeLrclib,
      cacheDao: db.cacheDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('LyricsRepository fallback ordering', () {
    test('prefers YTM timed lyrics when available', () async {
      fakeYtm.lyricsToReturn = const SyncedLyrics(
        lines: [LyricLine(startMs: 1000, text: 'YTM Line 1')],
        source: 'ytm',
        fingerprint: 'fp-ytm',
      );
      fakeMxm.lyricsToReturn = const SyncedLyrics(
        lines: [LyricLine(startMs: 1000, text: 'MXM Line 1')],
        source: 'musixmatch',
        fingerprint: 'fp-mxm',
      );
      fakeLrclib.lyricsToReturn = const SyncedLyrics(
        lines: [LyricLine(startMs: 1000, text: 'LRCLIB Line 1')],
        source: 'lrclib',
        fingerprint: 'fp-lrclib',
      );

      final res = await repo.get(testTrack);
      expect(res, isA<SyncedLyrics>());
      final synced = res as SyncedLyrics;
      expect(synced.source, equals('ytm'));
      expect(fakeYtm.callCount, equals(1));
      expect(fakeMxm.callCount, equals(0));
      expect(fakeLrclib.callCount, equals(0));
    });

    test('falls back to Musixmatch when YTM timed is unavailable', () async {
      fakeYtm.lyricsToReturn = null;
      fakeMxm.lyricsToReturn = const SyncedLyrics(
        lines: [LyricLine(startMs: 2000, text: 'MXM Line 1')],
        source: 'musixmatch',
        fingerprint: 'fp-mxm',
      );
      fakeLrclib.lyricsToReturn = const SyncedLyrics(
        lines: [LyricLine(startMs: 2000, text: 'LRCLIB Line 1')],
        source: 'lrclib',
        fingerprint: 'fp-lrclib',
      );

      final res = await repo.get(testTrack);
      expect(res, isA<SyncedLyrics>());
      final synced = res as SyncedLyrics;
      expect(synced.source, equals('musixmatch'));
      expect(fakeYtm.callCount, equals(1));
      expect(fakeMxm.callCount, equals(1));
      expect(fakeLrclib.callCount, equals(0));
    });

    test(
      'falls back to LRCLIB when YTM and Musixmatch are unavailable',
      () async {
        fakeYtm.lyricsToReturn = null;
        fakeMxm.lyricsToReturn = null;
        fakeLrclib.lyricsToReturn = const SyncedLyrics(
          lines: [LyricLine(startMs: 3000, text: 'LRCLIB Line 1')],
          source: 'lrclib',
          fingerprint: 'fp-lrclib',
          autoOffsetMs: 1500,
        );

        final res = await repo.get(testTrack);
        expect(res, isA<SyncedLyrics>());
        final synced = res as SyncedLyrics;
        expect(synced.source, equals('lrclib'));
        expect(synced.autoOffsetMs, equals(1500));
        expect(fakeYtm.callCount, equals(1));
        expect(fakeMxm.callCount, equals(1));
        expect(fakeLrclib.callCount, equals(1));
      },
    );

    test('falls back to PlainLyrics when no timed source available', () async {
      fakeYtm.lyricsToReturn = const PlainLyrics(
        text: 'Plain text from YTM',
        source: 'ytm',
      );
      fakeMxm.lyricsToReturn = null;
      fakeLrclib.lyricsToReturn = null;

      final res = await repo.get(testTrack);
      expect(res, isA<PlainLyrics>());
      final plain = res as PlainLyrics;
      expect(plain.text, equals('Plain text from YTM'));
    });

    test('returns NoLyrics when all sources return nothing', () async {
      fakeYtm.lyricsToReturn = null;
      fakeMxm.lyricsToReturn = null;
      fakeLrclib.lyricsToReturn = null;

      final res = await repo.get(testTrack);
      expect(res, isA<NoLyrics>());
    });
  });

  group('LyricsRepository offsets and pinning', () {
    test('persists autoOffsetMs to SQLite and returns it', () async {
      fakeYtm.lyricsToReturn = null;
      fakeMxm.lyricsToReturn = null;
      fakeLrclib.lyricsToReturn = const SyncedLyrics(
        lines: [LyricLine(startMs: 1000, text: 'Line')],
        source: 'lrclib',
        fingerprint: 'sheet-fp-1',
        autoOffsetMs: 4000,
      );

      final res = await repo.get(testTrack);
      expect(res, isA<SyncedLyrics>());
      final synced = res as SyncedLyrics;
      expect(synced.autoOffsetMs, equals(4000));

      final persistedOffset = await repo.getOffset(
        trackId: testTrack.id,
        fingerprint: 'sheet-fp-1',
      );
      expect(persistedOffset, equals(4000));
    });

    test('pinOffset overrides auto offset and persists manual flag', () async {
      fakeYtm.lyricsToReturn = const SyncedLyrics(
        lines: [LyricLine(startMs: 1000, text: 'Line')],
        source: 'ytm',
        fingerprint: 'sheet-fp-pin',
      );

      // Initial resolve with 0 offset
      final initial = await repo.get(testTrack);
      expect((initial as SyncedLyrics).autoOffsetMs, equals(0));

      // Pin manual offset of +3500ms
      await repo.pinOffset(
        trackId: testTrack.id,
        fingerprint: 'sheet-fp-pin',
        offsetMs: 3500,
      );

      // Subsequent get returns the pinned offset
      final afterPin = await repo.get(testTrack, forceFresh: true);
      expect((afterPin as SyncedLyrics).autoOffsetMs, equals(3500));

      // DB row has manual = true
      final row = await db.cacheDao.getLyricOffset(
        LyricsRepository.offsetKey(testTrack.id, 'sheet-fp-pin'),
      );
      expect(row, isNotNull);
      expect(row!.ms, equals(3500));
      expect(row.manual, isTrue);
    });

    test('fingerprints isolate offsets between different sheets', () async {
      await repo.pinOffset(
        trackId: testTrack.id,
        fingerprint: 'sheet-A',
        offsetMs: 2000,
      );

      final offA = await repo.getOffset(
        trackId: testTrack.id,
        fingerprint: 'sheet-A',
      );
      expect(offA, equals(2000));

      final offB = await repo.getOffset(
        trackId: testTrack.id,
        fingerprint: 'sheet-B',
      );
      expect(offB, isNull);
    });
  });
}
