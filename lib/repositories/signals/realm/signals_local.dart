import 'package:aspiro_trade/repositories/signals/domain/signals.dart';
import 'package:realm/realm.dart';

part 'signals_local.realm.dart';

@RealmModel()
class _SignalsLocal {
  @PrimaryKey()
  late String id;
  late String symbol;
  late String direction; 
  late String price; 
  late String takeProfit; 
  late String stopLoss; 
  late String currentPrice; 
  late String progressPct; 
  late String profitPct; 
  late String profitUsd; 
  late String status;  
}

extension SignalsLocalExt on SignalsLocal {
  Signals toEntity() {
    return Signals(
      id: id,
      tickerId: '',
      symbol: symbol,
      timeframe: '1h',
      direction: direction,
      price: double.tryParse(price) ?? 0.0,
      entryBarTime: DateTime.now(),
      takeProfit: double.tryParse(takeProfit),
      stopLoss: double.tryParse(stopLoss),
      prevMove: 0.0,
      stochK: 0.0,
      stochD: 0.0,
      macd: 0.0,
      macdSignal: 0.0,
      macdHistogram: 0.0,
      ema50: 0.0,
      ema200: 0.0,
      atr: 0.0,
      volume: 0.0,
      volumeSma: 0.0,
      pivotHigh: 0.0,
      pivotLow: 0.0,
      status: status,
      closePrice: 0.0,
      closeReason: '',
      closedAt: DateTime.fromMillisecondsSinceEpoch(0),
      profitLoss: double.tryParse(profitUsd) ?? 0.0,
      profitLossPct: double.tryParse(profitPct) ?? 0.0,
      webhookPayload: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currentPrice: double.tryParse(currentPrice) ?? 0.0,
      progressPct: double.tryParse(progressPct) ?? 0.0,
      profitPct: double.tryParse(profitPct) ?? 0.0,
      profitUsd: double.tryParse(profitUsd) ?? 0.0,
      signalStatus: (double.tryParse(profitPct) ?? 0.0) >= 0.0 ? 'in_profit' : 'in_loss',
      indicators: null,
      ticker: null,
    );
  }
}