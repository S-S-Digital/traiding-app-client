import 'package:flutter/material.dart';

class DeleteTickerDialog extends StatelessWidget {
  const DeleteTickerDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Удалить тикер?'),
      content: const Text(
        'Это действие нельзя отменить.',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, false),
          child: const Text('Нет'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, true),
          child: const Text('Да'),
        ),
      ],
    );
  }
}
