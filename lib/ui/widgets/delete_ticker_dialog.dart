import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class DeleteTickerDialog extends StatelessWidget {
  const DeleteTickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Delete ticker?',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      content: const Text(
        'This action cannot be undone.',
        style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: AppColors.down, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
