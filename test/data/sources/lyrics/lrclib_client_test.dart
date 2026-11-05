import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/sources/lyrics/lrclib_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  group('LRCLIB helpers', () {
    test('cleanTitle strips noise tails while keeping features', () {
      expect(cleanTitle('Flowers (Official Video)'), equals('Flowers'));
      expect(
        cleanTitle('Stay (feat. Justin Bieber) [Official Audio]'),
        equals('Stay (feat. Justin Bieber)'),
      );
      expect(
        cleanTitle('Song Title | BLESSD (VIDEO OFICIAL)'),
        equals('Song Title'),
      );
    });

    test('stripGroups removes all parentheses and bracket groups', () {
      expect(stripGroups('Stay (feat. Justin Bieber)'), equals('Stay'));
    });

    test('cleanArtist strips VEVO and Topic suffixes', () {
      expect(cleanArtist('AdeleVEVO'), equals('Adele'));
      expect(cleanArtist('Coldplay - Topic'), equals('Coldplay'));
      expect(cleanArtist('Artist - Official Channel'), equals('Artist'));
    });

    test('artistSim scores similarity correctly', () {
      expect(artistSim('Coldplay', 'Coldplay'), equals(2));
      expect(artistSim('Coldplay feat. BTS', 'Coldplay'), equals(2));
      expect(artistSim('David Bowie & Queen', 'Queen'), equals(1));
      expect(artistSim('Metallica', 'Dua Lipa'), equals(0));
    });

    test('titleLike handles fuzzy title matching', () {
      expect(titleLike('Flowers', 'Flowers (Official Video)'), isTrue);
      expect(titleLike('As It Was', 'As It Was'), isTrue);
      expect(titleLike('Something Completely Different', 'Flowers'), isFalse);
    });

    test('introOffMs computes lead-in auto offset', () {
      final lines = [
        const LyricLine(startMs: 10000, text: 'First line'),
        const LyricLine(startMs: 20000, text: 'Second line'),
        const LyricLine(startMs: 30000, text: 'Third line'),
        const LyricLine(startMs: 200000, text: 'Last line'),
      ];
      // selfEst = 200 + 12 = 212s
      // recDur = 212s (agrees with sheet)
      // video dur = 225s
      // g = min(225 - 212 - 5, 225 - 212) = min(8, 13) = 8.0s
      // rounded = 8.0s -> 8000ms
      final off = introOffMs(lines, 212, 225);
      expect(off, equals(8000));

      // Small delta < 2.5s is treated as noise -> 0
      final smallOff = introOffMs(lines, 212, 213);
      expect(smallOff, equals(0));
    });

    test('pickLrc selects closest duration candidate with synced lyrics', () {
      final pool = [
        const LrclibRecord(
          id: 1,
          trackName: 'Hello',
          artistName: 'Adele',
          duration: 180,
          syncedLyrics:
              '[00:05.00] Line 1\n[00:10.00] Line 2\n'
              '[00:15.00] Line 3\n[00:20.00] Line 4',
        ),
        const LrclibRecord(
          id: 2,
          trackName: 'Hello',
          artistName: 'Adele',
          duration: 295,
          syncedLyrics:
              '[00:05.00] Line A\n[00:10.00] Line B\n'
              '[00:15.00] Line C\n[00:20.00] Line D',
        ),
      ];

      final res = pickLrc(
        refTitle: 'Hello',
        pool: pool,
        artist: 'Adele',
        trackDurationSec: 290,
      );

      expect(res, isA<SyncedLyrics>());
      final synced = res! as SyncedLyrics;
      expect(synced.lines.first.text, equals('Line A'));
      expect(synced.source, equals('lrclib'));
    });
  });

  group('LrclibClient', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late LrclibClient client;

    setUp(() {
      dio = Dio(BaseOptions());
      dioAdapter = DioAdapter(dio: dio);
      client = LrclibClient(dio: dio);
    });

    test(
      'getLyrics performs parallel search and returns SyncedLyrics',
      () async {
        dioAdapter
          ..onGet(
            '${LrclibClient.baseUrl}/api/search',
            (server) => server.reply(200, <Map<String, dynamic>>[]),
            queryParameters: {'track_name': 'Shape of You'},
          )
          ..onGet(
            '${LrclibClient.baseUrl}/api/search',
            (server) => server.reply(200, <Map<String, dynamic>>[]),
            queryParameters: {'q': 'Ed Sheeran Shape of You'},
          )
          ..onGet(
            '${LrclibClient.baseUrl}/api/search',
            (server) => server.reply(200, [
              {
                'id': 1001,
                'name': 'Shape of You',
                'trackName': 'Shape of You',
                'artistName': 'Ed Sheeran',
                'duration': 233.0,
                'syncedLyrics':
                    "[00:10.00] The club isn't the best place\n"
                    '[00:14.00] So the bar is where I go\n'
                    '[00:18.00] Me and my friends at the table\n'
                    '[00:22.00] Doing fast and we talk slow',
              },
            ]),
            queryParameters: {
              'track_name': 'Shape of You',
              'artist_name': 'Ed Sheeran',
            },
          );

        final lyrics = await client.getLyrics(
          'Shape of You (Official Music Video)',
          'Ed Sheeran',
          durationSec: 235,
        );

        expect(lyrics, isA<SyncedLyrics>());
        final synced = lyrics! as SyncedLyrics;
        expect(synced.source, equals('lrclib'));
        expect(synced.lines.length, equals(4));
        expect(synced.lines.first.text, contains("The club isn't"));
        expect(synced.fingerprint, isNotEmpty);
      },
    );

    test(
      'getLyrics falls back to plain lyrics when synced is missing',
      () async {
        dioAdapter
          ..onGet(
            '${LrclibClient.baseUrl}/api/search',
            (server) => server.reply(200, <Map<String, dynamic>>[]),
            queryParameters: {'track_name': 'Rare Song'},
          )
          ..onGet(
            '${LrclibClient.baseUrl}/api/search',
            (server) => server.reply(200, <Map<String, dynamic>>[]),
            queryParameters: {'q': 'Indie Artist Rare Song'},
          )
          ..onGet(
            '${LrclibClient.baseUrl}/api/search',
            (server) => server.reply(200, [
              {
                'id': 2002,
                'name': 'Rare Song',
                'artistName': 'Indie Artist',
                'duration': 150.0,
                'plainLyrics':
                    'Only plain lyrics exist for this rare song.\n'
                    'Second line of rare song.',
              },
            ]),
            queryParameters: {
              'track_name': 'Rare Song',
              'artist_name': 'Indie Artist',
            },
          )
          ..onGet(
            '${LrclibClient.baseUrl}/api/get',
            (server) => server.reply(404, {'error': 'not found'}),
            queryParameters: {
              'track_name': 'Rare Song',
              'artist_name': 'Indie Artist',
            },
          );

        final lyrics = await client.getLyrics(
          'Rare Song',
          'Indie Artist',
          durationSec: 150,
        );

        expect(lyrics, isA<PlainLyrics>());
        final plain = lyrics! as PlainLyrics;
        expect(plain.source, equals('lrclib'));
        expect(plain.text, contains('Only plain lyrics exist'));
      },
    );
  });
}
