import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// STATIC backtest stats for a strategy mode.
///
/// These numbers are hardcoded (honest backtest, ~90 days, no commission) and
/// are NEVER recomputed at runtime — the product owner explicitly wants them
/// baked. The equity curve is illustrative: a smooth ascending line from $1000.
class StrategyModeStats {
  const StrategyModeStats({
    required this.tradesPerMonth,
    required this.tradesPer90d,
    required this.winRatePct,
    required this.profitFactor,
    required this.maxDrawdownPct,
    required this.explanation,
    required this.equity,
    required this.color,
  });

  final int tradesPerMonth;
  final int tradesPer90d;
  final int winRatePct;
  final double profitFactor;
  final int maxDrawdownPct;
  final String explanation;

  /// Illustrative equity curve starting at $1000 (13 points over 90 days).
  final List<double> equity;
  final Color color;

  static const double startEquity = 1000;

  /// Quality: fewer/cleaner trades, ends ~+30% (~\$1300 at 90d).
  static StrategyModeStats get quality => StrategyModeStats(
        tradesPerMonth: 26,
        tradesPer90d: 78,
        winRatePct: 61,
        profitFactor: 1.53,
        maxDrawdownPct: 24,
        explanation: AppLocalizations.strategyModeQualityExplain,
        color: AppColors.brand,
        equity: const [
          1000, 1015, 1040, 1030, 1070, 1100, 1095, 1140, 1175, 1160, 1210,
          1255, 1300,
        ],
      );

  /// Turnover: more trades, ends ~+40% (~\$1400 at 90d), bumpier curve.
  static StrategyModeStats get turnover => StrategyModeStats(
        tradesPerMonth: 61,
        tradesPer90d: 183,
        winRatePct: 65,
        profitFactor: 1.54,
        maxDrawdownPct: 37,
        explanation: AppLocalizations.strategyModeTurnoverExplain,
        color: AppColors.brandLight,
        equity: const [
          1000, 1025, 1010, 1060, 1110, 1095, 1150, 1200, 1185, 1250, 1310,
          1360, 1400,
        ],
      );

  static StrategyModeStats forMode(String modeKey) =>
      modeKey == StrategyMode.turnoverKey ? turnover : quality;
}

/// Explanation + static stats grid + equity sparkline for a single mode.
class StrategyModeStatsPanel extends StatelessWidget {
  const StrategyModeStatsPanel({super.key, required this.stats});

  final StrategyModeStats stats;

  @override
  Widget build(BuildContext context) {
    final endPct =
        ((stats.equity.last - StrategyModeStats.startEquity) /
                StrategyModeStats.startEquity *
                100)
            .round();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // (a) plain-language explanation
          Text(
            stats.explanation,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // backtest period label
          Row(
            children: [
              const Icon(Icons.history, size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 5),
              Text(
                AppLocalizations.strategyModeBacktestLabel,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // (b) key stats
          Row(
            children: [
              _StatCell(
                label: AppLocalizations.strategyModeStatTrades,
                value: '${stats.tradesPerMonth}',
                sub: '~${stats.tradesPer90d}/90д',
                color: AppColors.textPrimary,
              ),
              _StatCell(
                label: AppLocalizations.strategyModeStatWinrate,
                value: '${stats.winRatePct}%',
                color: AppColors.brand,
              ),
              _StatCell(
                label: AppLocalizations.strategyModeStatPf,
                value: stats.profitFactor.toStringAsFixed(2),
                color: AppColors.brand,
              ),
              _StatCell(
                label: AppLocalizations.strategyModeStatMaxDd,
                value: '${stats.maxDrawdownPct}%',
                color: AppColors.down,
              ),
            ],
          ),
          const SizedBox(height: 14),
          // (c) equity-growth chart from $1000
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.strategyModeChartAxis,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                '\$1000 → \$${stats.equity.last.round()}  (+$endPct%)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: stats.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(height: 64, child: _EquityChart(stats: stats)),
          const SizedBox(height: 8),
          // disclaimer
          Text(
            AppLocalizations.strategyModeDisclaimer,
            style: const TextStyle(
              fontSize: 9.5,
              height: 1.3,
              fontStyle: FontStyle.italic,
              color: AppColors.textQuaternary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
    this.sub,
  });

  final String label;
  final String value;
  final String? sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 1),
            Text(
              sub!,
              style: const TextStyle(
                fontSize: 8.5,
                color: AppColors.textQuaternary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EquityChart extends StatelessWidget {
  const _EquityChart({required this.stats});

  final StrategyModeStats stats;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < stats.equity.length; i++)
        FlSpot(i.toDouble(), stats.equity[i]),
    ];
    final ys = stats.equity;
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.12;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        minX: 0,
        maxX: (stats.equity.length - 1).toDouble(),
        minY: minY - pad,
        maxY: maxY + pad,
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            curveSmoothness: 0.28,
            color: stats.color,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  stats.color.withValues(alpha: 0.28),
                  stats.color.withValues(alpha: 0.0),
                ],
              ),
            ),
            spots: spots,
          ),
        ],
      ),
    );
  }
}
