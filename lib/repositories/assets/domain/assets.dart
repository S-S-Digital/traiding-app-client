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
}
