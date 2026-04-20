import 'dart:async';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Future<(String?, String?)> Function() getTokens;
  final Future<void> Function(String accessToken, String refreshToken)
      saveTokens;
  final Future<void> Function() onForceLogout;
  final Dio dio;

  // Mutex: if a refresh is already in progress, all other 401s wait for it
  Completer<String?>? _refreshCompleter;
  bool _isLoggingOut = false;

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
    if (_skipPaths.contains(options.path)) {
      return handler.next(options);
    }

    final (accessToken, _) = await getTokens();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 ||
        err.requestOptions.path.contains('/auth/refresh')) {
      return handler.next(err);
    }

    try {
      final newAccessToken = await _refreshOrWait();

      if (newAccessToken == null) {
        // Refresh failed — force logout and kick to login screen
        if (!_isLoggingOut) {
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

    try {
      final (_, refreshToken) = await getTokens();
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(null);
        return null;
      }

      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final newAccess = response.data['accessToken'] as String?;
      final newRefresh = response.data['refreshToken'] as String?;

      if (newAccess == null || newRefresh == null) {
        _refreshCompleter!.complete(null);
        return null;
      }

      await saveTokens(newAccess, newRefresh);
      _refreshCompleter!.complete(newAccess);
      return newAccess;
    } catch (e) {
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }
}
