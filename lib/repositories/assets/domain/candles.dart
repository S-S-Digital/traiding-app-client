class Candles {
  Candles({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.closeTime,
    required this.quoteAssetVolume,
    required this.numberOfTrades,
    required this.takerBuyBaseAssetVolume,
    required this.takerBuyQuoteAssetVolume,
  });

  
  final int openTime;
  final String open;
  final String high;
  final String low;
  final String close;
  final String volume;
  final int closeTime;
  final String quoteAssetVolume;
  final String numberOfTrades;
  final String takerBuyBaseAssetVolume;
  final String takerBuyQuoteAssetVolume;
}
