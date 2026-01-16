import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8), // Микро-отступ между заголовком и подзаголовком
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha:0.7),
          ),
        ),
      ],
    );
  }
}