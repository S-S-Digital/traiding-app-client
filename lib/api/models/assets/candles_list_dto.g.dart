// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candles_list_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandlesListDto _$CandlesListDtoFromJson(Map<String, dynamic> json) =>
    CandlesListDto(
      symbol: json['symbol'] as String,
      interval: json['interval'] as String,
      limit: (json['limit'] as num).toInt(),
      candles: (json['candles'] as List<dynamic>)
          .map((e) => CandlesDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CandlesListDtoToJson(CandlesListDto instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'interval': instance.interval,
      'limit': instance.limit,
      'candles': instance.candles,
    };
