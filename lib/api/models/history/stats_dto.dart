import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stats_dto.g.dart';

@JsonSerializable()
class StatsDto extends Equatable {
  final num totalSignals;
  final num successfulSignals;
  final num winRate;
  final num totalProfit;

  const StatsDto({
    required this.totalSignals,
    required this.successfulSignals,
    required this.winRate,
    required this.totalProfit,
  });

  factory StatsDto.fromJson(Map<String, dynamic> json) =>
      _$StatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StatsDtoToJson(this);

  Stats toEntity() => Stats(
    totalSignals: totalSignals,
    successfulSignals: successfulSignals,
    winRate: winRate,
    totalProfit: totalProfit,
  );

  @override
  List<Object?> get props => [
    totalSignals,
    successfulSignals,
    winRate,
    totalProfit,
  ];
}
