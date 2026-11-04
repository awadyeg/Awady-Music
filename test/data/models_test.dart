import 'dart:convert';

import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/models/playlist_export.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/stream_info.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Artist models and hasArtistPage', () {
    test('hasArtistPage returns false for special fake IDs', () {
      expect(hasArtistPage(null), isFalse);
      expect(hasArtistPage(const Artist(id: '', name: 'Empty')), isFalse);
      expect(
        hasArtistPage(const Artist(id: 'yt-va', name: 'Various Artists')),
        isFalse,
      );
      expect(
        hasArtistPage(const Artist(id: 'yt-', name: 'Missing Channel')),
        isFalse,
      );
      expect(
        hasArtistPage(const Artist(id: 'yt-UC12345', name: 'Real Artist')),
        isTrue,
      );

      const artist = Artist(id: 'yt-UC12345', name: 'Adele');
      expect(artist.hasPage, isTrue);
    });

    test('Artist JSON round trip with desktop fields', () {
      final jsonMap = {
        'id': 'yt-UC12345',
        'streamId': 'UC12345',
        'handle': 'adele',
        'name': 'Adele',
        'bio': 'English singer-songwriter',
        'is_verified': true,
        'follower_count': 12000000,
        'track_count': 84,
        'profile_picture': {
          '150x150': 'https://example.com/adele_150.jpg',
          '480x480': 'https://example.com/adele_480.jpg',
        },
        'cover_photo': 'https://example.com/adele_cover.jpg',
      };

      final artist = Artist.fromJson(jsonMap);
      expect(artist.id, 'yt-UC12345');
      expect(artist.streamId, 'UC12345');
      expect(artist.name, 'Adele');
      expect(artist.isVerified, isTrue);
      expect(artist.followerCount, 12000000);
      expect(artist.profilePicture?.s480, 'https://example.com/adele_480.jpg');

      final serialized = artist.toJson();
      expect(serialized['id'], 'yt-UC12345');
      expect(serialized['name'], 'Adele');
    });
  });

  group('Track models and serialization', () {
    test('Track round trip with desktop user field', () {
      final jsonMap = {
        'id': 'yt-dQw4w9WgXcQ',
        'source': 'yt',
        'streamId': 'dQw4w9WgXcQ',
        'title': 'Never Gonna Give You Up',
        'duration': 213,
        'genre': 'Pop',
        'play_count': 1450000,
        'album': {'id': 'ytalb-123', 'name': 'Whenever You Need Somebody'},
        'artwork': {
          '150x150': 'https://example.com/art_150.jpg',
          '480x480': 'https://example.com/art_480.jpg',
        },
        'user': {
          'id': 'yt-UCuAXFkgsw1L7xaCfnd5JJOw',
          'name': 'Rick Astley',
          'handle': 'rickastley',
        },
      };

      final track = Track.fromJson(jsonMap);
      expect(track.id, 'yt-dQw4w9WgXcQ');
      expect(track.source, TrackSource.yt);
      expect(track.streamId, 'dQw4w9WgXcQ');
      expect(track.title, 'Never Gonna Give You Up');
      expect(track.duration, 213);
      expect(track.playCount, 1450000);
      expect(track.album?.name, 'Whenever You Need Somebody');
      expect(track.artist.name, 'Rick Astley');
      expect(track.isStreamable, isTrue);

      final outJson = track.toJson();
      final roundTrip = Track.fromJson(outJson);
      expect(roundTrip, equals(track));
    });
  });

  group('RemotePlaylist and LocalPlaylist', () {
    test('RemotePlaylist parses desktop playlist format', () {
      final jsonMap = {
        'id': 'ytpl-PL12345',
        'playlist_name': 'Today Top Hits',
        'is_album': false,
        'track_count': 50,
        'user': {'id': 'yt-curator', 'name': 'Spotify / YT Curators'},
      };

      final playlist = RemotePlaylist.fromJson(jsonMap);
      expect(playlist.id, 'ytpl-PL12345');
      expect(playlist.name, 'Today Top Hits');
      expect(playlist.isAlbum, isFalse);
      expect(playlist.trackCount, 50);
      expect(playlist.owner.name, 'Spotify / YT Curators');
    });

    test('LocalPlaylist round trip', () {
      final local = LocalPlaylist(
        id: 'local-test-123',
        name: 'Road Trip',
        createdAt: DateTime.utc(2026, 11, 4, 12),
        tracks: [
          const Track(
            id: 'yt-1',
            title: 'Song 1',
            artist: Artist(id: 'yt-a1', name: 'Artist 1'),
          ),
        ],
      );

      final jsonMap = local.toJson();
      final decoded = LocalPlaylist.fromJson(jsonMap);
      expect(decoded.name, 'Road Trip');
      expect(decoded.tracks.length, 1);
    });
  });

  group('Lyrics and StreamInfo', () {
    test('StreamInfo and Lyrics models instantiate', () {
      final streamInfo = StreamInfo(
        url: Uri.parse('https://googlevideo.com/videoplayback'),
        expiresAt: DateTime.utc(2026, 11, 4, 18),
        bitrate: 128000,
        mimeType: 'audio/mp4',
      );
      expect(streamInfo.bitrate, 128000);

      const lyrics = SyncedLyrics(
        lines: [LyricLine(startMs: 1200, text: 'Hello')],
        source: 'lrclib',
        fingerprint: 'fp-123',
      );
      expect(lyrics.lines.first.text, 'Hello');
    });
  });

  group('Desktop .freebify.json import/export parsing', () {
    test('parses sample desktop .freebify.json export correctly', () {
      const sampleExportJson = '''
      {
        "app": "freebify",
        "type": "playlist",
        "version": 1,
        "name": "Gym Workout",
        "exportedAt": "2026-11-04T12:00:00.000Z",
        "tracks": [
          {
            "title": "Stronger",
            "artist": "Kanye West",
            "duration": 312,
            "source": "yt",
            "streamId": "PsO6ZnUZI0g",
            "album": "Graduation"
          },
          {
            "title": "Lose Yourself",
            "artist": "Eminem",
            "duration": 326,
            "source": "yt",
            "streamId": "_Yhyp-_hX2s",
            "album": "8 Mile"
          }
        ]
      }
      ''';

      final decoded = json.decode(sampleExportJson) as Map<String, dynamic>;
      final export = PlaylistExport.fromJson(decoded);

      expect(export.app, 'freebify');
      expect(export.type, 'playlist');
      expect(export.version, 1);
      expect(export.name, 'Gym Workout');
      expect(export.tracks.length, 2);
      expect(export.tracks[0].title, 'Stronger');
      expect(export.tracks[0].artist, 'Kanye West');
      expect(export.tracks[0].duration, 312);
      expect(export.tracks[0].streamId, 'PsO6ZnUZI0g');
      expect(export.tracks[0].album, 'Graduation');
      expect(export.tracks[1].title, 'Lose Yourself');
    });
  });
}
