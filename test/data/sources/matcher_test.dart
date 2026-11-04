import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/search_results.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/matcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class MatcherMockAdapter implements HttpClientAdapter {
  MatcherMockAdapter(this.searchResults);

  final Map<String, dynamic> searchResults;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return Future.value(
      ResponseBody.fromString(
        '{}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  @override
  void close({bool force = false}) {}
}

class FakeInnertubeClient extends InnertubeClient {
  FakeInnertubeClient(this.mockTracks);

  final List<Track> mockTracks;

  @override
  Future<SearchResults> search(String query) async {
    return SearchResults(songs: mockTracks);
  }
}

void main() {
  group('Matcher pure-function normalisation tests', () {
    test('fold strips diacritics and lowercases', () {
      expect(fold('Café'), 'cafe');
      expect(fold('Mötley Crüe'), 'motley crue');
      expect(fold('Beyoncé'), 'beyonce');
      expect(fold('Sigur Rós'), 'sigur ros');
      expect(fold('Amélie'), 'amelie');
      expect(fold('Niño'), 'nino');
      expect(fold('ÁÉÍÓÚ'), 'aeiou');
    });

    test('cleanText removes feat, remastered, version, and brackets', () {
      expect(
        cleanText('Song (feat. X) [Remastered 2011] - Remastered'),
        'song',
      );
      expect(cleanText('Chandelier - Single Version'), 'chandelier');
      expect(
        cleanText('Bohemian Rhapsody - 2011 Remaster'),
        'bohemian rhapsody',
      );
      expect(cleanText('Hello (feat. John)'), 'hello');
      expect(cleanText('Hello (ft. John)'), 'hello');
      expect(cleanText('Starboy [Explicit]'), 'starboy');
      expect(cleanText('Album [Deluxe Edition]'), 'album');
      expect(cleanText('Canción (feat. Shakira)'), 'cancion');
      expect(cleanText('Track - Album Version'), 'track');
    });

    test('firstArtist isolates primary artist name', () {
      expect(firstArtist('Queen & David Bowie'), 'queen');
      expect(firstArtist('Artist 1, Artist 2, Artist 3'), 'artist 1');
      expect(firstArtist('Adele feat. John Legend'), 'adele');
      expect(firstArtist('Eminem ft. Rihanna'), 'eminem');
      expect(firstArtist('Marshmello x Bastille'), 'marshmello');
      expect(firstArtist('David Guetta with Sia'), 'david guetta');
      expect(firstArtist('Beyoncé; Jay-Z'), 'beyonce');
      expect(firstArtist('AC/DC'), 'ac');
    });

    test('matchKey combines first artist and clean title', () {
      expect(
        matchKey('Hello (feat. Someone)', 'Adele & Friend'),
        'adele hello',
      );
      expect(
        matchKey('Bohemian Rhapsody [Remastered]', 'Queen'),
        'queen bohemian rhapsody',
      );
    });

    test('matchScore scores exact matches higher than covers or live', () {
      const realTrack = Track(
        id: 'yt-1',
        streamId: '1',
        source: TrackSource.yt,
        title: 'Hello',
        duration: 295,
        artist: Artist(id: 'yt-adele', name: 'Adele', handle: 'Adele'),
      );

      const liveTrack = Track(
        id: 'yt-2',
        streamId: '2',
        source: TrackSource.yt,
        title: 'Hello (Live at the BBC)',
        duration: 350,
        artist: Artist(id: 'yt-adele', name: 'Adele', handle: 'Adele'),
      );

      const coverTrack = Track(
        id: 'yt-3',
        streamId: '3',
        source: TrackSource.yt,
        title: 'Hello',
        duration: 295,
        artist: Artist(
          id: 'yt-tribute',
          name: 'Tribute Band',
          handle: 'Tribute',
        ),
      );

      final realScore = matchScore(
        track: realTrack,
        wantTitle: 'Hello',
        wantArtist: 'Adele',
        wantDuration: 296,
      );

      final liveScore = matchScore(
        track: liveTrack,
        wantTitle: 'Hello',
        wantArtist: 'Adele',
        wantDuration: 296,
      );

      final coverScore = matchScore(
        track: coverTrack,
        wantTitle: 'Hello',
        wantArtist: 'Adele',
        wantDuration: 296,
      );

      // Real track: exact title (+3), artist (+1.5), duration diff 1s = 7.5
      expect(realScore, 7.5);

      // Live track has duration diff 54s (>30 -> -1.5), partial title match
      expect(liveScore, lessThan(realScore));

      // Cover track misses artist match
      expect(coverScore, lessThan(realScore));
    });
  });

  group('matchSingleTrack & InnertubeClient.match integration', () {
    test('matchSingleTrack selects best scored track', () async {
      const track1 = Track(
        id: 'yt-cover',
        streamId: 'cover',
        source: TrackSource.yt,
        title: 'Hello (Karaoke)',
        duration: 290,
        artist: Artist(id: 'yt-karaoke', name: 'Karaoke', handle: 'Karaoke'),
      );
      const track2 = Track(
        id: 'yt-real',
        streamId: 'real',
        source: TrackSource.yt,
        title: 'Hello',
        duration: 296,
        artist: Artist(id: 'yt-adele', name: 'Adele', handle: 'Adele'),
      );

      final fakeClient = FakeInnertubeClient([track1, track2]);

      final matched = await matchSingleTrack(
        fakeClient,
        const MatchQuery(
          title: 'Hello - Remastered',
          artist: 'Adele',
          duration: 296,
        ),
      );

      expect(matched, isNotNull);
      expect(matched!.id, 'yt-real');
    });

    test('InnertubeClient.match preserves batch order', () async {
      const track = Track(
        id: 'yt-1',
        streamId: '1',
        source: TrackSource.yt,
        title: 'Rolling in the Deep',
        duration: 228,
        artist: Artist(id: 'yt-adele', name: 'Adele', handle: 'Adele'),
      );

      final fakeClient = FakeInnertubeClient([track]);

      final results = await fakeClient.match([
        const MatchQuery(title: 'Rolling in the Deep', artist: 'Adele'),
        const MatchQuery(title: 'Rolling in the Deep', artist: 'Adele'),
      ]);

      expect(results.length, 2);
      expect(results[0]?.title, 'Rolling in the Deep');
      expect(results[1]?.title, 'Rolling in the Deep');
    });
  });
}
