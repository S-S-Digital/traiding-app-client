import 'package:aspiro_trade/features/tickers/models/models.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class TickersItem extends StatelessWidget {
  const TickersItem({
    super.key,
    required this.tickers,
    required this.onSwipe,
    required this.onEdit,
  });

  final CombinedTicker tickers;
  final VoidCallback onSwipe;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isNegative = tickers.assets.change24h.startsWith('-');

    return Dismissible(
      key: ValueKey(tickers.tickers.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.down.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        onSwipe.call();
        return false;
      },
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    tickers.assets.logoUrl,
                    width: 40, height: 40, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        tickers.tickers.symbol.isNotEmpty ? tickers.tickers.symbol[0] : '?',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + symbol
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tickers.assets.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          tickers.tickers.symbol,
                          style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.elevated,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            tickers.tickers.timeframe.toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textTertiary),
                          ),
                        ),
                        // Signal indicator
                        if (tickers.signals != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: tickers.signals!.direction.contains('buy') ? AppColors.up : AppColors.down,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Price + change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tickers.assets.formatPriceLogic(tickers.assets.price),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isNegative ? AppColors.down.withValues(alpha: 0.12) : AppColors.up.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${isNegative ? '' : '+'}${tickers.assets.formatPriceLogic(tickers.assets.priceChangePercent)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isNegative ? AppColors.down : AppColors.up,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
