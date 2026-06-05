import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:talker/talker.dart';

/// Maps any purchase/restore error into a FRIENDLY, localized (RU/EN) message.
///
/// IMPORTANT: this never returns raw backend / store text. Unknown errors fall
/// back to a generic, reassuring message. The internal English strings the bloc
/// emits ("Store unavailable", "Purchase error", "Restore failed", a raw
/// `purchase.error.message`, …) are intentionally normalised here.
String mapPurchaseError(Object? error) {
  if (error == null) return AppLocalizations.purchaseFailedGeneric;

  if (error is AppException) return _mapAppException(error);

  if (error is DioException) {
    return _mapAppException(DioExceptionFactory.fromDioException(error, Talker()));
  }

  final lower = error.toString().toLowerCase();

  if (lower.contains('cancel')) {
    return AppLocalizations.purchaseCancelled;
  }
  if (lower.contains('nothing to restore')) {
    return AppLocalizations.nothingToRestore;
  }
  if (lower.contains('store unavailable') || lower.contains('unavailable')) {
    return AppLocalizations.errorServerUnavailable;
  }
  if (lower.contains('timeout')) {
    return AppLocalizations.errorTimeout;
  }
  if (lower.contains('socket') ||
      lower.contains('network') ||
      lower.contains('failed host lookup') ||
      lower.contains('unreachable') ||
      lower.contains('internet')) {
    return AppLocalizations.errorNoNetwork;
  }
  if (lower.contains('unauthorized') || lower.contains('401')) {
    return AppLocalizations.errorSessionExpired;
  }
  if (lower.contains('forbidden') || lower.contains('403')) {
    return AppLocalizations.errorPremiumRequired;
  }

  // Default — never leak raw text to the user.
  return AppLocalizations.purchaseFailedGeneric;
}

String _mapAppException(AppException e) {
  final name = e.runtimeType.toString().toLowerCase();
  if (name.contains('network')) return AppLocalizations.errorNoNetwork;
  if (name.contains('timeout')) return AppLocalizations.errorTimeout;

  final code = e.statusCode;
  if (code == 400) return AppLocalizations.errorBadRequest;
  if (code == 401) return AppLocalizations.errorSessionExpired;
  if (code == 403) return AppLocalizations.errorPremiumRequired;
  if (code == 409) return AppLocalizations.errorConflict;
  if (code == 429) return AppLocalizations.errorTooManyRequests;
  if (code != null && code >= 500) return AppLocalizations.errorServerUnavailable;

  return AppLocalizations.purchaseFailedGeneric;
}
