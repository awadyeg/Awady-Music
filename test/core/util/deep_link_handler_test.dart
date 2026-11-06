import 'package:awady_music/core/util/deep_link_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeGoRouter extends Fake implements GoRouter {
  final List<String> pushedRoutes = [];

  @override
  Future<T?> push<T extends Object?>(String location, {Object? extra}) async {
    pushedRoutes.add(location);
    return null;
  }
}

void main() {
  late _FakeGoRouter fakeRouter;

  setUp(() {
    fakeRouter = _FakeGoRouter();
  });

  group('DeepLinkHandler.handleUri', () {
    test('routes awadymusic://playlist/123 to /playlist/123', () {
      DeepLinkHandler.handleUri(
        Uri.parse('awadymusic://playlist/123'),
        fakeRouter,
      );
      expect(fakeRouter.pushedRoutes, ['/playlist/123']);
    });

    test('routes awadymusic://artist/456 to /artist/456', () {
      DeepLinkHandler.handleUri(
        Uri.parse('awadymusic://artist/456'),
        fakeRouter,
      );
      expect(fakeRouter.pushedRoutes, ['/artist/456']);
    });

    test('routes awadymusic://import?url=... to /import?url=...', () {
      DeepLinkHandler.handleUri(
        Uri.parse(
          'awadymusic://import?url=https%3A%2F%2Fopen.spotify.com%2Fplaylist%2F123',
        ),
        fakeRouter,
      );
      expect(fakeRouter.pushedRoutes.length, 1);
      expect(fakeRouter.pushedRoutes.first.startsWith('/import?url='), isTrue);
    });

    test('routes http spotify link to /import?url=...', () {
      DeepLinkHandler.handleUri(
        Uri.parse('https://open.spotify.com/playlist/12345'),
        fakeRouter,
      );
      expect(fakeRouter.pushedRoutes.length, 1);
      expect(fakeRouter.pushedRoutes.first.contains('spotify.com'), isTrue);
    });

    test('routes http youtube music link to /import?url=...', () {
      DeepLinkHandler.handleUri(
        Uri.parse('https://music.youtube.com/playlist?list=PL123'),
        fakeRouter,
      );
      expect(fakeRouter.pushedRoutes.length, 1);
      expect(
        fakeRouter.pushedRoutes.first.contains('music.youtube.com'),
        isTrue,
      );
    });
  });
}
