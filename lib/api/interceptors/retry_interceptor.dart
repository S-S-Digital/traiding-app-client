import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:aspiro_trade/repositories/core/logs/app_logger.dart';

/// Retry interceptor with exponential backoff for transient failures.
///
/// Retries on:
/// - Connection timeouts, send timeouts, receive timeouts
/// - Connection errors (SocketException, etc.)
/// - 5xx server errors (502, 503, 504)
/// - 429 Too Many Requests (respects Retry-After header)
///
/// Does NOT retry:
/// - 4xx client errors (400, 401, 403, 404, 409)
/// - Cancelled requests
/// - Requests that have already been retried [maxRetries] times
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
  });

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;

  static const _retryCountKey = '_retryCount';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = (extra[_retryCountKey] as int?) ?? 0;

    if (!_shouldRetry(err) || retryCount >= maxRetries) {
      return handler.next(err);
    }

    final delay = _calculateDelay(err, retryCount);
    talker.warning(
      '🔄 Retry ${retryCount + 1}/$maxRetries for '
      '${err.requestOptions.method} ${err.requestOptions.path} '
      'after ${delay.inMilliseconds}ms '
      '(${_errorReason(err)})',
    );

    await Future.delayed(delay);

    try {
      err.requestOptions.extra[_retryCountKey] = retryCount + 1;
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    // Don't retry cancelled requests
    if (err.type == DioExceptionType.cancel) return false;

    // IDEMPOTENCY GUARD (audit C2): a POST/PUT/PATCH that the server may have
    // already processed but whose response was lost (timeout / dropped
    // connection) must NEVER be replayed — that produced duplicate account
    // registrations and duplicate payment-receipt submissions. We only know the
    // server did NOT act when it explicitly signals so (502/503/504/429 below),
    // which is handled by the status-code branch. Any error with NO response
    // (timeout/connection) on a non-idempotent method → do not retry.
    final method = err.requestOptions.method.toUpperCase();
    final isNonIdempotent =
        method == 'POST' || method == 'PUT' || method == 'PATCH';

    // Retry all timeout and connection errors — but only for idempotent methods.
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return !isNonIdempotent;
    }

    // Retry on SocketException (network unreachable, etc.) — idempotent only.
    if (err.error is SocketException) return !isNonIdempotent;

    // Retry on specific HTTP status codes where the server signals it did NOT
    // act (safe to replay even for POST/PUT/PATCH).
    final statusCode = err.response?.statusCode;
    if (statusCode != null) {
      return statusCode == 429 || // Too Many Requests
          statusCode == 502 || // Bad Gateway
          statusCode == 503 || // Service Unavailable
          statusCode == 504; // Gateway Timeout
    }

    return false;
  }

  Duration _calculateDelay(DioException err, int retryCount) {
    // Respect Retry-After header for 429
    if (err.response?.statusCode == 429) {
      final retryAfter = err.response?.headers.value('retry-after');
      if (retryAfter != null) {
        final seconds = int.tryParse(retryAfter);
        if (seconds != null) {
          return Duration(seconds: seconds);
        }
      }
    }

    // Exponential backoff: 1s, 2s, 4s
    return baseDelay * (1 << retryCount);
  }

  String _errorReason(DioException err) {
    if (err.response?.statusCode != null) {
      return 'HTTP ${err.response!.statusCode}';
    }
    return err.type.name;
  }
}
