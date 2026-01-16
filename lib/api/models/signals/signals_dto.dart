import 'package:aspiro_trade/api/models/signals/indicators_dto.dart';
import 'package:aspiro_trade/api/models/signals/tickers_dto.dart';
import 'package:aspiro_trade/api/models/signals/webhook_payload_dto.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:json_annotation/json_annotation.dart';

part 'signals_dto.g.dart';

@JsonSerializable()
class SignalsDto  {
    const SignalsDto({
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

  final String id;
  final String? tickerId;
  final String symbol;
  final String timeframe;
  final String direction;
  final num? price;
  final DateTime? entryBarTime;
  final num? takeProfit;
  final num? stopLoss;
  final num? prevMove;
  final num? stochK;
  final num? stochD;
  final num? macd;
  final num? macdSignal;
  final num? macdHistogram;
  final num? ema50;
  final num? ema200;
  final num? atr;
  final num? volume;
  final num? volumeSma;
  final num? pivotHigh;
  final num? pivotLow;
  final String status;
  final num? closePrice;
  final String? closeReason;
  final DateTime? closedAt;
  final num? profitLoss;
  final num? profitLossPct;
  final WebhookPayloadDto? webhookPayload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final num currentPrice;
  final num progressPct;
  final double? profitPct;
  final num? profitUsd;
  final String? signalStatus;
  final IndicatorsDto? indicators;
  final TickersDto? ticker;



  factory SignalsDto.fromJson(Map<String, dynamic> json) =>
      _$SignalsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SignalsDtoToJson(this);

  Signals toEntity() => Signals(
    id: id,
    tickerId: tickerId ?? '',
    symbol: symbol,
    timeframe: timeframe,
    direction: direction,
    price: price ?? 0,
    entryBarTime: entryBarTime ?? DateTime.now(),
    takeProfit: takeProfit ?? 0,
    stopLoss: stopLoss ?? 0,
    prevMove: prevMove ?? 0,
    stochK: stochK ?? 0,
    stochD: stochD ?? 0,
    macd: macd ?? 0,
    macdSignal: macdSignal ?? 0,
    macdHistogram: macdHistogram ?? 0,
    ema50: ema50 ?? 0,
    ema200: ema200 ?? 0,
    atr: atr ?? 0,
    volume: volume ?? 0,
    volumeSma: volumeSma ?? 0,
    pivotHigh: pivotHigh ?? 0,
    pivotLow: pivotLow ?? 0,
    status: status,
    closePrice: closePrice ?? 0,
    closeReason: closeReason ?? '',
    closedAt: closedAt ?? DateTime.now(),
    profitLoss: profitLoss ?? 0,
    profitLossPct: profitLossPct ?? 0,
    webhookPayload: '',
    createdAt: createdAt,
    updatedAt: updatedAt,
    currentPrice: currentPrice,
    progressPct: progressPct,
    profitPct: profitPct ?? 0,
    profitUsd: profitUsd ?? 0,
    signalStatus: signalStatus ?? '',
    indicators: indicators?.toEntity(),
    ticker: ticker?.toEntity(),
  );

}
