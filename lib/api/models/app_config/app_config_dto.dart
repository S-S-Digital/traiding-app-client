/// Server-driven app configuration (`GET /app-config`).
///
/// This is the single source of truth for what markets / assets / strategies /
/// features are live. It is **public** (no auth) and contains ONLY display
/// metadata + boolean flags — never secrets, thresholds or pair-selection
/// logic. See `.team-output/SERVER_DRIVEN_CONTRACT.md`.
///
/// DTOs are hand-parsed (no json_serializable / build_runner) on purpose: the
/// repo's codegen toolchain has a known realm⇄build_runner version conflict,
/// and this payload is small + fetched via a plain Dio GET, so hand parsing is
/// both lower-risk and dependency-free. Parsing is defensive: every field has a
/// sane fallback so a malformed/partial payload can never crash the app.
library;

class AppConfigDto {
  const AppConfigDto({
    required this.meta,
    required this.markets,
    required this.assets,
    required this.strategies,
    required this.features,
  });

  final ConfigMetaDto meta;
  final List<MarketDto> markets;
  final List<AssetConfigDto> assets;
  final List<StrategyConfigDto> strategies;

  /// Global feature flags. Unknown keys treated as `false` by callers; a
  /// missing known key falls back to its current product default.
  final Map<String, bool> features;

  factory AppConfigDto.fromJson(Map<String, dynamic> json) {
    return AppConfigDto(
      meta: ConfigMetaDto.fromJson(_asMap(json['meta'])),
      markets: _asList(json['markets'])
          .map((e) => MarketDto.fromJson(_asMap(e)))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
      assets: _asList(json['assets'])
          .map((e) => AssetConfigDto.fromJson(_asMap(e)))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
      strategies: _asList(json['strategies'])
          .map((e) => StrategyConfigDto.fromJson(_asMap(e)))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
      features: _asFlags(json['features']),
    );
  }

  Map<String, dynamic> toJson() => {
        'meta': meta.toJson(),
        'markets': markets.map((e) => e.toJson()).toList(),
        'assets': assets.map((e) => e.toJson()).toList(),
        'strategies': strategies.map((e) => e.toJson()).toList(),
        'features': features,
      };

  // ----- convenience accessors (used by the UI gating layer) -----

  List<MarketDto> get enabledMarkets =>
      markets.where((m) => m.enabled).toList(growable: false);

  List<AssetConfigDto> get enabledAssets =>
      assets.where((a) => a.enabled).toList(growable: false);

  List<StrategyConfigDto> get enabledStrategies =>
      strategies.where((s) => s.enabled).toList(growable: false);

  AssetConfigDto? assetFor(String symbol) {
    final up = symbol.toUpperCase();
    for (final a in assets) {
      if (a.symbol.toUpperCase() == up) return a;
    }
    return null;
  }

  MarketDto? marketById(String id) {
    for (final m in markets) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// Resolve a symbol → its asset's market → that market's [MarketDto.liveData].
  /// Returns null when the symbol/asset/market isn't found in config (caller
  /// should fall back to its own heuristic). Used to decide whether the signal
  /// card shows a live price slider vs static Entry/SL/TP.
  bool? liveDataFor(String symbol) {
    final asset = assetFor(symbol);
    if (asset == null) return null;
    return marketById(asset.market)?.liveData;
  }

  /// Feature flag lookup. Missing key ⇒ [fallback] (product default).
  bool feature(String key, {bool fallback = false}) =>
      features[key] ?? fallback;
}

class ConfigMetaDto {
  const ConfigMetaDto({
    required this.configVersion,
    required this.minAppVersion,
    required this.refreshSec,
    required this.generatedAt,
  });

  final int configVersion;
  final String minAppVersion;
  final int refreshSec;
  final String? generatedAt;

  factory ConfigMetaDto.fromJson(Map<String, dynamic> json) => ConfigMetaDto(
        configVersion: _asInt(json['configVersion'], 1),
        minAppVersion: _asString(json['minAppVersion'], '0.0.0'),
        refreshSec: _asInt(json['refreshSec'], 900),
        generatedAt: json['generatedAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'configVersion': configVersion,
        'minAppVersion': minAppVersion,
        'refreshSec': refreshSec,
        'generatedAt': generatedAt,
      };
}

class MarketDto {
  const MarketDto({
    required this.id,
    required this.name,
    required this.enabled,
    required this.order,
    required this.icon,
    required this.liveData,
  });

  final String id;
  final String name;
  final bool enabled;
  final int order;
  final String? icon;

  /// Whether this market has a live price feed (crypto today). Drives the
  /// signal card's live-slider vs static display. Missing key ⇒ false.
  final bool liveData;

  factory MarketDto.fromJson(Map<String, dynamic> json) => MarketDto(
        id: _asString(json['id'], ''),
        name: _asString(json['name'], ''),
        enabled: _asBool(json['enabled'], false),
        order: _asInt(json['order'], 0),
        icon: json['icon'] as String?,
        liveData: _asBool(json['liveData'], false),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'enabled': enabled,
        'order': order,
        'icon': icon,
        'liveData': liveData,
      };
}

class AssetConfigDto {
  const AssetConfigDto({
    required this.symbol,
    required this.market,
    required this.display,
    required this.priceDecimals,
    required this.enabled,
    required this.order,
    required this.session,
    required this.icon,
  });

  final String symbol;
  final String market;
  final String display;

  /// OVERRIDE only. `null` ⇒ client falls back to magnitude-aware formatting
  /// (today's behavior — no regression for any coin).
  final int? priceDecimals;
  final bool enabled;
  final int order;
  final String session;
  final String? icon;

  factory AssetConfigDto.fromJson(Map<String, dynamic> json) => AssetConfigDto(
        symbol: _asString(json['symbol'], ''),
        market: _asString(json['market'], ''),
        display: _asString(json['display'], _asString(json['symbol'], '')),
        priceDecimals: _asIntOrNull(json['priceDecimals']),
        enabled: _asBool(json['enabled'], false),
        order: _asInt(json['order'], 0),
        session: _asString(json['session'], '24/7'),
        icon: json['icon'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'market': market,
        'display': display,
        'priceDecimals': priceDecimals,
        'enabled': enabled,
        'order': order,
        'session': session,
        'icon': icon,
      };
}

class StrategyConfigDto {
  const StrategyConfigDto({
    required this.id,
    required this.name,
    required this.description,
    required this.timeframe,
    required this.enabled,
    required this.isDefault,
    required this.markets,
    required this.stats,
    required this.order,
  });

  /// MUST equal the backend StrategyMode key for quality/turnover — the client
  /// keeps sending this id to `PUT /users/strategy-mode`. Never rename.
  final String id;
  final String name;
  final String? description;
  final String timeframe;
  final bool enabled;
  final bool isDefault;
  final List<String> markets;
  final StrategyStatsDto? stats;
  final int order;

  factory StrategyConfigDto.fromJson(Map<String, dynamic> json) =>
      StrategyConfigDto(
        id: _asString(json['id'], ''),
        name: _asString(json['name'], ''),
        description: json['description'] as String?,
        timeframe: _asString(json['timeframe'], '15m'),
        enabled: _asBool(json['enabled'], false),
        // backend key may be `default` or `isDefault`
        isDefault: _asBool(json['default'] ?? json['isDefault'], false),
        markets: _asList(json['markets'])
            .map((e) => e.toString())
            .toList(growable: false),
        stats: json['stats'] == null
            ? null
            : StrategyStatsDto.fromJson(_asMap(json['stats'])),
        order: _asInt(json['order'], 0),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'timeframe': timeframe,
        'enabled': enabled,
        'default': isDefault,
        'markets': markets,
        'stats': stats?.toJson(),
        'order': order,
      };
}

class StrategyStatsDto {
  const StrategyStatsDto({
    required this.tradesPerMonth,
    required this.tradesPer90d,
    required this.winRatePct,
    required this.profitFactor,
    required this.maxDrawdownPct,
    required this.returnPct,
    required this.equity,
  });

  final int tradesPerMonth;
  final int tradesPer90d;
  final double winRatePct;
  final double profitFactor;
  final double maxDrawdownPct;
  final double returnPct;
  final List<double> equity;

  factory StrategyStatsDto.fromJson(Map<String, dynamic> json) =>
      StrategyStatsDto(
        tradesPerMonth: _asInt(json['tradesPerMonth'], 0),
        tradesPer90d: _asInt(json['tradesPer90d'], 0),
        winRatePct: _asDouble(json['winRatePct'], 0),
        profitFactor: _asDouble(json['profitFactor'], 0),
        maxDrawdownPct: _asDouble(json['maxDrawdownPct'], 0),
        returnPct: _asDouble(json['returnPct'], 0),
        equity: _asList(json['equity'])
            .map((e) => _asDouble(e, 0))
            .toList(growable: false),
      );

  Map<String, dynamic> toJson() => {
        'tradesPerMonth': tradesPerMonth,
        'tradesPer90d': tradesPer90d,
        'winRatePct': winRatePct,
        'profitFactor': profitFactor,
        'maxDrawdownPct': maxDrawdownPct,
        'returnPct': returnPct,
        'equity': equity,
      };
}

// ----------------------- defensive parse helpers -----------------------

Map<String, dynamic> _asMap(dynamic v) =>
    v is Map ? v.map((k, val) => MapEntry(k.toString(), val)) : <String, dynamic>{};

List<dynamic> _asList(dynamic v) => v is List ? v : const [];

Map<String, bool> _asFlags(dynamic v) {
  if (v is! Map) return <String, bool>{};
  final out = <String, bool>{};
  v.forEach((k, val) => out[k.toString()] = _asBool(val, false));
  return out;
}

String _asString(dynamic v, String fallback) => v is String ? v : fallback;

bool _asBool(dynamic v, bool fallback) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.toLowerCase() == 'true';
  return fallback;
}

int _asInt(dynamic v, int fallback) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

int? _asIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

double _asDouble(dynamic v, double fallback) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}
