import 'package:aspiro_trade/features/history/models/combined_history.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class PerformanceDashboard extends StatelessWidget {
  const PerformanceDashboard({
    super.key,
    required this.histories,
    required this.activePeriod,
    this.backendStats,
  });

  final List<CombinedHistory> histories;
  final String activePeriod;
  // Server-authoritative aggregate over all closed signals; used for the
  // all-time view so this card matches the Settings screen exactly.
  final Stats? backendStats;

  @override
  Widget build(BuildContext context) {
    // 1. Filter histories based on activePeriod
    final now = DateTime.now();
    final filtered = histories.where((h) {
      if (activePeriod == 'All') return true;
      if (activePeriod == 'Today') {
        final today = DateTime(now.year, now.month, now.day);
        final d = h.history.closedAt;
        return DateTime(d.year, d.month, d.day) == today;
      }
      if (activePeriod == '7d') {
        final cutoff = now.subtract(const Duration(days: 7));
        return h.history.closedAt.isAfter(cutoff);
      }
      return true;
    }).toList();

    // 2. Compute stats.
    // All-time view trusts the backend aggregate (every closed signal, not just
    // the loaded page). Period sub-views fold locally with a win predicate
    // aligned to the backend (resultPct > 0 strictly).
    final backend = backendStats;
    final int total;
    final int successful;
    final int winRate;
    final double roundedProfit;
    if (activePeriod == 'All' && backend != null) {
      total = backend.totalSignals.toInt();
      successful = backend.successfulSignals.toInt();
      winRate = backend.winRate.round();
      roundedProfit = (backend.totalProfit.toDouble() * 100).round() / 100;
    } else {
      total = filtered.length;
      successful = filtered.where((h) => h.history.resultPct > 0).length;
      winRate = total > 0 ? (successful / total * 100).round() : 0;
      final totalProfit = filtered.fold<double>(
          0, (sum, h) => sum + h.history.resultPct.toDouble());
      roundedProfit = (totalProfit * 100).round() / 100;
    }
    final lost = total - successful;

    final isProfit = roundedProfit >= 0;
    final trendColor = isProfit ? AppColors.up : AppColors.down;

    // Period Title Translation Helper
    String getPeriodTitle() {
      switch (activePeriod) {
        case 'Today':
          return AppLocalizations.todaysPerformance;
        case '7d':
          return AppLocalizations.sevenDaysPerformance;
        case 'All':
        default:
          return AppLocalizations.allTimePerformance;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isProfit
              ? [
                  const Color(0xFF132F22), // Deep Forest Green
                  AppColors.card,
                ]
              : [
                  const Color(0xFF33161A), // Deep Wine/Red
                  AppColors.card,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: trendColor.withOpacity(0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: trendColor.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getPeriodTitle(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isProfit ? AppLocalizations.profitWord : AppLocalizations.lossWord,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: trendColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content columns
          Row(
            children: [
              // PNL Display
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.totalReturn,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Icon(
                            isProfit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            color: trendColor,
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isProfit ? '+' : ''}${roundedProfit.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: trendColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // USD return removed to show percent-only profit
                    const SizedBox(height: 0),
                  ],
                ),
              ),

              // Vertical divider
              Container(
                height: 64,
                width: 1,
                color: AppColors.border.withOpacity(0.5),
              ),
              const SizedBox(width: 20),

              // Win Rate Display
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // Radial winrate circle
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 58,
                          height: 58,
                          child: CircularProgressIndicator(
                            value: winRate / 100,
                            strokeWidth: 5,
                            backgroundColor: AppColors.border.withOpacity(0.8),
                            valueColor: AlwaysStoppedAnimation<Color>(trendColor),
                          ),
                        ),
                        Text(
                          '$winRate%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Winrate text stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.winRate,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textTertiary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$winRate% ${AppLocalizations.winWord}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$successful ${AppLocalizations.wWord} • $lost ${AppLocalizations.lWord}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
