// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tickers_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TickersDto _$TickersDtoFromJson(Map<String, dynamic> json) => TickersDto(
  symbol: json['symbol'] as String?,
  timeframe: json['timeframe'] as String?,
);

Map<String, dynamic> _$TickersDtoToJson(TickersDto instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'timeframe': instance.timeframe,
    };
