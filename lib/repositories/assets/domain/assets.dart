// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  String formatPriceLogic(String value) {
    final number = double.tryParse(value) ?? 0;
    final parts = number.toString().split('.');

    if (parts.length == 1) {
      // Целое число
      return parts[0];
    }

    final integerPart = parts[0];
    var decimalPart = parts[1];

    // Если после запятой меньше 3 цифр, оставляем как есть
    if (decimalPart.length <= 3) {
      return '$integerPart.$decimalPart';
    }

    // Берём первые три цифры
    String firstThree = decimalPart.substring(0, 3);

    // Решаем, добавлять ли четвёртую
    if (decimalPart.length > 3 && int.parse(decimalPart[2]) >= 5) {
      firstThree += decimalPart[3]; // добавляем четвёртую цифру
    }

    return '$integerPart.$firstThree';
  }

  String get formatPercent {
    // 1. Безопасное чтение данных
    final value = double.tryParse(priceChangePercent) ?? 0.0;

    if (value == 0) {
      return '0'; 
    }

    
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(3)}%';
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
