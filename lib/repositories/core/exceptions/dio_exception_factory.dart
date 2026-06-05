
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talker/talker.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';


class DioExceptionFactory {
  const DioExceptionFactory._();

  /// Converts DioException into custom network or timeout errors
  static AppException fromDioException(DioException e, Talker talker) {
    final message = e.response?.data is Map
        ? (e.response?.data as Map)['message']?.toString()
        : e.message;

    // === Server response errors (4xx, 5xx) ===
    if (e.type == DioExceptionType.badResponse) {
      talker.error('API Server error: $message (Status: ${e.response?.statusCode})', e, StackTrace.current);
      return AppExceptionFactory.fromStatusCode(e.response?.statusCode, message);
    }

    // === No network or server unreachable ===
    if (e.type == DioExceptionType.connectionError ||
        e.error is SocketException ||
        e.error is HandshakeException ||
        e.error.toString().contains('Failed host lookup') ||
        e.error.toString().contains('Network is unreachable')) {
      talker.error('Network error: $message', e, StackTrace.current);
      return NetworkException(AppLocalizations.errorNoNetwork);
    }

    // === Timeouts ===
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      talker.error('Timeout error: $message', e, StackTrace.current);
      return TimeoutException(AppLocalizations.errorTimeout);
    }

    // === Any other unknown Dio error ===
    talker.error('Unknown Dio error: $message', e, StackTrace.current);
    return UnknownException(AppLocalizations.errorConnection(message));
  }
}
