import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:dio/dio.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage tokenStorage;
  final AuthRepositoryI authRepository;

  bool _isRefreshing = false;
  final _queue = <(RequestOptions, ErrorInterceptorHandler)>[];

  RefreshTokenInterceptor(this.dio, this.tokenStorage, this.authRepository);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final (_, refresh) = await tokenStorage.getTokens();
    if (refresh == null) {
      return handler.reject(err);
    }

    if (_isRefreshing) {
      
      _queue.add((err.requestOptions, handler));
      return;
    }

    _isRefreshing = true;
    final newAccess = await authRepository.refresh(Refresh(refreshToken: refresh));

    // Повторяем неудавшийся запрос
    err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
    final cloneReq = await dio.fetch(err.requestOptions);
    handler.resolve(cloneReq);

    // Повторяем все запросы из очереди
    for (final (req, queuedHandler) in _queue) {
      req.headers['Authorization'] = 'Bearer $newAccess';
      final clone = await dio.fetch(req);
      queuedHandler.resolve(clone);
    }
    _queue.clear();
    _isRefreshing = false;
  }
}
