import 'package:aspiro_trade/ui/ui.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String message, String title, VoidCallback onPressed) {
  return showGeneralDialog(
    context: context,
    barrierLabel: "ErrorDialog",
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 800  ),
    pageBuilder: (context, animation, secondaryAnimation) {
      return ErrorDialog(message: message, title: title, onPressed: onPressed,);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 1), // снизу вверх
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
      );

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
