import 'dart:io' show Platform;

import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talker/talker.dart';
import 'package:dio/dio.dart';

extension AppExceptionHandler on BuildContext {
  /// Главная точка входа для обработки ошибок
  void handleException(
    Object? error,
    BuildContext context, {
    VoidCallback? onPressed,
    bool kickToLoginOnUnauthorized = true,
  }) {
    if (error == null) return;

    final AppException appException;
    if (error is AppException) {
      appException = error;
    } else if (error is DioException) {
      appException = DioExceptionFactory.fromDioException(error, Talker());
    } else {
      final errStr = error.toString();
      final lowerStr = errStr.toLowerCase();
      if (lowerStr.contains('timeoutexception') || lowerStr.contains('timeout')) {
        appException = TimeoutException(AppLocalizations.errorTimeout);
      } else if (lowerStr.contains('socketexception') ||
                 lowerStr.contains('network') ||
                 lowerStr.contains('failed host lookup') ||
                 lowerStr.contains('unreachable')) {
        appException = NetworkException(AppLocalizations.errorNoNetwork);
      } else if (lowerStr.contains('unauthorized') || lowerStr.contains('401')) {
        appException = UnauthorizedException(AppLocalizations.errorSessionExpired);
      } else if (lowerStr.contains('forbidden') || lowerStr.contains('403')) {
        appException = FordibenException(AppLocalizations.errorPremiumRequired);
      } else if (lowerStr.contains('signinwithapple') || lowerStr.contains('authorizationerror') || lowerStr.contains('appleauth')) {
        appException = UnknownException(
          AppLocalizations.isRu 
            ? 'Ошибка входа через Apple. Убедитесь, что вы вошли в Apple ID на вашем устройстве.'
            : 'Apple Sign-In failed. Please ensure you are logged into your Apple ID on this device.'
        );
      } else if (lowerStr.contains('googlesignin') || lowerStr.contains('googleauth')) {
        appException = UnknownException(
          AppLocalizations.isRu
            ? 'Ошибка входа через Google. Попробуйте еще раз или выберите другой способ.'
            : 'Google Sign-In failed. Please try again or select another method.'
        );
      } else {
        // Clean technical terms to hide raw technical details
        final isTechnical = errStr.contains('{') ||
            errStr.contains('<') ||
            errStr.contains('dio') ||
            lowerStr.contains('exception') ||
            lowerStr.contains('error') ||
            lowerStr.contains('stacktrace') ||
            lowerStr.contains('http');

        if (isTechnical) {
          appException = UnknownException(AppLocalizations.errorUnknown);
        } else {
          appException = UnknownException(errStr);
        }
      }
    }

    if (appException is NetworkException) {
      showNetworkErrorSnackBar();
    } else if (appException is UnauthorizedException && !kickToLoginOnUnauthorized) {
      // On the auth screens a 401 means bad credentials, NOT an expired session.
      // Show the real message instead of the "session expired → go to login"
      // dialog (we are already on the login/register screen).
      _showErrorSnackBar(appException.message);
    } else if (appException is UnauthorizedException) {
      // Только для Unauthorized — показываем диалог и делаем logout
      _showErrorDialog(
        title: AppLocalizations.sessionExpired,
        message: AppLocalizations.logInAgain,
        onPressed: () {
          Navigator.of(context).pop();
          onPressed?.call();
          AutoRouter.of(
            context,
          ).pushAndPopUntil(const LoginRoute(), predicate: (_) => false);
        },
      );
    } else if (appException is FordibenException) {
      // 403 — Premium required: handled inline by each screen, suppress snackbar
      return;
    } else {
      // Все остальные ошибки — тихий snackbar, не блокирующий UI
      _showErrorSnackBar(appException.message);
    }
  }

  void _showPremiumRequiredSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textQuaternary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Lock icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.brand.withValues(alpha: 0.15),
                    AppColors.brand.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 36,
                color: AppColors.brand,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.premiumRequired,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.premiumSubtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Feature list
            _PremiumFeatureRow(icon: Icons.cell_tower_rounded, text: AppLocalizations.featureUnlimitedSignals),
            const SizedBox(height: 12),
            _PremiumFeatureRow(icon: Icons.analytics_outlined, text: AppLocalizations.featureAdvancedAnalytics),
            const SizedBox(height: 12),
            _PremiumFeatureRow(icon: Icons.add_chart_rounded, text: AppLocalizations.featureUnlimitedTickers),
            const SizedBox(height: 12),
            _PremiumFeatureRow(icon: Icons.notifications_active_outlined, text: AppLocalizations.featurePriorityAlerts),
            const SizedBox(height: 28),
            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  AutoRouter.of(context).push(const SubscriptionRoute());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.upgradeToPlan,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Close
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                AppLocalizations.maybeLater,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(this);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        backgroundColor: AppColors.darkAccentRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showBusinessErrorSnackbar(String text, VoidCallback onPressed) {
    final theme = Theme.of(this);
    final messenger = ScaffoldMessenger.of(this);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onError, // Используем on-color из темы
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        backgroundColor:
            theme.colorScheme.error, // Берем красный из ColorScheme
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: AppLocalizations.close,
          textColor: theme.colorScheme.onError,
          onPressed: () {
            messenger.hideCurrentSnackBar();
            onPressed();
          },
        ),
      ),
    );
  }

  // --- ЛОГИКА SNACKBAR (Твой метод) ---
  void showNetworkErrorSnackBar() {
    final theme = Theme.of(this);
    final messenger = ScaffoldMessenger.of(this);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.noInternet,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onError, // Используем on-color из темы
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        backgroundColor:
            theme.colorScheme.error, // Берем красный из ColorScheme
        duration: const Duration(days: 1),

        action: SnackBarAction(
          label: AppLocalizations.close,
          textColor: theme.colorScheme.onError,
          onPressed: messenger.hideCurrentSnackBar,
        ),
      ),
    );
  }

  // --- ЛОГИКА DIALOG (Твой метод с анимацией и платформенностью) ---
  Future<void> _showErrorDialog({
    required String title,
    required String message,
    required VoidCallback onPressed,
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: this,
        barrierDismissible: false,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          content: Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: onPressed,
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Android стиль с твоей кастомной анимацией
      return showGeneralDialog(
        context: this,
        barrierLabel: "ErrorDialog",
        barrierDismissible: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(
          milliseconds: 600,
        ), // Оптимально для EaseOutBack
        pageBuilder: (context, animation, secondaryAnimation) {
          // Здесь вызывается твой кастомный виджет ErrorDialog
          return ErrorDialog(
            message: message,
            title: title,
            onPressed: onPressed,
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation =
              Tween<Offset>(
                begin: const Offset(0, 1), // Снизу вверх
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              );

          return SlideTransition(position: offsetAnimation, child: child);
        },
      );
    }
  }


  Future<void> showSuccesDialog({
    required String title,
    required String message,
    required VoidCallback onPressed,
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: this,
        barrierDismissible: false,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          content: Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: onPressed,
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Android стиль с твоей кастомной анимацией
      return showGeneralDialog(
        context: this,
        barrierLabel: "success",
        barrierDismissible: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(
          milliseconds: 600,
        ), // Оптимально для EaseOutBack
        pageBuilder: (context, animation, secondaryAnimation) {
          return ErrorDialog(
            message: message,
            title: title,
            onPressed: onPressed,
            dialogTitle: '✓',
            buttonColor: AppColors.brand,
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation =
              Tween<Offset>(
                begin: const Offset(0, 1), // Снизу вверх
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              );

          return SlideTransition(position: offsetAnimation, child: child);
        },
      );
    }
  }

  /// Главная функция вызова, разделяющая логику на две платформы
  Future<bool?> showDeleteAccountDialog(BuildContext context) async {
    if (Platform.isIOS) {
      return _showIOSDeleteDialog(context);
    } else {
      return _showAndroidDeleteDialog(context);
    }
  }

  /// Реализация для iOS (Cupertino Style)
  /// Apple ожидает стандартный размытый фон и характерную типографику.
  Future<bool?> _showIOSDeleteDialog(BuildContext context) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(
          AppLocalizations.deleteAccount,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          AppLocalizations.deleteAccountConfirm,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction:
                true, // Делает текст красным и выделяет значимость
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.delete),
          ),
        ],
      ),
    );
  }

  /// Реализация для Android (Material 3 Style)
  /// Используется стандартный AlertDialog с закругленными углами.
  Future<bool?> _showAndroidDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.deleteAccount),
        content: Text(
          AppLocalizations.deleteAccountConfirm,
        ),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.cancel.toUpperCase()),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(AppLocalizations.delete.toUpperCase()),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeatureRow extends StatelessWidget {
  const _PremiumFeatureRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.brand.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.brand),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: AppColors.brand,
        ),
      ],
    );
  }
}
