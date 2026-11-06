import 'package:awady_music/data/sources/importer/playlist_file_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaylistFileParser - csvRows', () {
    test('parses simple unquoted rows', () {
      const csv = 'Track,Artist\nSong 1,Artist 1\nSong 2,Artist 2';
      final rows = PlaylistFileParser.csvRows(csv);
      expect(rows.length, 3);
      expect(rows[0], ['Track', 'Artist']);
      expect(rows[1], ['Song 1', 'Artist 1']);
      expect(rows[2], ['Song 2', 'Artist 2']);
    });

    test('handles commas inside quotes', () {
      const csv = '"Song, A","Artist, The"\n"Another, Song","Artist B"';
      final rows = PlaylistFileParser.csvRows(csv);
      expect(rows.length, 2);
      expect(rows[0], ['Song, A', 'Artist, The']);
      expect(rows[1], ['Another, Song', 'Artist B']);
    });

    test('handles escaped double quotes', () {
      const csv = '"Song with ""quotes""",Artist\nSimple,B';
      final rows = PlaylistFileParser.csvRows(csv);
      expect(rows.length, 2);
      expect(rows[0], ['Song with "quotes"', 'Artist']);
      expect(rows[1], ['Simple', 'B']);
    });

    test('handles CRLF line endings and empty lines', () {
      const csv = 'Track,Artist\r\nSong 1,Artist 1\r\n\r\nSong 2,Artist 2\r\n';
      final rows = PlaylistFileParser.csvRows(csv);
      expect(rows.length, 3);
      expect(rows[1], ['Song 1', 'Artist 1']);
      expect(rows[2], ['Song 2', 'Artist 2']);
    });
  });

  group('PlaylistFileParser - findCols', () {
    test('matches Spotify headers', () {
      final header = ['Track Name', 'Artist Name(s)', 'Album', 'Duration'];
      final (titleIndex, artistIndex) = PlaylistFileParser.findCols(header);
      expect(titleIndex, 0);
      expect(artistIndex, 1);
    });

    test('matches loose title and artist headers', () {
      final header = ['Index', 'Song Name', 'Album', 'Featured Artist'];
      final (titleIndex, artistIndex) = PlaylistFileParser.findCols(header);
      expect(titleIndex, 1);
      expect(artistIndex, 3);
    });

    test('falls back to 0 and 1 if unknown', () {
      final header = ['Foo', 'Bar'];
      final (titleIndex, artistIndex) = PlaylistFileParser.findCols(header);
      expect(titleIndex, 0);
      expect(artistIndex, 1);
    });
  });

  group('PlaylistFileParser - parseCsv', () {
    test('parses CSV text into ParsedPlaylistFile', () {
      const csv = '''

"Track Name","Artist Name(s)"
"Birds of a Feather","Billie Eilish"
"Espresso","Sabrina Carpenter"''';

      final result = PlaylistFileParser.parseCsv(
        csv,
        defaultName: 'Summer Hits',
      );
      expect(result.name, 'Summer Hits');
      expect(result.entries.length, 2);
      expect(result.entries[0].title, 'Birds of a Feather');
      expect(result.entries[0].artist, 'Billie Eilish');
      expect(result.entries[1].title, 'Espresso');
      expect(result.entries[1].artist, 'Sabrina Carpenter');
    });

    test('throws FormatException on empty or header-only CSV', () {
      expect(
        () => PlaylistFileParser.parseCsv('Track,Artist'),
        throwsFormatException,
      );
      expect(() => PlaylistFileParser.parseCsv(''), throwsFormatException);
    });
  });

  group('PlaylistFileParser - parseJson', () {
    test('parses valid freebify playlist JSON', () {
      const json = '''

{
        "app": "freebify",
        "type": "playlist",
        "name": "My Exported Playlist",
        "tracks": [
          {"title": "Track 1", "artist": "Artist 1", "duration": 180},
          {"title": "Track 2", "user": {"name": "Artist 2"}, "duration": 210}
        ]
      }''';

      final result = PlaylistFileParser.parseJson(json);
      expect(result.name, 'My Exported Playlist');
      expect(result.entries.length, 2);
      expect(result.entries[0].title, 'Track 1');
      expect(result.entries[0].artist, 'Artist 1');
      expect(result.entries[0].duration, 180);
      expect(result.entries[1].title, 'Track 2');
      expect(result.entries[1].artist, 'Artist 2');
      expect(result.entries[1].duration, 210);
    });

    test('parses awadymusic playlist JSON and uses fallback name', () {
      const json = '''

{
        "app": "awadymusic",
        "type": "playlist",
        "tracks": [
          {"title": "Track 1", "artist": "Artist 1"}
        ]
      }''';

      final result = PlaylistFileParser.parseJson(
        json,
        defaultName: 'Fallback Name',
      );
      expect(result.name, 'Fallback Name');
      expect(result.entries.length, 1);
    });

    test('throws on invalid app or type', () {
      const badApp = '{"app": "other", "type": "playlist", "tracks": []}';
      expect(() => PlaylistFileParser.parseJson(badApp), throwsFormatException);

      const badType = '{"app": "freebify", "type": "album", "tracks": []}';
      expect(
        () => PlaylistFileParser.parseJson(badType),
        throwsFormatException,
      );
    });

    test('parses Spotify GDPR YourLibrary.json into Liked Songs', () {
      const json = '''
{
  "tracks": [
    {"artist": "Amr Diab", "album": "Tamally Maak", "track": "Tamally Maak", "uri": "spotify:track:123"},
    {"artist": "Fairuz", "album": "Kifak Inta", "track": "Kifak Inta", "uri": "spotify:track:456"}
  ]
}''';
      final result = PlaylistFileParser.parseJson(json);
      expect(result.name, 'Liked Songs');
      expect(result.entries.length, 2);
      expect(result.entries[0].title, 'Tamally Maak');
      expect(result.entries[0].artist, 'Amr Diab');
    });

    test('parses Exportify CSV with Duration (ms) into seconds', () {
      const csv = '''
"Track Name","Artist Name(s)","Duration (ms)"
"Tamally Maak","Amr Diab","245000"''';
      final result = PlaylistFileParser.parseCsv(
        csv,
        defaultName: 'Liked_Songs',
      );
      expect(result.entries.length, 1);
      expect(result.entries.first.duration, 245);
    });
  });
}
