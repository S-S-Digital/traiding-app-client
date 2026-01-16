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


    String get formatTimeframe{
    switch (timeframe) {
      case '15m':
        return '15 минут';
      case '1h':
        return '1 час';
      case '1d':
        return '1 день';
      case '1w':
        return '1 неделя';
      case '1M':
        return '1 месяц';
      default:
        return timeframe; 
    }
  }

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