
import 'package:flutter/material.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key, required this.confirm});

  final VoidCallback confirm;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: Text(
        'Выход из аккаунта',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Вы уверены, что хотите выйти?',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        FilledButton(
          onPressed:confirm,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'да'.toUpperCase(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),

        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Нет'),
        ),
      ],
    );
  }
}
