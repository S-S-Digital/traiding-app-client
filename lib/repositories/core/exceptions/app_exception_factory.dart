import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';

final class AppExceptionFactory {
  const AppExceptionFactory._();

  static AppException fromStatusCode(int? statusCode, [String? message]) {
    final msg = message?.toLowerCase().trim();

    switch (statusCode) {
      case 400:
        return BadRequestException(_mapMessage(msg) ?? AppLocalizations.errorBadRequest);
      case 401:
        return UnauthorizedException(_mapMessage(msg) ?? AppLocalizations.errorUnauthorized);
      case 403:
        return FordibenException(_mapMessage(msg) ?? AppLocalizations.errorForbidden);
      case 409:
        return ConflictException(_mapMessage(msg) ?? AppLocalizations.errorConflict);
      case 429:
        return BadRequestException(_mapMessage(msg) ?? AppLocalizations.errorTooManyRequests);
      case 500:
        return InternalServerErrorException(_mapMessage(msg) ?? AppLocalizations.errorServer);
      case 502:
      case 503:
      case 504:
        return InternalServerErrorException(_mapMessage(msg) ?? AppLocalizations.errorServerUnavailable);
      default:
        return UnknownException(_mapMessage(msg) ?? AppLocalizations.errorUnknown);
    }
  }

  static String? _mapMessage(String? msg) {
    if (msg == null) return null;

    final normalized = msg.toLowerCase().trim();

    if (normalized.contains('invalid credentials') || normalized.contains('wrong password')) {
      return AppLocalizations.errorInvalidCredentials;
    }
    if (normalized.contains('user not found')) {
      return AppLocalizations.errorUserNotFound;
    }
    if (normalized.contains('email already exists')) {
      return AppLocalizations.errorEmailExists;
    }
    if (normalized.contains('network is unreachable')) {
      return AppLocalizations.errorNoConnection;
    }
    if (normalized.contains('token expired') || normalized.contains('unauthorized')) {
      return AppLocalizations.errorSessionExpired;
    }
    if (normalized.contains('premium required') || normalized.contains('forbidden')) {
      return AppLocalizations.errorPremiumRequired;
    }
    if (normalized.contains('too many requests')) {
      return AppLocalizations.errorTooManyRequests;
    }

    // If it's a simple human-readable string without HTML/JSON, return formatted
    if (!msg.contains('{') &&
        !msg.contains('<') &&
        !msg.contains('dio') &&
        !msg.contains('exception') &&
        !msg.contains('error')) {
      if (msg.isNotEmpty) {
        return msg[0].toUpperCase() + msg.substring(1);
      }
    }

    return null;
  }
}
