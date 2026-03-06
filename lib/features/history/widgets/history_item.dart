import 'package:aspiro_trade/features/history/models/models.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {
  const HistoryItem({super.key, required this.history});

  final CombinedHistory history;

  String _closeReasonLabel() {
    final status = history.history.status.toLowerCase();
    if (status.contains('tp') || status.contains('won')) return 'Take Profit';
    if (status.contains('sl') || status.contains('lost')) return 'Stop Loss';
    return 'Closed';
  }

  @override
  Widget build(BuildContext context) {
    final isWin = history.history.status.toLowerCase().contains('won') ||
        history.history.status.toLowerCase().contains('tp') ||
        history.history.resultPct > 0;
    final isBuy = history.history.direction.toLowerCase() == 'buy';
    final resultPct = history.history.resultPct;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: isWin ? AppColors.up.withValues(alpha: 0.12) : AppColors.down.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isWin ? Icons.check : Icons.close,
              size: 16,
              color: isWin ? AppColors.up : AppColors.down,
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      history.history.symbol,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isBuy ? AppColors.up.withValues(alpha: 0.12) : AppColors.down.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        isBuy ? 'LONG' : 'SHORT',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isBuy ? AppColors.up : AppColors.down),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      history.history.timeframe.toUpperCase(),
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_closeReasonLabel()} • ${history.history.duration}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          // P&L %
          Text(
            '${resultPct > 0 ? '+' : ''}${resultPct.toStringAsFixed(2)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: resultPct >= 0 ? AppColors.up : AppColors.down,
            ),
          ),
        ],
      ),
    );
  }
}
