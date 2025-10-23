import 'package:aspiro_trade/ui/ui.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String message) {
  return showGeneralDialog(
    context: context,
    barrierLabel: "ErrorDialog",
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (context, animation, secondaryAnimation) {
      return ErrorDialog(message: message);
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
