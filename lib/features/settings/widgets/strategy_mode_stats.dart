import 'package:aspiro_trade/api/models/app_config/app_config_dto.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Backtest stats for a strategy mode — now SERVER-OWNED.
///
/// The numbers (trades/month, WR, PF, drawdown, equity curve) are no longer
/// hardcoded in Dart: they are sourced from `GET /app-config`'s `strategies[]`
/// (see [StrategyConfigDto.stats]). They are still never recomputed at
/// runtime — the product owner wants them baked, just baked in the DB so
/// they're editable without an app release. With crypto-only enabled the
/// server ships the exact same figures the app used to hardcode, so the panel
/// renders identically.
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
  final double winRatePct;
  final double profitFactor;
  final double maxDrawdownPct;
  final String explanation;

  /// Equity curve starting at $1000 (points over the 90d backtest window).
  final List<double> equity;
  final Color color;

  static const double startEquity = 1000;

  /// Build a display model from a server strategy entry. [explanation] is the
  /// plain-language blurb (localized for known modes, falling back to the
  /// server `description`); [color] tints the chart/accent. Returns null when
  /// the strategy has no stats (e.g. a work-in-progress mode) ⇒ no panel.
  static StrategyModeStats? fromConfig(
    StrategyConfigDto strategy, {
    required String explanation,
    required Color color,
  }) {
    final s = strategy.stats;
    if (s == null) return null;
    return StrategyModeStats(
      tradesPerMonth: s.tradesPerMonth,
      tradesPer90d: s.tradesPer90d,
      winRatePct: s.winRatePct,
      profitFactor: s.profitFactor,
      maxDrawdownPct: s.maxDrawdownPct,
      explanation: explanation,
      equity: s.equity.isEmpty ? const [startEquity, startEquity] : s.equity,
      color: color,
    );
  }
}

/// Explanation + static stats grid + equity sparkline for a single mode.
class StrategyModeStatsPanel extends StatelessWidget {
  const StrategyModeStatsPanel({super.key, required this.stats});

  final StrategyModeStats stats;

  @override
  Widget build(BuildContext context) {
    final endPct =
        (stats.equity.last - StrategyModeStats.startEquity) /
            StrategyModeStats.startEquity *
            100;
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
                value: '${stats.winRatePct.toStringAsFixed(1)}%',
                color: AppColors.brand,
              ),
              _StatCell(
                label: AppLocalizations.strategyModeStatPf,
                value: stats.profitFactor.toStringAsFixed(2),
                color: AppColors.brand,
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
                '\$1000 → \$${stats.equity.last.round()}  (+${endPct.toStringAsFixed(1)}%)',
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
