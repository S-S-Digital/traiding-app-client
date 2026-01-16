class Tickers {
  Tickers({required this.symbol, required this.timeframe});
  final String symbol;
  final String timeframe;

  factory Tickers.empty() =>  Tickers(symbol: '', timeframe: '');
}
