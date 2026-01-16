
import 'package:flutter/material.dart';

class SubscriptionTitle extends StatelessWidget {
  const SubscriptionTitle({
    super.key,
    
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Разблокируй полный потенциал',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Получи доступ к расширенной аналитике, неограниченным сигналам и приоритетной поддержке',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
