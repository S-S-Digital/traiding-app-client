// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhook_payload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebhookPayloadDto _$WebhookPayloadDtoFromJson(Map<String, dynamic> json) =>
    WebhookPayloadDto(
      sl: json['SL'] as num,
      tp: json['TP'] as num,
      price: json['price'] as num,
      ticker: json['ticker'] as String,
      direction: json['direction'] as String,
      prevMove: json['prev_move'] as num,
      timeframe: json['timeframe'] as String,
      indicators: IndicatorsDto.fromJson(
        json['indicators'] as Map<String, dynamic>,
      ),
      entryBarTime: DateTime.parse(json['entry_bar_time'] as String),
    );

Map<String, dynamic> _$WebhookPayloadDtoToJson(WebhookPayloadDto instance) =>
    <String, dynamic>{
      'SL': instance.sl,
      'TP': instance.tp,
      'price': instance.price,
      'ticker': instance.ticker,
      'direction': instance.direction,
      'prev_move': instance.prevMove,
      'timeframe': instance.timeframe,
      'indicators': instance.indicators,
      'entry_bar_time': instance.entryBarTime.toIso8601String(),
    };
