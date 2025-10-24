import 'dart:io';

import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:dio/dio.dart';
import 'package:talker/talker.dart';



abstract class BaseRepository {
  final Talker talker;

  const BaseRepository(this.talker);

  Future<T> safeApiCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e, stack) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['message'] ?? e.message;

      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw NetworkException('Нет интернет-соединения');
      }
      talker.error('DioException: $message', e, stack);
      throw AppExceptionFactory.fromStatusCode(statusCode, message);
    } on AppException {
      rethrow;
    }
    
    catch (e, stack) {
      talker.error('Unknown error', e, stack);
      throw UnknownException(e.toString());
    }
  }
}
