import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:dio/dio.dart';
import 'package:talker/talker.dart';

abstract class BaseRepository {
  final Talker talker;

  const BaseRepository(this.talker);

  Future<T> safeApiCall<T>(Future<T> Function() call) async {
    try {
      return await call();

    } on AppException catch(error){
   
      throw AppExceptionFactory.fromStatusCode(error.statusCode);
    } on DioException catch(error) {
      
      final status = error.response?.statusCode;

    talker.error(
      'DioException: $status',
      error,
      error.stackTrace,
    );

    // Преобразуем в AppException
    throw AppExceptionFactory.fromStatusCode(status);
    } catch (e, stack) {
      // Любые другие неожиданные ошибки
      talker.error('Unknown error', e, stack);
      throw UnknownException(e.toString());
    }
  }
}
