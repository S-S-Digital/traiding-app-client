import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'indicators_dto.g.dart';

@JsonSerializable()
class IndicatorsDto extends Equatable {
  const IndicatorsDto({
    required this.atr,
    required this.macd,
    required this.ema50,
    required this.ema200,
    required this.volume,
    required this.stochD,
    required this.stochK,
    required this.volumeSma,
    required this.macdSignal,
    required this.macdHistogram,
  });

  final double? atr;
  final double? macd;
  final double? ema50;
  final double? ema200;
  final num? volume;
  @JsonKey(name: 'stoch_d')
  final double? stochD;

  @JsonKey(name: 'stoch_k')
  final double? stochK;

  @JsonKey(name: 'volume_sma')
  final num? volumeSma;

  @JsonKey(name: 'macd_signal')
  final double? macdSignal;
  @JsonKey(name: 'macd_histogram')
  final num? macdHistogram;

  factory IndicatorsDto.empty() => const IndicatorsDto(
    atr: 0,
    macd: 0,
    ema50: 0,
    ema200: 0,
    volume: 0,
    stochD: 0,
    stochK: 0,
    volumeSma: 0,
    macdSignal: 0,
    macdHistogram: 0,
  );

  factory IndicatorsDto.fromJson(Map<String, dynamic> json) =>
      _$IndicatorsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$IndicatorsDtoToJson(this);

  Indicator toEntity() => Indicator(
    atr: atr ?? 0,
    macd: macd ?? 0,
    ema50: ema50 ?? 0,
    ema200: ema200 ?? 0,
    stochD: stochD ?? 0,
    stochK: stochK ?? 0,
    macdSignal: macdSignal ?? 0,
    volume: volume ?? 0,
    volumeSma: volumeSma ?? 0,
    macdHistogram: macdHistogram ?? 0,
  );

  @override
  List<Object?> get props => [
    atr,
    macd,
    ema50,
    ema200,
    stochD,
    stochK,
    macdSignal,
    volumeSma,
    macdHistogram,
  ];
}
