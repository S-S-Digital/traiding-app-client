// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indicators_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndicatorsDto _$IndicatorsDtoFromJson(Map<String, dynamic> json) =>
    IndicatorsDto(
      atr: (json['atr'] as num?)?.toDouble(),
      macd: (json['macd'] as num?)?.toDouble(),
      ema50: (json['ema50'] as num?)?.toDouble(),
      ema200: (json['ema200'] as num?)?.toDouble(),
      volume: json['volume'] as num?,
      stochD: (json['stoch_d'] as num?)?.toDouble(),
      stochK: (json['stoch_k'] as num?)?.toDouble(),
      volumeSma: json['volume_sma'] as num?,
      macdSignal: (json['macd_signal'] as num?)?.toDouble(),
      macdHistogram: json['macd_histogram'] as num?,
    );

Map<String, dynamic> _$IndicatorsDtoToJson(IndicatorsDto instance) =>
    <String, dynamic>{
      'atr': instance.atr,
      'macd': instance.macd,
      'ema50': instance.ema50,
      'ema200': instance.ema200,
      'volume': instance.volume,
      'stoch_d': instance.stochD,
      'stoch_k': instance.stochK,
      'volume_sma': instance.volumeSma,
      'macd_signal': instance.macdSignal,
      'macd_histogram': instance.macdHistogram,
    };
