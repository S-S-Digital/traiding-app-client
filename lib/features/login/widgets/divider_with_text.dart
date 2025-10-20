import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  const DividerWithText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: theme.dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('или', style: theme.textTheme.bodyMedium),
        ),
        Expanded(child: Container(height: 1, color: theme.dividerColor)),
      ],
    );
  }
}