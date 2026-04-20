import 'package:aspiro_trade/features/signals/models/models.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class SignalsItem extends StatelessWidget {
  const SignalsItem({super.key, required this.signal});

  final CombinedSignal signal;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'at_tp':
      case 'in_profit':
        return AppColors.up;
      case 'at_sl':
      case 'in_loss':
        return AppColors.down;
      case 'unknown':
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = signal.signal.direction.toLowerCase() == 'buy';
    final profitPct = signal.signal.profitPct?.toDouble() ?? 0;
    final isProfit = profitPct >= 0;
    final isClosed = signal.signal.isClosed;

    final sl = signal.signal.stopLoss?.toDouble();
    final tp = signal.signal.takeProfit?.toDouble();
    final current = signal.signal.currentPrice?.toDouble();
    final entry = signal.signal.price.toDouble();

    // Progress bar: only if SL and TP are known
    final hasRange = sl != null && tp != null;
    double progress = 0.5;
    if (hasRange && current != null) {
      final range = (tp - sl).abs();
      progress = range > 0 ? ((current - sl).abs() / range).clamp(0.0, 1.0) : 0.5;
    }

    final statusColor = _statusColor(signal.signal.signalStatus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      signal.assets.logoUrl,
                      width: 36, height: 36, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          signal.signal.symbol.isNotEmpty ? signal.signal.symbol[0] : '?',
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Pair + pills
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        signal.signal.symbol,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _DirectionPill(isBuy: isBuy),
                          const SizedBox(width: 6),
                          _TimeframePill(timeframe: signal.signal.timeframe),
                          const SizedBox(width: 6),
                          if (isClosed)
                            _StatusPill(label: 'CLOSED', color: statusColor)
                          else
                            Text(
                              TimeOfDay.fromDateTime(signal.signal.entryBarTime).format(context),
                              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // P&L badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isProfit ? AppColors.up.withValues(alpha: 0.12) : AppColors.down.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${isProfit ? '+' : ''}${profitPct.toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isProfit ? AppColors.up : AppColors.down),
                  ),
                ),
              ],
            ),
          ),

          // ── Progress Bar (SL → TP) — only if both are available ──
          if (hasRange)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SL $sl', style: const TextStyle(fontSize: 11, color: AppColors.down, fontWeight: FontWeight.w500)),
                      Text('TP $tp', style: const TextStyle(fontSize: 11, color: AppColors.up, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.elevated,
                      valueColor: AlwaysStoppedAnimation<Color>(isProfit ? AppColors.up : AppColors.down),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SL —', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
                  Text('TP —', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // ── Grid: Entry / Current ──
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                _GridCell(label: 'Entry', value: '\$$entry', valueColor: AppColors.textPrimary),
                Container(width: 1, height: 32, color: AppColors.border),
                _GridCell(
                  label: isClosed ? 'Close' : 'Current',
                  value: current != null ? '\$$current' : '—',
                  valueColor: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionPill extends StatelessWidget {
  const _DirectionPill({required this.isBuy});
  final bool isBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isBuy ? AppColors.up.withValues(alpha: 0.15) : AppColors.down.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isBuy ? 'LONG' : 'SHORT',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isBuy ? AppColors.up : AppColors.down),
      ),
    );
  }
}


class _TimeframePill extends StatelessWidget {
  const _TimeframePill({required this.timeframe});
  final String timeframe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(4)),
      child: Text(
        timeframe.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.label, required this.value, required this.valueColor});
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor)),
        ],
      ),
    );
  }
}
