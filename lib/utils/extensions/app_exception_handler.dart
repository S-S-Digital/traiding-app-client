import 'dart:io' show Platform;

import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension AppExceptionHandler on BuildContext {
  /// Главная точка входа для обработки ошибок
  void handleException(
    AppException error,
    BuildContext context, {
    VoidCallback? onPressed,
  }) {
    if (error is NetworkException) {
      showNetworkErrorSnackBar();
    } else if (error is UnauthorizedException) {
      // Только для Unauthorized — показываем диалог и делаем logout
      _showErrorDialog(
        title: 'Сессия истекла',
        message: 'Войдите в аккаунт заново',
        onPressed: () {
          Navigator.of(context).pop();
          onPressed?.call();
          AutoRouter.of(
            context,
          ).pushAndPopUntil(const LoginRoute(), predicate: (_) => false);
        },
      );
    } else if (error is FordibenException) {
      // 403 — Premium required: handled inline by each screen, suppress snackbar
      return;
    } else {
      // Все остальные ошибки — тихий snackbar, не блокирующий UI
      _showErrorSnackBar(error.message);
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
            const Text(
              'Premium Required',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upgrade to Pro to unlock all features',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Feature list
            _PremiumFeatureRow(icon: Icons.cell_tower_rounded, text: 'Unlimited trading signals'),
            const SizedBox(height: 12),
            _PremiumFeatureRow(icon: Icons.analytics_outlined, text: 'Advanced analytics & history'),
            const SizedBox(height: 12),
            _PremiumFeatureRow(icon: Icons.add_chart_rounded, text: 'Unlimited ticker tracking'),
            const SizedBox(height: 12),
            _PremiumFeatureRow(icon: Icons.notifications_active_outlined, text: 'Real-time push notifications'),
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
                child: const Text(
                  'Upgrade to Pro',
                  style: TextStyle(
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
              child: const Text(
                'Maybe Later',
                style: TextStyle(
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
          label: 'Закрыть',
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
          'Нет подключения к интернету',
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
          label: 'Закрыть',
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
          'Удаление аккаунта',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Ваш профиль и все связанные данные будут стерты. Вы действительно хотите продолжить?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          CupertinoDialogAction(
            isDestructiveAction:
                true, // Делает текст красным и выделяет значимость
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
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
        title: const Text('Удаление учетной записи'),
        content: const Text(
          'Ваш профиль и все связанные данные будут стерты. Вы действительно хотите продолжить?',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('ОТМЕНА'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('УДАЛИТЬ'),
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
