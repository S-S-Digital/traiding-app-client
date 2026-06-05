// Domain models for the premium per-asset analytics feed
// (`GET /asset-analytics/today`, backend Task #3 / IMPL_ANALYTICS.md).

class AnalyticsLevels {
  const AnalyticsLevels({
    required this.support,
    required this.resistance,
    this.ema50,
    this.ema200,
    this.change24hPct,
  });

  final List<double> support;
  final List<double> resistance;
  final double? ema50;
  final double? ema200;
  final double? change24hPct;
}

class AnalyticsScenario {
  const AnalyticsScenario({
    required this.type,
    required this.condition,
    required this.target,
  });

  /// e.g. "bounce" | "breakout".
  final String type;
  final String condition;
  final String target;
}

class AssetAnalytics {
  const AssetAnalytics({
    required this.asset,
    required this.price,
    required this.trend,
    required this.regime,
    required this.adx,
    required this.atrPct,
    required this.levels,
    required this.narrative,
    required this.scenarios,
    required this.sentiment,
    required this.signalsLikely,
    required this.isLocked,
  });

  final String asset;
  final double price;

  /// "UP" | "DOWN" | "FLAT" — null in the locked teaser.
  final String? trend;

  /// "TREND" | "RANGE" — null in the locked teaser.
  final String? regime;
  final double? adx;
  final double? atrPct;
  final AnalyticsLevels? levels;
  final String narrative;
  final List<AnalyticsScenario> scenarios;

  /// "BULLISH" | "BEARISH" | "NEUTRAL" — null in the locked teaser.
  final String? sentiment;
  final bool? signalsLikely;
  final bool isLocked;
}

/// The whole envelope returned by `GET /asset-analytics/today`.
class AssetAnalyticsFeed {
  const AssetAnalyticsFeed({
    required this.date,
    required this.isLocked,
    required this.assets,
  });

  /// UTC "YYYY-MM-DD" day key; null when no data has been generated yet.
  final String? date;

  /// Top-level lock = the requesting user is not premium.
  final bool isLocked;
  final List<AssetAnalytics> assets;

  AssetAnalytics? forSymbol(String symbol) {
    final upper = symbol.toUpperCase();
    for (final a in assets) {
      if (a.asset.toUpperCase() == upper) return a;
    }
    return null;
  }
}
