// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tickers_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TickersDto _$TickersDtoFromJson(Map<String, dynamic> json) => TickersDto(
  id: json['id'] as String,
  userId: json['userId'] as String,
  symbol: json['symbol'] as String,
  timeframe: json['timeframe'] as String,
  notifyBuy: json['notifyBuy'] as bool,
  notifySell: json['notifySell'] as bool,
  isActive: json['isActive'] as bool,
  addedAt: DateTime.parse(json['addedAt'] as String),
);

Map<String, dynamic> _$TickersDtoToJson(TickersDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'symbol': instance.symbol,
      'timeframe': instance.timeframe,
      'notifyBuy': instance.notifyBuy,
      'notifySell': instance.notifySell,
      'isActive': instance.isActive,
      'addedAt': instance.addedAt.toIso8601String(),
    };
