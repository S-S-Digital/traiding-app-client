
import 'dart:io' show Platform;

import 'package:aspiro_trade/features/settings/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Future<Object?> showExitDialog(BuildContext context, VoidCallback confirm) {
//     return showGeneralDialog(
//       context: context,
//       barrierLabel: "ExitDialog",
//       barrierDismissible: true,
//       barrierColor: Colors.black54,
//       transitionDuration: const Duration(milliseconds: 800),
//       pageBuilder: (context, animation, secondaryAnimation) {
//         return ExitDialog(confirm: confirm);
//       },
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         final offsetAnimation =
//             Tween<Offset>(
//               begin: const Offset(0, 1), // снизу вверх
//               end: Offset.zero,
//             ).animate(
//               CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
//             );

//         return SlideTransition(position: offsetAnimation, child: child);
//       },
//     );
//   }



Future<Object?> showExitDialog(
  BuildContext context,
  VoidCallback confirm,
) {
  if (Platform.isIOS) {
    // iOS стиль
    return showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context), // Отмена
            child: const Text('Отмена'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              confirm(); // Подтверждение выхода
            },
            isDestructiveAction: true,
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  } else {
    // Android стиль
    return showGeneralDialog(
      context: context,
      barrierLabel: "ExitDialog",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ExitDialog(confirm: confirm);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation =
            Tween<Offset>(
              begin: const Offset(0, 1), // снизу вверх
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            );

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}