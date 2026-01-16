
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talker/talker.dart';
import 'package:aspiro_trade/repositories/core/core.dart';


class DioExceptionFactory {
  const DioExceptionFactory._();

  /// Преобразует DioException в кастомные сетевые или таймаут ошибки
  static AppException fromDioException(DioException e, Talker talker) {
    final message = e.response?.data?['message'] ?? e.message;

    // === Нет сети или сервер недоступен ===
    if (e.type == DioExceptionType.connectionError ||
        e.error is SocketException ||
        e.error is HandshakeException ||
        e.error.toString().contains('Failed host lookup') ||
        e.error.toString().contains('Network is unreachable')) {
      talker.error('Network error: $message', e, StackTrace.current);
      return const NetworkException('Нет подключения к сети или сервер недоступен');
    }

    // === Таймауты ===
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      talker.error('Timeout error: $message', e, StackTrace.current);
      return const TimeoutException('Сервер не отвечает. Попробуйте позже.');
    }

    // === Любая другая неизвестная ошибка Dio ===
    talker.error('Unknown Dio error: $message', e, StackTrace.current);
    return UnknownException('Произошла ошибка соединения: $message');
  }
}
