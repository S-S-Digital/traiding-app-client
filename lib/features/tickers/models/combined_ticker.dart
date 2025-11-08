import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';

class CombinedTicker {
  final Assets assets;
  final List<Candles> candles;
  final Tickers tickers;

  CombinedTicker({
    required this.assets,
    required this.candles,
    required this.tickers,
  });

  // Фабричный метод
  factory CombinedTicker.fromSources({
    required Assets assets,
    required List<Candles> candles,
    required Tickers tickers,
  }) {
    return CombinedTicker(
      assets: assets,
      candles: candles,
      tickers: tickers,
    );
  }
}
