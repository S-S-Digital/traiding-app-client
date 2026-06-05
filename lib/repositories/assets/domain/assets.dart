// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:aspiro_trade/repositories/assets/realm/assets_local.dart';
import 'package:aspiro_trade/utils/methods/price_formatter.dart';

class Assets {
  Assets({
    required this.symbol,
    required this.name,
    required this.baseAsset,
    required this.quoteAsset,
    required this.price,
    required this.change24h,
    required this.logoUrl,
    required this.volume24h,
    required this.high24h,
    required this.low24h,
    required this.priceChangePercent,
  });

  Assets copyWith({
    String? symbol,
    String? name,
    String? baseAsset,
    String? quoteAsset,
    String? price,
    String? change24h,
    String? logoUrl,
    String? volume24h,
    String? high24h,
    String? low24h,
    String? priceChangePercent,
  }) {
    return Assets(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      baseAsset: baseAsset ?? this.baseAsset,
      quoteAsset: quoteAsset ?? this.quoteAsset,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
      logoUrl: logoUrl ?? this.logoUrl,
      volume24h: volume24h ?? this.volume24h,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      priceChangePercent: priceChangePercent ?? this.priceChangePercent,
    );
  }

  final String symbol;
  final String name;
  final String baseAsset;
  final String quoteAsset;
  final String price;
  final String change24h;
  final String logoUrl;
  final String volume24h;
  final String high24h;
  final String low24h;
  final String priceChangePercent;

  Assets.empty([String defaultSymbol = ''])
    : symbol = defaultSymbol,
      name = 'N/A',
      baseAsset = '',
      quoteAsset = '',
      price = '0',
      change24h = '0',
      logoUrl = '',
      volume24h = '0',
      high24h = '0',
      low24h = '0',
      priceChangePercent = '0';

  /// Magnitude-aware price string with thousands grouping. Replaces the old
  /// ad-hoc 3rd/4th-decimal logic that printed sub-dollar coins as `0.000`
  /// (audit M9). Decimals scale from the price magnitude.
  String formatPriceLogic(String value) {
    final number = double.tryParse(value) ?? 0;
    return PriceFormatter.price(number);
  }

  /// Signed percent, 2 decimals, locale-neutral (audit M10).
  String get formatPercent {
    final value = double.tryParse(priceChangePercent) ?? 0.0;
    if (value == 0) return '0';
    return PriceFormatter.percent(value);
  }
}

extension AssetsExtension on Assets {
  /// Возвращает "пустой" объект Assets с дефолтными значениями
  static Assets empty(String symbol) => Assets(
    symbol: symbol,
    name: '',
    baseAsset: '',
    quoteAsset: '',
    price: '0',
    change24h: '0',
    logoUrl: '',
    volume24h: '0',
    high24h: '0',
    low24h: '0',
    priceChangePercent: '0',
  );
}

extension AssetsLocalMapper on AssetsLocal {
  Assets toEntity() {
    return Assets(
      symbol: symbol,
      name: name,
      baseAsset: baseAsset,
      quoteAsset: quoteAsset,
      price: price,
      change24h: change24h,
      logoUrl: logoUrl,
      volume24h: '0',
      high24h: '0',
      low24h: '0',
      priceChangePercent: change24h,
    );
  }
}
