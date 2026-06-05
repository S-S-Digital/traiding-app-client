import 'package:aspiro_trade/features/history/models/models.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:aspiro_trade/utils/methods/price_formatter.dart';
import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {
  const HistoryItem({super.key, required this.history});

  final CombinedHistory history;

  String _closeReasonLabel() {
    final status = history.history.status.toLowerCase();
    if (status.contains('tp') || status.contains('won')) return AppLocalizations.takeProfit;
    if (status.contains('sl') || status.contains('lost')) return AppLocalizations.stopLoss;
    return AppLocalizations.closed;
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = history.history.direction.toLowerCase() == 'buy';
    final resultPct = history.history.resultPct;
    final directionColor = isBuy ? AppColors.up : AppColors.down;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        children: [
          // Direction indicator icon with subtle glow background
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: directionColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: directionColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              isBuy ? Icons.call_made_rounded : Icons.call_received_rounded,
              size: 16,
              color: directionColor,
            ),
          ),
          const SizedBox(width: 12),

          // Trade Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      history.history.symbol,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Direction Capsule (LONG/SHORT)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: directionColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: directionColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isBuy ? AppLocalizations.directionLong : AppLocalizations.directionShort,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: directionColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Timeframe Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.border.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        history.history.timeframe.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Prices: Entry -> Exit
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${AppLocalizations.inWord}: ${PriceFormatter.price(history.history.entry, withSymbol: true)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 9,
                      color: AppColors.textTertiary,
                    ),
                    Text(
                      '${AppLocalizations.outWord}: ${PriceFormatter.price(history.history.exit, withSymbol: true)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Close reason & Duration (duration is nullable — backend sends
                // null when createdAt/closedAt are missing)
                Text(
                  (history.history.duration ?? '').isEmpty
                      ? _closeReasonLabel()
                      : '${_closeReasonLabel()} • ${history.history.duration}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // P&L Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Percent Capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (resultPct >= 0 ? AppColors.up : AppColors.down).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: (resultPct >= 0 ? AppColors.up : AppColors.down).withOpacity(0.2),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${resultPct > 0 ? '+' : ''}${resultPct.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: resultPct >= 0 ? AppColors.up : AppColors.down,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
