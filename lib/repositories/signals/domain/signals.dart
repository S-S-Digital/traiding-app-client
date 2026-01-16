import 'package:aspiro_trade/repositories/signals/signals.dart';

class Signals {
  Signals({
    required this.id,
    required this.tickerId,
    required this.symbol,
    required this.timeframe,
    required this.direction,
    required this.price,
    required this.entryBarTime,
    required this.takeProfit,
    required this.stopLoss,
    required this.prevMove,
    required this.stochK,
    required this.stochD,
    required this.macd,
    required this.macdSignal,
    required this.macdHistogram,
    required this.ema50,
    required this.ema200,
    required this.atr,
    required this.volume,
    required this.volumeSma,
    required this.pivotHigh,
    required this.pivotLow,
    required this.status,
    required this.closePrice,
    required this.closeReason,
    required this.closedAt,
    required this.profitLoss,
    required this.profitLossPct,
    required this.webhookPayload,
    required this.createdAt,
    required this.updatedAt,
    required this.currentPrice,
    required this.progressPct,
    required this.profitPct,
    required this.profitUsd,
    required this.signalStatus,
    required this.indicators,
    required this.ticker,
  });

  Signals copyWith({
    String? id,
    String? tickerId,
    String? symbol,
    String? timeframe,
    String? direction,
    double? price,
    DateTime? entryBarTime,
    double? takeProfit,
    double? stopLoss,
    double? prevMove,
    double? stochK,
    double? stochD,
    double? macd,
    double? macdSignal,
    double? macdHistogram,
    double? ema50,
    double? ema200,
    double? atr,
    double? volume,
    double? volumeSma,
    double? pivotHigh,
    double? pivotLow,
    String? status,
    double? closePrice,
    String? closeReason,
    DateTime? closedAt,
    double? profitLoss,
    double? profitLossPct,
    String? webhookPayload,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? currentPrice,
    double? progressPct,
    double? profitPct,
    double? profitUsd,
    String? signalStatus,
    Indicator? indicators,
    Tickers? ticker,
  }) {
    return Signals(
      id: id ?? this.id,
      tickerId: tickerId ?? this.tickerId,
      symbol: symbol ?? this.symbol,
      timeframe: timeframe ?? this.timeframe,
      direction: direction ?? this.direction,
      price: price ?? this.price,
      entryBarTime: entryBarTime ?? this.entryBarTime,
      takeProfit: takeProfit ?? this.takeProfit,
      stopLoss: stopLoss ?? this.stopLoss,
      prevMove: prevMove ?? this.prevMove,
      stochK: stochK ?? this.stochK,
      stochD: stochD ?? this.stochD,
      macd: macd ?? this.macd,
      macdSignal: macdSignal ?? this.macdSignal,
      macdHistogram: macdHistogram ?? this.macdHistogram,
      ema50: ema50 ?? this.ema50,
      ema200: ema200 ?? this.ema200,
      atr: atr ?? this.atr,
      volume: volume ?? this.volume,
      volumeSma: volumeSma ?? this.volumeSma,
      pivotHigh: pivotHigh ?? this.pivotHigh,
      pivotLow: pivotLow ?? this.pivotLow,
      status: status ?? this.status,
      closePrice: closePrice ?? this.closePrice,
      closeReason: closeReason ?? this.closeReason,
      closedAt: closedAt ?? this.closedAt,
      profitLoss: profitLoss ?? this.profitLoss,
      profitLossPct: profitLossPct ?? this.profitLossPct,
      webhookPayload: webhookPayload ?? this.webhookPayload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentPrice: currentPrice ?? this.currentPrice,
      progressPct: progressPct ?? this.progressPct,
      profitPct: profitPct ?? this.profitPct,
      profitUsd: profitUsd ?? this.profitUsd,
      signalStatus: signalStatus ?? this.signalStatus,
      indicators: indicators ?? this.indicators,
      ticker: ticker ?? this.ticker,
    );
  }

  final String id;
  final String tickerId;
  final String symbol;
  final String timeframe;
  final String direction;
  final num price;
  final DateTime entryBarTime;
  final num takeProfit;
  final num stopLoss;
  final num prevMove;
  final num stochK;
  final num stochD;
  final num macd;
  final num macdSignal;
  final num macdHistogram;
  final num ema50;
  final num ema200;
  final num atr;
  final num volume;
  final num volumeSma;
  final num pivotHigh;
  final num pivotLow;
  final String status;
  final num closePrice;
  final String closeReason;
  final DateTime closedAt;
  final num profitLoss;
  final num profitLossPct;
  final String webhookPayload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final num currentPrice;
  final num progressPct;
  final num profitPct;
  final num profitUsd;
  final String signalStatus;
  final Indicator? indicators;
  final Tickers? ticker;

  String getDirection(String value) =>
      value.toLowerCase().contains('buy') ? 'Покупка' : 'Продажа';


  String formatTimeframe(String timeframe) {
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
