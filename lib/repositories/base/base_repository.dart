import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:dio/dio.dart';
import 'package:talker/talker.dart';

abstract class BaseRepository {
  final Talker talker;

  const BaseRepository(this.talker);

  Future<T> safeApiCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AppException {
      rethrow;
    } on DioException catch (error) {
      throw DioExceptionFactory.fromDioException(error, talker);
    } catch (e, stack) {
      // Любые другие неожиданные ошибки
      talker.error('Unknown error', e, stack);
      throw UnknownException(e.toString());
    }
  }
}
