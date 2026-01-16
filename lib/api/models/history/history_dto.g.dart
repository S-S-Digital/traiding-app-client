// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryDto _$HistoryDtoFromJson(Map<String, dynamic> json) => HistoryDto(
  id: json['id'] as String,
  symbol: json['symbol'] as String,
  direction: json['direction'] as String,
  timeframe: json['timeframe'] as String,
  status: json['status'] as String,
  entry: json['entry'] as num,
  exit: json['exit'] as num,
  takeProfit: json['takeProfit'] as num,
  stopLoss: json['stopLoss'] as num,
  resultPct: json['resultPct'] as num,
  resultUsd: json['resultUsd'] as num,
  duration: json['duration'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  closedAt: DateTime.parse(json['closedAt'] as String),
);

Map<String, dynamic> _$HistoryDtoToJson(HistoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'direction': instance.direction,
      'timeframe': instance.timeframe,
      'status': instance.status,
      'entry': instance.entry,
      'exit': instance.exit,
      'takeProfit': instance.takeProfit,
      'stopLoss': instance.stopLoss,
      'resultPct': instance.resultPct,
      'resultUsd': instance.resultUsd,
      'duration': instance.duration,
      'createdAt': instance.createdAt.toIso8601String(),
      'closedAt': instance.closedAt.toIso8601String(),
    };
