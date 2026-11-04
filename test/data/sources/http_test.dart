import 'dart:convert';
import 'dart:typed_data';

import 'package:awady_music/data/sources/http.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class SequenceAdapter implements HttpClientAdapter {
  SequenceAdapter(this.handlers);

  final List<ResponseBody Function(RequestOptions options)> handlers;
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (callCount < handlers.length) {
      final handler = handlers[callCount];
      callCount++;
      return handler(options);
    }
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      error: 'No more responses mocked',
    );
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(int statusCode, Object? body) {
  final bytes = utf8.encode(jsonEncode(body));
  return ResponseBody.fromBytes(
    bytes,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  group('HTTP core and Dio factory', () {
    test('creates Dio with default timeouts', () {
      final dio = createDio();
      expect(dio.options.connectTimeout, const Duration(seconds: 8));
      expect(dio.options.receiveTimeout, const Duration(seconds: 15));
      expect(dio.interceptors.any((i) => i is HttpLoggingInterceptor), isTrue);
      expect(dio.interceptors.any((i) => i is RetryInterceptor), isTrue);
    });

    test('custom timeouts and options are preserved', () {
      final custom = BaseOptions(
        baseUrl: 'https://example.com',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
      );
      final dio = createDio(options: custom);
      expect(dio.options.baseUrl, 'https://example.com');
      expect(dio.options.connectTimeout, const Duration(seconds: 5));
      expect(dio.options.receiveTimeout, const Duration(seconds: 10));
    });

    test('retries on 500 error and succeeds on subsequent try', () async {
      final adapter = SequenceAdapter([
        (_) => jsonResponse(500, {'error': 'Internal Server Error'}),
        (_) => jsonResponse(200, {'success': true}),
      ]);

      final dio = createDio(retryDelays: [Duration.zero, Duration.zero])
        ..httpClientAdapter = adapter;

      final res = await dio.get<Map<String, dynamic>>(
        'https://example.com/api',
      );
      expect(res.statusCode, 200);
      expect(res.data?['success'], true);
      expect(adapter.callCount, 2);
    });

    test('does NOT retry on 404 client error', () async {
      final adapter = SequenceAdapter([
        (_) => jsonResponse(404, {'error': 'Not Found'}),
        (_) => jsonResponse(200, {'success': true}),
      ]);

      final dio = createDio(retryDelays: [Duration.zero, Duration.zero])
        ..httpClientAdapter = adapter;

      await expectLater(
        dio.get<dynamic>('https://example.com/api/notfound'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
      expect(adapter.callCount, 1);
    });

    test(
      'retries up to maxRetries on network errors then propagates error',
      () async {
        final adapter = SequenceAdapter([
          (options) => throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
          ),
          (options) => throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          ),
          (options) => throw DioException(
            requestOptions: options,
            type: DioExceptionType.receiveTimeout,
          ),
        ]);

        final dio = createDio(retryDelays: [Duration.zero, Duration.zero])
          ..httpClientAdapter = adapter;

        await expectLater(
          dio.get<dynamic>('https://example.com/api/fail'),
          throwsA(isA<DioException>()),
        );

        expect(adapter.callCount, 3);
      },
    );
  });
}
