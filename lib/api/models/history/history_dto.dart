import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'history_dto.g.dart';

@JsonSerializable()
class HistoryDto extends Equatable {
  const HistoryDto({
    required this.id,
    required this.symbol,
    required this.direction,
    required this.timeframe,
    required this.status,
    required this.entry,
    required this.exit,
    required this.takeProfit,
    required this.stopLoss,
    required this.resultPct,
    required this.resultUsd,
    required this.duration,
    required this.createdAt,
    required this.closedAt,
  });

  final String id;
  final String symbol;
  final String direction;
  final String timeframe;
  final String status;
  final num entry;
  final num exit;
  final num takeProfit;
  final num stopLoss;
  final num resultPct;
  final num resultUsd;
  final String duration;
  final DateTime createdAt;
  final DateTime closedAt;

  factory HistoryDto.fromJson(Map<String, dynamic> json) =>
      _$HistoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryDtoToJson(this);

  History toEntity() => History(
    id: id,
    symbol: symbol,
    direction: direction,
    timeframe: timeframe,
    status: status,
    entry: entry,
    exit: exit,
    takeProfit: takeProfit,
    stopLoss: stopLoss,
    resultPct: resultPct,
    resultUsd: resultUsd,
    duration: duration,
    createdAt: createdAt,
    closedAt: closedAt,
  );

  @override
  List<Object?> get props => [
    id,
    symbol,
    direction,
    timeframe,
    status,
    entry,
    exit,
    takeProfit,
    stopLoss,
    resultPct,
    resultUsd,
    duration,
    createdAt,
    closedAt,
  ];
}
