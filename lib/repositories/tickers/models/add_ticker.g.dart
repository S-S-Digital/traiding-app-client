// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_ticker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddTicker _$AddTickerFromJson(Map<String, dynamic> json) => AddTicker(
  symbol: json['symbol'] as String,
  timeframe: json['timeframe'] as String,
  notifyBuy: json['notifyBuy'] as bool,
  notifySell: json['notifySell'] as bool,
);

Map<String, dynamic> _$AddTickerToJson(AddTicker instance) => <String, dynamic>{
  'symbol': instance.symbol,
  'timeframe': instance.timeframe,
  'notifyBuy': instance.notifyBuy,
  'notifySell': instance.notifySell,
};
