import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/models/track_validator.dart';
import 'package:flutter_test/flutter_test.dart';

Track _mkTrack(
  String id, {
  Artwork? artwork,
  String? streamId,
  TrackSource? source,
}) {
  return Track(
    id: id,
    title: 'Song $id',
    duration: 200,
    streamId: streamId,
    source: source ?? TrackSource.audius,
    artwork: artwork,
    artist: const Artist(id: 'u1', handle: 'h', name: 'Artist'),
  );
}

void main() {
  group('isValidTrack', () {
    test('rejects non-objects', () {
      for (final v in [null, 5, 'x', true, <dynamic>[]]) {
        expect(isValidTrack(v), isFalse);
      }
    });

    test('rejects tracks missing title', () {
      final t = {
        'id': 'a',
        'duration': 200,
        'user': {'id': 'u1', 'name': 'Artist'},
      };
      expect(isValidTrack(t), isFalse);
    });

    test('rejects tracks missing a valid user', () {
      final noUser = {'id': 'a', 'title': 'Song a', 'duration': 200};
      expect(isValidTrack(noUser), isFalse);

      final incompleteUser1 = {
        'id': 'a',
        'title': 'Song a',
        'user': {'id': 'u1'},
      };
      expect(isValidTrack(incompleteUser1), isFalse);

      final incompleteUser2 = {
        'id': 'a',
        'title': 'Song a',
        'user': {'name': 'Artist'},
      };
      expect(isValidTrack(incompleteUser2), isFalse);
    });

    test('rejects bad durations', () {
      final base = {
        'id': 'a',
        'title': 'Song a',
        'user': {'id': 'u1', 'name': 'Artist'},
      };

      expect(isValidTrack({...base, 'duration': double.nan}), isFalse);
      expect(isValidTrack({...base, 'duration': double.infinity}), isFalse);
      expect(isValidTrack({...base, 'duration': '200'}), isFalse);
    });

    test('accepts a valid track', () {
      final t = {
        'id': 'a',
        'title': 'Song a',
        'duration': 200,
        'user': {'id': 'u1', 'name': 'Artist'},
      };
      expect(isValidTrack(t), isTrue);

      // duration is optional in legacy persisted blobs
      final tNullDuration = {
        'id': 'a',
        'title': 'Song a',
        'duration': null,
        'user': {'id': 'u1', 'name': 'Artist'},
      };
      expect(isValidTrack(tNullDuration), isTrue);
    });
  });

  group('repairTrack', () {
    test('backfills streamId and source for yt-* ids', () {
      final out = repairTrack(_mkTrack('yt-abc123'));
      expect(out.streamId, 'abc123');
      expect(out.source, TrackSource.yt);
    });

    test('strips signed params from ytimg artwork URLs', () {
      final out = repairTrack(
        _mkTrack(
          'yt-abc123',
          artwork: const Artwork(
            s480: 'https://i.ytimg.com/vi/x/hqdefault.jpg?sqp=123&rs=4',
          ),
        ),
      );
      expect(out.artwork?.s480, 'https://i.ytimg.com/vi/x/hqdefault.jpg');
    });

    test('adds the i.ytimg fallback for yt tracks without one', () {
      final out = repairTrack(
        _mkTrack(
          'yt-abc123',
          artwork: const Artwork(s480: 'https://cdn.example.com/a.jpg'),
        ),
      );
      expect(
        out.artwork?.fallback,
        'https://i.ytimg.com/vi/abc123/hqdefault.jpg',
      );
    });

    test('keeps an existing fallback', () {
      final out = repairTrack(
        _mkTrack(
          'yt-abc123',
          artwork: const Artwork(
            fallback: 'https://i.ytimg.com/vi/zzz/hqdefault.jpg',
          ),
        ),
      );
      expect(out.artwork?.fallback, 'https://i.ytimg.com/vi/zzz/hqdefault.jpg');
    });

    test('leaves non-yt tracks alone', () {
      final t = _mkTrack('aud-1');
      final out = repairTrack(t);
      expect(out.streamId, isNull);
      expect(out.source, TrackSource.audius);
      expect(out.artwork, isNull);
    });
  });

  group('slimTrack', () {
    test('strips heavy fields', () {
      const t = Track(
        id: 'a',
        title: 'Song a',
        artist: Artist(
          id: 'u1',
          name: 'Artist',
          bio: 'Long bio that should be removed',
          coverPhoto: 'https://example.com/cover.jpg',
        ),
      );

      final out = slimTrack(t);
      expect(out.artist.bio, isNull);
      expect(out.artist.coverPhoto, isNull);
      expect(out.id, 'a');
      expect(out.title, 'Song a');
      expect(out.artist.name, 'Artist');
    });
  });

  group('sanitizeTrackList', () {
    test('filters invalid entries', () {
      final out = sanitizeTrackList([
        _mkTrack('a'),
        {'bad': 1},
        _mkTrack('b'),
        null,
      ], 10);
      expect(out.map((t) => t.id).toList(), ['a', 'b']);
    });

    test('caps the list at the cap argument', () {
      final out = sanitizeTrackList([
        _mkTrack('a'),
        _mkTrack('b'),
        _mkTrack('c'),
      ], 2);
      expect(out.length, 2);
      expect(out.map((t) => t.id).toList(), ['a', 'b']);
    });

    test('returns an empty array for non-arrays', () {
      for (final v in [null, 5, 'x', <dynamic, dynamic>{}]) {
        expect(sanitizeTrackList(v, 10), isEmpty);
      }
    });
  });
}
