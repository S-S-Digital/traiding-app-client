
import 'package:aspiro_trade/features/settings/models/models.dart';
import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem({super.key, required this.item, required this.onTap});

  final SettingsItems item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: 0,
        title: Text(
          item.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: item.isSwitch == true
            ? Switch(value: item.switchValue, onChanged: (value) {})
            : const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
