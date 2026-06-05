import 'package:aspiro_trade/repositories/analytics/domain/asset_analytics.dart';

/// Manual (no codegen) DTOs for `GET /asset-analytics/today`. Follows the same
/// hand-written `fromJson` pattern as `MarketDigestDto` so we don't depend on
/// the conflicting build_runner toolchain.

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

List<double> _toDoubleList(dynamic v) {
  if (v is List) {
    return v
        .map(_toDouble)
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
  }
  return const [];
}

class AssetAnalyticsFeedDto {
  const AssetAnalyticsFeedDto({
    required this.date,
    required this.isLocked,
    required this.assets,
  });

  final String? date;
  final bool isLocked;
  final List<AssetAnalyticsDto> assets;

  factory AssetAnalyticsFeedDto.fromJson(Map<String, dynamic> json) {
    final rawAssets = json['assets'];
    return AssetAnalyticsFeedDto(
      date: json['date'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
      assets: rawAssets is List
          ? rawAssets
              .whereType<Map>()
              .map((e) =>
                  AssetAnalyticsDto.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  AssetAnalyticsFeed toEntity() => AssetAnalyticsFeed(
        date: date,
        isLocked: isLocked,
        assets: assets.map((e) => e.toEntity()).toList(),
      );
}

class AssetAnalyticsDto {
  const AssetAnalyticsDto({
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
  final String? trend;
  final String? regime;
  final double? adx;
  final double? atrPct;
  final Map<String, dynamic>? levels;
  final String narrative;
  final List<Map<String, dynamic>> scenarios;
  final String? sentiment;
  final bool? signalsLikely;
  final bool isLocked;

  factory AssetAnalyticsDto.fromJson(Map<String, dynamic> json) {
    final rawScenarios = json['scenarios'];
    return AssetAnalyticsDto(
      asset: json['asset'] as String? ?? '',
      price: _toDouble(json['price']) ?? 0,
      trend: json['trend'] as String?,
      regime: json['regime'] as String?,
      adx: _toDouble(json['adx']),
      atrPct: _toDouble(json['atrPct']),
      levels: json['levels'] is Map
          ? Map<String, dynamic>.from(json['levels'] as Map)
          : null,
      narrative: json['narrative'] as String? ?? '',
      scenarios: rawScenarios is List
          ? rawScenarios
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : const [],
      sentiment: json['sentiment'] as String?,
      signalsLikely: json['signalsLikely'] as bool?,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }

  AssetAnalytics toEntity() => AssetAnalytics(
        asset: asset,
        price: price,
        trend: trend,
        regime: regime,
        adx: adx,
        atrPct: atrPct,
        levels: levels == null
            ? null
            : AnalyticsLevels(
                support: _toDoubleList(levels!['support']),
                resistance: _toDoubleList(levels!['resistance']),
                ema50: _toDouble(levels!['ema50']),
                ema200: _toDouble(levels!['ema200']),
                change24hPct: _toDouble(levels!['change24hPct']),
              ),
        narrative: narrative,
        scenarios: scenarios
            .map((s) => AnalyticsScenario(
                  type: s['type']?.toString() ?? '',
                  condition: s['condition']?.toString() ?? '',
                  target: s['target']?.toString() ?? '',
                ))
            .toList(),
        sentiment: sentiment,
        signalsLikely: signalsLikely,
        isLocked: isLocked,
      );
}
