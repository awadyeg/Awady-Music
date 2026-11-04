import 'dart:async';

import 'package:awady_music/core/util/log.dart';
import 'package:dio/dio.dart';

/// Interceptor that retries requests on network errors and HTTP 5xx responses.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryDelays = const [
      Duration(milliseconds: 500),
      Duration(milliseconds: 1000),
    ],
  });

  final Dio dio;
  final int maxRetries;
  final List<Duration> retryDelays;

  static const String retryCountKey = 'awady_retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final retryCount = (requestOptions.extra[retryCountKey] as int?) ?? 0;

    final shouldRetry = _shouldRetry(err) && retryCount < maxRetries;
    if (!shouldRetry) {
      return handler.next(err);
    }

    final delay = retryCount < retryDelays.length
        ? retryDelays[retryCount]
        : retryDelays.last;

    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    final nextRetryCount = retryCount + 1;
    requestOptions.extra[retryCountKey] = nextRetryCount;

    try {
      final response = await dio.fetch<dynamic>(requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    } on Object catch (_) {
      return handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    final status = err.response?.statusCode;
    if (status != null && status >= 500 && status < 600) {
      return true;
    }
    return false;
  }
}

/// Interceptor that logs HTTP requests, responses, and errors to [Log].
class HttpLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Log.i('HTTP ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final status = response.statusCode;
    final method = response.requestOptions.method;
    final uri = response.requestOptions.uri;
    Log.i('HTTP $status $method $uri');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode ?? err.type.name;
    final method = err.requestOptions.method;
    final uri = err.requestOptions.uri;
    Log.w('HTTP [$status] $method $uri: ${err.message}');
    handler.next(err);
  }
}

/// Creates a [Dio] instance configured with default timeouts (connect 8s,
/// receive 15s), [HttpLoggingInterceptor], and [RetryInterceptor].
Dio createDio({
  BaseOptions? options,
  List<Interceptor>? interceptors,
  int maxRetries = 2,
  List<Duration>? retryDelays,
}) {
  final baseOptions = (options ?? BaseOptions()).copyWith(
    connectTimeout: options?.connectTimeout ?? const Duration(seconds: 8),
    receiveTimeout: options?.receiveTimeout ?? const Duration(seconds: 15),
  );

  final dio = Dio(baseOptions);

  if (interceptors != null) {
    dio.interceptors.addAll(interceptors);
  }

  dio.interceptors.addAll([
    HttpLoggingInterceptor(),
    RetryInterceptor(
      dio: dio,
      maxRetries: maxRetries,
      retryDelays:
          retryDelays ??
          const [Duration(milliseconds: 500), Duration(milliseconds: 1000)],
    ),
  ]);

  return dio;
}
