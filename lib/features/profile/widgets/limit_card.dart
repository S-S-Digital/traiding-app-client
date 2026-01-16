
import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:flutter/material.dart';

class LimitCard extends StatelessWidget {
  const LimitCard({super.key, required this.limits});

  final Limits limits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusText = limits.maxTickers.type == MaxTickersType.unlimited
        ? 'Безлимит'
        : limits.canAddMoreTickers
        ? 'Можно добавлять'
        : 'Достигнут лимит';

    return Container(
      margin: const EdgeInsetsGeometry.all(15),
      padding: const EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Тикеры: ',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                limits.maxTickers.type == MaxTickersType.unlimited
                    ? 'Безлимит'
                    : '${limits.currentTickers}/${limits.maxTickers.value}',

                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Статус: ',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                statusText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            'Доступные функции:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Wrap(
              spacing: 50,
              runSpacing: 8,
              children: limits.readableFeatures.map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(
                    color: limits.isPremium
                        ? AppColors.darkAccentGold.withValues(alpha: 0.1)
                        : theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: limits.isPremium
                          ? AppColors.darkAccentGold
                          : theme.primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    feature,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: limits.isPremium
                          ? AppColors.darkAccentGold
                          : theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

