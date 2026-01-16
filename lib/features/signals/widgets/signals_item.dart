
import 'package:aspiro_trade/features/signals/models/models.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:flutter/material.dart';

class SignalsItem extends StatelessWidget {
  const SignalsItem({super.key, required this.signal});

  final CombinedSignal signal;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isBuy = signal.signal.direction.toLowerCase() == 'buy';
    final priceChange = signal.signal.currentPrice - signal.signal.price;
    final priceChangePct = (priceChange / signal.signal.price) * 100;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: size.height * 0.2,
          maxHeight: size.height * 0.6,
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isBuy
                          ? theme.colorScheme.secondary.withValues(alpha: 0.25)
                          : theme.colorScheme.error.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      signal.signal.getDirection(signal.signal.direction),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isBuy
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    // Можно форматировать дату entryBarTime
                    TimeOfDay.fromDateTime(
                      signal.signal.entryBarTime,
                    ).format(context),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),

              // Crypto info
              CryptoListTile(
                imagePath: signal.assets.logoUrl,
                title: signal.assets.symbol,
                subtitle: '',
                size: CryptoListTileSize.medium,
              ),

              // Prices info
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height * 0.05,
                  maxHeight: size.height * 0.3,
                ),
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor.withValues(alpha:  0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 5,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Текущая цена:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${signal.signal.currentPrice.toStringAsFixed(2)}\$',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Цена входа:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${signal.signal.price.toStringAsFixed(2)}\$',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Тейк-профит',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${signal.signal.takeProfit.toStringAsFixed(2)}\$',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Стоп-лосс',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${signal.signal.stopLoss.toStringAsFixed(2)}\$',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Изменение:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${priceChangePct >= 0 ? '+' : ''}${priceChangePct.toStringAsFixed(2)}% (${priceChange.toStringAsFixed(2)}\$)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: priceChange >= 0
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Таймфрейм:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              signal.signal.formatTimeframe(signal.signal.timeframe),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
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
