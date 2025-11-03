// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candles_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandlesDto _$CandlesDtoFromJson(Map<String, dynamic> json) => CandlesDto(
  openTime: (json['openTime'] as num).toInt(),
  open: json['open'] as String,
  high: json['high'] as String,
  low: json['low'] as String,
  close: json['close'] as String,
  volume: json['volume'] as String,
  closeTime: (json['closeTime'] as num).toInt(),
  quoteAssetVolume: json['quoteAssetVolume'] as String,
  numberOfTrades: (json['numberOfTrades'] as num).toInt(),
  takerBuyBaseAssetVolume: json['takerBuyBaseAssetVolume'] as String,
  takerBuyQuoteAssetVolume: json['takerBuyQuoteAssetVolume'] as String,
);

Map<String, dynamic> _$CandlesDtoToJson(CandlesDto instance) =>
    <String, dynamic>{
      'openTime': instance.openTime,
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'volume': instance.volume,
      'closeTime': instance.closeTime,
      'quoteAssetVolume': instance.quoteAssetVolume,
      'numberOfTrades': instance.numberOfTrades,
      'takerBuyBaseAssetVolume': instance.takerBuyBaseAssetVolume,
      'takerBuyQuoteAssetVolume': instance.takerBuyQuoteAssetVolume,
    };
