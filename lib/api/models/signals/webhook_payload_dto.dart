import 'package:aspiro_trade/api/models/signals/indicators_dto.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'webhook_payload_dto.g.dart';

@JsonSerializable()
class WebhookPayloadDto extends Equatable {
  const WebhookPayloadDto({
    required this.sl,
    required this.tp,
    required this.price,
    required this.ticker,
    required this.direction,
    required this.prevMove,
    required this.timeframe,
    required this.indicators,
    required this.entryBarTime,
  });
  @JsonKey(name: 'SL')
  final num sl;

  @JsonKey(name: 'TP')
  final num tp;

  final num price;
  final String ticker;
  final String direction;
  @JsonKey(name: 'prev_move')
  final num prevMove;


  final String timeframe;
  final IndicatorsDto indicators;
  @JsonKey(name: 'entry_bar_time')
  final DateTime entryBarTime;


    factory WebhookPayloadDto.fromJson(Map<String, dynamic> json) =>
      _$WebhookPayloadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WebhookPayloadDtoToJson(this);

  @override
  List<Object?> get props => [
    sl,
    tp,
    price,
    ticker,
    direction,
    prevMove,
    timeframe,
    entryBarTime,
  ];
}
