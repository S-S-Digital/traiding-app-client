// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signals_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignalsDto _$SignalsDtoFromJson(Map<String, dynamic> json) => SignalsDto(
  id: json['id'] as String,
  tickerId: json['tickerId'] as String?,
  symbol: json['symbol'] as String,
  timeframe: json['timeframe'] as String,
  direction: json['direction'] as String,
  price: json['price'] as num?,
  entryBarTime: json['entryBarTime'] == null
      ? null
      : DateTime.parse(json['entryBarTime'] as String),
  takeProfit: json['takeProfit'] as num?,
  stopLoss: json['stopLoss'] as num?,
  prevMove: json['prevMove'] as num?,
  stochK: json['stochK'] as num?,
  stochD: json['stochD'] as num?,
  macd: json['macd'] as num?,
  macdSignal: json['macdSignal'] as num?,
  macdHistogram: json['macdHistogram'] as num?,
  ema50: json['ema50'] as num?,
  ema200: json['ema200'] as num?,
  atr: json['atr'] as num?,
  volume: json['volume'] as num?,
  volumeSma: json['volumeSma'] as num?,
  pivotHigh: json['pivotHigh'] as num?,
  pivotLow: json['pivotLow'] as num?,
  status: json['status'] as String,
  closePrice: json['closePrice'] as num?,
  closeReason: json['closeReason'] as String?,
  closedAt: json['closedAt'] == null
      ? null
      : DateTime.parse(json['closedAt'] as String),
  profitLoss: json['profitLoss'] as num?,
  profitLossPct: json['profitLossPct'] as num?,
  webhookPayload: json['webhookPayload'] == null
      ? null
      : WebhookPayloadDto.fromJson(
          json['webhookPayload'] as Map<String, dynamic>,
        ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  currentPrice: json['currentPrice'] as num,
  progressPct: json['progressPct'] as num,
  profitPct: (json['profitPct'] as num?)?.toDouble(),
  profitUsd: json['profitUsd'] as num?,
  signalStatus: json['signalStatus'] as String?,
  indicators: json['indicators'] == null
      ? null
      : IndicatorsDto.fromJson(json['indicators'] as Map<String, dynamic>),
  ticker: json['ticker'] == null
      ? null
      : TickersDto.fromJson(json['ticker'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SignalsDtoToJson(SignalsDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tickerId': instance.tickerId,
      'symbol': instance.symbol,
      'timeframe': instance.timeframe,
      'direction': instance.direction,
      'price': instance.price,
      'entryBarTime': instance.entryBarTime?.toIso8601String(),
      'takeProfit': instance.takeProfit,
      'stopLoss': instance.stopLoss,
      'prevMove': instance.prevMove,
      'stochK': instance.stochK,
      'stochD': instance.stochD,
      'macd': instance.macd,
      'macdSignal': instance.macdSignal,
      'macdHistogram': instance.macdHistogram,
      'ema50': instance.ema50,
      'ema200': instance.ema200,
      'atr': instance.atr,
      'volume': instance.volume,
      'volumeSma': instance.volumeSma,
      'pivotHigh': instance.pivotHigh,
      'pivotLow': instance.pivotLow,
      'status': instance.status,
      'closePrice': instance.closePrice,
      'closeReason': instance.closeReason,
      'closedAt': instance.closedAt?.toIso8601String(),
      'profitLoss': instance.profitLoss,
      'profitLossPct': instance.profitLossPct,
      'webhookPayload': instance.webhookPayload,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'currentPrice': instance.currentPrice,
      'progressPct': instance.progressPct,
      'profitPct': instance.profitPct,
      'profitUsd': instance.profitUsd,
      'signalStatus': instance.signalStatus,
      'indicators': instance.indicators,
      'ticker': instance.ticker,
    };
