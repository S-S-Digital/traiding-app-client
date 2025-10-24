import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Future<(String?, String?)> Function() getTokens;
  final Future<void> Function(String accessToken, String refreshToken) saveTokens;
  final Dio dio;

  AuthInterceptor({
    required this.getTokens,
    required this.saveTokens,
    required this.dio,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    
    if (options.path.contains('/auth/')) {
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
    
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/refresh')) {
      final (_, refreshToken) = await getTokens();
      if (refreshToken == null || refreshToken.isEmpty) {
        return handler.next(err); 
      }

      try {
        
        final response = await dio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
          options: Options(headers: {'Authorization': null}),
        );

        final newAccess = response.data['accessToken'] as String?;
        final newRefresh = response.data['refreshToken'] as String?;

        if (newAccess == null || newRefresh == null) {
          return handler.next(err);
        }

        
        await saveTokens(newAccess, newRefresh);

        final retryResponse = await dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: Options(
            method: err.requestOptions.method,
            headers: {
              ...err.requestOptions.headers,
              'Authorization': 'Bearer $newAccess',
            },
          ),
        );

        return handler.resolve(retryResponse);
      } catch (e) {
        
        return handler.next(err);
      }
    }

    
    handler.next(err);
  }
}
