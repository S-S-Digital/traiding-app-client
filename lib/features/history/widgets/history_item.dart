import 'package:aspiro_trade/features/history/models/models.dart';
import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {
  const HistoryItem({super.key, required this.history});

  final CombinedHistory history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: size.height * 0.2,
          maxHeight: size.height * 0.7,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: theme.colorScheme.secondary,
                          size: size.height * 0.02,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          history.history.formatStatus(history.history.status),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    DateFormatter.format(history.history.closedAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.network(
                  history.assets.logoUrl,

                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                    );
                  },
                ),
                title: Text(
                  history.history.symbol,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  history.history.formatDirection(history.history.direction),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height * 0.1,
                  maxHeight: size.height * 0.4,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Вход:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          Text(
                            '${history.history.entry}\$',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Тейк-профит:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          Text(
                            '${history.history.takeProfit}\$',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Стоп-лосс:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          Text(
                            '${history.history.stopLoss}\$',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Выход:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          Text(
                            '${history.history.exit}\$',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Результат:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          Text(
                            '${history.history.resultPct}% (${history.history.resultUsd}\$)',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Таймфрейм:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          Text(
                            history.history.formatTimeframe(
                              history.history.timeframe,
                            ),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),

                      // Stop Loss
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Длительность:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          Text(
                            history.history.duration,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
