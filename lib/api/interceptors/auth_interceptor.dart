import 'dart:async';
import 'package:dio/dio.dart';

import 'package:aspiro_trade/ui/localization/app_localizations.dart';

class AuthInterceptor extends Interceptor {
  final Future<(String?, String?)> Function() getTokens;
  final Future<void> Function(String accessToken, String refreshToken)
      saveTokens;
  final Future<void> Function() onForceLogout;
  final Dio dio;

  // Mutex: if a refresh is already in progress, all other 401s wait for it
  Completer<String?>? _refreshCompleter;
  bool _isLoggingOut = false;

  // Set by the current refresh cycle: true only when the refresh failed for a
  // DEFINITIVE auth reason (missing refresh token, or the refresh endpoint
  // rejected us with 401/403). Transient failures (no network, timeout, 5xx,
  // 429-exhausted, malformed 200) leave this false so we DON'T log the user out
  // for a connectivity blip.
  bool _refreshAuthFailure = false;

  AuthInterceptor({
    required this.getTokens,
    required this.saveTokens,
    required this.onForceLogout,
    required this.dio,
  });

  static const _skipPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/google/mobile',
    '/auth/apple/mobile',
  ];

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Add dynamic language header on every outgoing API request
    options.headers['Accept-Language'] = AppLocalizations.isRu ? 'ru' : 'en';

    if (_skipPaths.contains(options.path)) {
      return handler.next(options);
    }

    final (accessToken, _) = await getTokens();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      return handler.next(options);
    }

    // No access token for a protected request. Do NOT fire it tokenless:
    // during cold start (before secure storage hydrates) or while logged out,
    // a tokenless request would 401 and trigger a spurious force-logout. Reject
    // locally instead — routing/auth gating (splash) decides login vs home.
    return handler.reject(
      DioException(
        requestOptions: options,
        type: DioExceptionType.cancel,
        error: 'No auth token — request suppressed',
      ),
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only a 401 on a request that ACTUALLY carried a token is a real session
    // failure worth refreshing / logging out for. A 401 on a tokenless request
    // (cold-start race / already logged out) must never force a logout — there
    // was no session to lose.
    final hadToken =
        err.requestOptions.headers['Authorization']?.toString().isNotEmpty ??
            false;
    if (err.response?.statusCode != 401 ||
        err.requestOptions.path.contains('/auth/refresh') ||
        !hadToken) {
      return handler.next(err);
    }

    try {
      final newAccessToken = await _refreshOrWait();

      if (newAccessToken == null) {
        // Refresh did not yield a token. Only force a logout if the refresh
        // failed for a definitive auth reason. On transient failures (offline,
        // timeout, 5xx, 429) keep the session and just surface the error —
        // logging the user out for a network blip is the bug we're fixing.
        if (_refreshAuthFailure && !_isLoggingOut) {
          _isLoggingOut = true;
          await onForceLogout();
          _isLoggingOut = false;
        }
        return handler.next(err);
      }

      // Retry the original request with new token
      final retryResponse = await dio.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: Options(
          method: err.requestOptions.method,
          headers: {
            ...err.requestOptions.headers,
            'Authorization': 'Bearer $newAccessToken',
          },
        ),
      );

      return handler.resolve(retryResponse);
    } catch (_) {
      return handler.next(err);
    }
  }

  /// If a refresh is already in flight, wait for it.
  /// Otherwise, start a new refresh and let others wait.
  Future<String?> _refreshOrWait() async {
    // Another call is already refreshing — just wait for the result
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();
    // Default to transient: only flip to true on a proven auth failure so a
    // thrown/unexpected error never causes a spurious logout.
    _refreshAuthFailure = false;

    try {
      final (_, refreshToken) = await getTokens();
      if (refreshToken == null || refreshToken.isEmpty) {
        // No refresh token at all => the session is genuinely gone.
        _refreshAuthFailure = true;
        _refreshCompleter!.complete(null);
        return null;
      }

      final Response? response;
      try {
        response = await _refreshWithRetry(refreshToken);
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        // 401/403 from the refresh endpoint = the refresh token is invalid/
        // revoked => real auth failure. Anything else (offline, timeout, 5xx)
        // is transient => keep the session.
        _refreshAuthFailure = status == 401 || status == 403;
        _refreshCompleter!.complete(null);
        return null;
      }

      // 429 retries exhausted (rate limited) — transient, do not log out.
      if (response == null) {
        _refreshCompleter!.complete(null);
        return null;
      }

      final data = response.data;
      final newAccess = data is Map ? data['accessToken'] as String? : null;
      final newRefresh = data is Map ? data['refreshToken'] as String? : null;

      if (newAccess == null ||
          newAccess.isEmpty ||
          newRefresh == null ||
          newRefresh.isEmpty) {
        // 200 but malformed/empty body — likely a transient server glitch, not
        // proof the session is invalid. Keep the user logged in.
        _refreshCompleter!.complete(null);
        return null;
      }

      // Persist BOTH the new access token and the rotated refresh token so the
      // next refresh uses the latest (rotated) refresh token.
      await saveTokens(newAccess, newRefresh);
      _refreshCompleter!.complete(newAccess);
      return newAccess;
    } catch (e) {
      // Unexpected error — treat as transient (no logout).
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Posts /auth/refresh with exponential backoff on 429 (max 3 attempts).
  /// Respects Retry-After header when present.
  /// Returns null if all retries exhausted or a non-429 error occurred.
  Future<Response?> _refreshWithRetry(String refreshToken) async {
    const maxAttempts = 3;
    var delay = const Duration(seconds: 1);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await dio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 429 || attempt == maxAttempts) {
          if (e.response?.statusCode == 429) {
            return null;
          }
          rethrow;
        }

        final retryAfter = _parseRetryAfter(e.response?.headers.value('retry-after'));
        await Future<void>.delayed(retryAfter ?? delay);
        delay *= 2;
      }
    }
    return null;
  }

  Duration? _parseRetryAfter(String? value) {
    if (value == null || value.isEmpty) return null;
    final seconds = int.tryParse(value.trim());
    if (seconds != null && seconds > 0) {
      return Duration(seconds: seconds);
    }
    return null;
  }
}
