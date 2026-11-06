import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_repository.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockInnertubeClient extends Mock implements InnertubeClient;

class MockAudiusClient extends Mock implements AudiusClient;

void main() {
  group('AiMixPlaylist & aiMixesFromLikes tests', () {
    late MockInnertubeClient mockInnertube;
    late MockAudiusClient mockAudius;
    late CatalogRepository repo;

    setUp(() {
      mockInnertube = MockInnertubeClient();
      mockAudius = MockAudiusClient();
      repo = CatalogRepositoryImpl(
        innertubeClient: mockInnertube,
        audiusClient: mockAudius,
      );
    });

    test('returns empty when no liked tracks are provided', () async {
      final mixes = await repo.aiMixesFromLikes(const []);
      expect(mixes, isEmpty);
    });

    test(
      'creates Overall Mix and category mixes with suggestions in middle',
      () async {
        const t1 = Track(
          id: 'yt-arabic_1',
          streamId: 'vid_arabic_1',
          title: 'أنت عمري',
          artist: Artist(id: 'a_kalthoum', name: 'أم كلثوم'),
          duration: 300,
        );
        const t2 = Track(
          id: 'yt-arabic_2',
          streamId: 'vid_arabic_2',
          title: 'سيرة الحب',
          artist: Artist(id: 'a_kalthoum', name: 'أم كلثوم'),
          duration: 290,
        );
        const t3 = Track(
          id: 'yt-pop_1',
          streamId: 'vid_pop_1',
          title: 'Skyfall',
          artist: Artist(id: 'a_adele', name: 'Adele'),
          duration: 286,
        );
        const t4 = Track(
          id: 'yt-pop_2',
          streamId: 'vid_pop_2',
          title: 'Rolling in the Deep',
          artist: Artist(id: 'a_adele', name: 'Adele'),
          duration: 228,
        );

        when(() => mockInnertube.upNext(any(), limit: any(named: 'limit')))
            .thenAnswer(
              (_) async => const [
                Track(
                  id: 't_suggested_1',
                  title: 'Suggested Track',
                  artist: Artist(id: 'a_sugg', name: 'Suggested Artist'),
                  duration: 200,
                ),
              ],
            );

        final mixes = await repo.aiMixesFromLikes([t1, t2, t3, t4]);

        expect(mixes, isNotEmpty);
        final overall = mixes.first;
        expect(overall.badge, 'Overall Mix');
        expect(overall.title, 'All Likes AI Mix');
        expect(overall.tracks, isNotEmpty);
        expect(overall.suggestedTrackIds, contains('t_suggested_1'));

        // Verify suggested track is placed in the middle
        final firstTrackId = overall.tracks.first.id;
        final lastTrackId = overall.tracks.last.id;
        expect(firstTrackId, equals('yt-arabic_1'));
        expect(lastTrackId, equals('yt-pop_2'));
        expect(overall.tracks[2].id, equals('t_suggested_1'));

        // Check category mix
        expect(mixes.length, greaterThan(1));
        final mix1 = mixes[1];
        expect(mix1.badge, 'Mix 1');
      },
    );
  });
}
