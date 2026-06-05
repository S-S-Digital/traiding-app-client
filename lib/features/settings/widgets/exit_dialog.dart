import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key, required this.confirm});

  final VoidCallback confirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        AppLocalizations.signOut,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
      content: Text(
        AppLocalizations.confirmSignOut,
        style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.cancel, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ),
        FilledButton(
          onPressed: confirm,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.down,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(AppLocalizations.signOut, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
