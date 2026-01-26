import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart' as signal;
import 'package:aspiro_trade/repositories/tickers/tickers.dart';

class CombinedTicker {
  final Assets assets;
  final Tickers tickers;
  final signal.Signals? signals;

  CombinedTicker({required this.assets, required this.tickers, this.signals});

  factory CombinedTicker.fromSources({
    required Assets assets,
    required signal.Signals? signals,
    required Tickers tickers,
  }) {
    return CombinedTicker(assets: assets, tickers: tickers, signals: signals);
  }

  factory CombinedTicker.empty() {
    return CombinedTicker(assets: Assets.empty(), tickers: Tickers.empty());
  }

  static const _sentinel = Object();

  CombinedTicker copyWith({
    Assets? assets,
    Tickers? tickers,
    Object? signals = _sentinel, // ключевой момент
  }) {
    return CombinedTicker(
      assets: assets ?? this.assets,
      tickers: tickers ?? this.tickers,
      signals: signals == _sentinel
          ? this
                .signals // оставить как есть
          : signals as signal.Signals?, // заменить или поставить null
    );
  }
}
