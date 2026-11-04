import 'dart:convert';

import 'package:awady_music/data/models/stream_info.dart';
import 'package:awady_music/data/sources/http.dart';
import 'package:awady_music/data/sources/ytstream/explode_resolver.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_impl.dart';
import 'package:awady_music/data/sources/ytstream/visionos_resolver.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class MockStreamAdapter implements HttpClientAdapter {
  MockStreamAdapter({
    this.homepageHtml,
    this.playerResponse,
    this.probeStatusCode = 206,
  });

  String? homepageHtml;
  Map<String, dynamic>? playerResponse;
  int probeStatusCode;
  int playerCallCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final url = options.uri.toString();

    if (url.contains('youtube.com/') && !url.contains('youtubei')) {
      return Future.value(
        ResponseBody.fromString(
          homepageHtml ?? '<html>"STS":19750,"VISITOR_DATA":"V_DATA"</html>',
          200,
          headers: {
            Headers.contentTypeHeader: ['text/html'],
          },
        ),
      );
    }

    if (url.contains('youtubei/v1/player')) {
      playerCallCount++;
      final payload =
          playerResponse ??
          {
            'playabilityStatus': {'status': 'OK'},
            'streamingData': {
              'adaptiveFormats': [
                {
                  'mimeType': 'audio/mp4; codecs="mp4a.40.2"',
                  'url': 'https://rr1---sn-fake.googlevideo.com/videoplayback?expire=1799999999&id=1',
                  'bitrate': 128000,
                  'averageBitrate': 128000,
                },
              ],
            },
            'playerConfig': {
              'audioConfig': {'loudnessDb': -2.5},
            },
          };

      return Future.value(
        ResponseBody.fromString(
          jsonEncode(payload),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );
    }

    if (url.contains('googlevideo.com')) {
      return Future.value(
        ResponseBody.fromString(
          '',
          probeStatusCode,
          headers: {
            Headers.contentTypeHeader: ['audio/mp4'],
          },
        ),
      );
    }

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

class FakeVisionOsResolver extends VisionOsResolver {
  FakeVisionOsResolver({this.returnInfo, this.shouldFail = false});

  final StreamInfo? returnInfo;
  final bool shouldFail;
  int callCount = 0;

  @override
  Future<StreamInfo?> resolve(
    Dio dio,
    String videoId, {
    bool isIos = false,
  }) async {
    callCount++;
    if (shouldFail) return null;
    return returnInfo ??
        StreamInfo(
          url: Uri.parse('https://googlevideo.com/stream_$videoId'),
          expiresAt: DateTime.now().add(const Duration(hours: 4)),
          bitrate: 128000,
        );
  }
}

class FakeExplodeResolver extends YoutubeExplodeResolver {
  FakeExplodeResolver({this.returnInfo, this.shouldFail = false});

  final StreamInfo? returnInfo;
  final bool shouldFail;
  int callCount = 0;

  @override
  Future<StreamInfo?> resolve(
    String videoId, {
    bool isIos = false,
    dynamic ytOverride,
  }) async {
    callCount++;
    if (shouldFail) return null;
    return returnInfo ??
        StreamInfo(
          url: Uri.parse('https://explode.stream/audio_$videoId'),
          expiresAt: DateTime.now().add(const Duration(hours: 4)),
          bitrate: 160000,
        );
  }
}

void main() {
  group('VisionOsResolver tests', () {
    test(
      'resolves stream URL with STS, visitorData, and 1-byte probe',
      () async {
        final adapter = MockStreamAdapter();
        final dio = createDio()..httpClientAdapter = adapter;
        final resolver = VisionOsResolver();

        final info = await resolver.resolve(dio, 'test_vid');
        expect(info, isNotNull);
        expect(info!.url.host, contains('googlevideo.com'));
        expect(info.bitrate, 128000);
        expect(info.loudnessDb, -2.5);
        expect(adapter.playerCallCount, 1);
      },
    );

    test('retries on LOGIN_REQUIRED with refreshed credentials', () async {
      final adapter = MockStreamAdapter(
        playerResponse: {
          'playabilityStatus': {'status': 'LOGIN_REQUIRED'},
        },
      );
      final dio = createDio()..httpClientAdapter = adapter;
      final resolver = VisionOsResolver();

      final info = await resolver.resolve(dio, 'test_vid');
      expect(info, isNull);
      expect(adapter.playerCallCount, 2);
    });

    test('rejects untrusted hostnames or probe failures', () async {
      final adapter = MockStreamAdapter(probeStatusCode: 403);
      final dio = createDio()..httpClientAdapter = adapter;
      final resolver = VisionOsResolver();

      final info = await resolver.resolve(dio, 'test_vid');
      expect(info, isNull);
    });
  });

  group('StreamResolverImpl chain & caching tests', () {
    test(
      'returns VisionOS stream when available without invoking Explode',
      () async {
        final fakeVision = FakeVisionOsResolver();
        final fakeExplode = FakeExplodeResolver();

        final resolver = StreamResolverImpl(
          visionOsResolver: fakeVision,
          explodeResolver: fakeExplode,
        );

        final info = await resolver.resolve('yt-dQw4w9WgXcQ');
        expect(info.url.toString(), contains('googlevideo.com'));
        expect(fakeVision.callCount, 1);
        expect(fakeExplode.callCount, 0);
      },
    );

    test('falls back to Explode when VisionOS fails', () async {
      final fakeVision = FakeVisionOsResolver(shouldFail: true);
      final fakeExplode = FakeExplodeResolver();

      final resolver = StreamResolverImpl(
        visionOsResolver: fakeVision,
        explodeResolver: fakeExplode,
      );

      final info = await resolver.resolve('dQw4w9WgXcQ');
      expect(info.url.toString(), contains('explode.stream'));
      expect(fakeVision.callCount, 1);
      expect(fakeExplode.callCount, 1);
    });

    test(
      'throws StreamUnavailableException when both resolvers fail',
      () async {
        final fakeVision = FakeVisionOsResolver(shouldFail: true);
        final fakeExplode = FakeExplodeResolver(shouldFail: true);

        final resolver = StreamResolverImpl(
          visionOsResolver: fakeVision,
          explodeResolver: fakeExplode,
        );

        expect(
          () => resolver.resolve('dead_vid'),
          throwsA(isA<StreamUnavailableException>()),
        );
      },
    );

    test('caches stream in memory and dedupes in-flight requests', () async {
      final fakeVision = FakeVisionOsResolver();
      final resolver = StreamResolverImpl(
        visionOsResolver: fakeVision,
        explodeResolver: FakeExplodeResolver(),
      );

      // Inflight deduplication: 2 concurrent calls
      final results = await Future.wait([
        resolver.resolve('vid_123'),
        resolver.resolve('vid_123'),
      ]);

      expect(results[0].url, results[1].url);
      expect(fakeVision.callCount, 1);

      // Second call uses memory cache
      final cached = await resolver.resolve('vid_123');
      expect(cached.url, results[0].url);
      expect(fakeVision.callCount, 1);

      // Invalidation clears cache
      resolver.invalidate('vid_123');
      await resolver.resolve('vid_123');
      expect(fakeVision.callCount, 2);
    });
  });
}
