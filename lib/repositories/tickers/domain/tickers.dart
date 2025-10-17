import 'package:aspiro_trade/repositories/tickers/tickers.dart';

class Tickers {

  Tickers({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.timeframe,
    required this.notifyBuy,
    required this.notifySell,
    required this.isActive,
    required this.addedAt,
  });

  final String id;
  final String userId;
  final String symbol;
  final String timeframe;
  final bool notifyBuy;
  final bool notifySell;
  final bool isActive;
  final DateTime addedAt;

}


extension TickersLocalMapper on TickersLocal {
  Tickers toEntity() {
    return Tickers(
      id: id,
      userId: userId,
      symbol: symbol,
      timeframe: timeframe,
      notifyBuy: notifyBuy,
      notifySell: notifySell,
      isActive: isActive,
      addedAt: addedAt,
    );
  }
}