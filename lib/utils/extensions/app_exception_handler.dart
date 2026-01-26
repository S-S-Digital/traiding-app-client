import 'dart:io' show Platform;

import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
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
    } else {
      _showErrorDialog(
        title: 'Ошибка',
        message: error.message,
        onPressed: () {
          // 1. Всегда закрываем диалог
          Navigator.of(context).pop();

          // 2. Кастомное действие (если передали)
          onPressed?.call();

          // 3. Принудительный logout при Unauthorized
          if (error is UnauthorizedException) {
            AutoRouter.of(
              context,
            ).pushAndPopUntil(const LoginRoute(), predicate: (_) => false);
          }
        },
      );
    }
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
