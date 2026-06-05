import 'package:aspiro_trade/repositories/signals/domain/signal_stats.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'signal_stats_dto.g.dart';

@JsonSerializable()
class SignalStatsDto extends Equatable {
  final num total;
  final num totalBuy;
  final num totalSell;
  final num active;
  final num closed;
  final num profitable;
  final num unprofitable;
  final num winRate;
  final num totalProfitLoss;
  final num totalProfitLossPct;
  final num avgProfitLossPct;

  const SignalStatsDto({
    required this.total,
    required this.totalBuy,
    required this.totalSell,
    required this.active,
    required this.closed,
    required this.profitable,
    required this.unprofitable,
    required this.winRate,
    required this.totalProfitLoss,
    required this.totalProfitLossPct,
    required this.avgProfitLossPct,
  });

  factory SignalStatsDto.fromJson(Map<String, dynamic> json) =>
      _$SignalStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SignalStatsDtoToJson(this);

  SignalStats toEntity() => SignalStats(
    total: total,
    totalBuy: totalBuy,
    totalSell: totalSell,
    active: active,
    closed: closed,
    profitable: profitable,
    unprofitable: unprofitable,
    winRate: winRate,
    totalProfitLoss: totalProfitLoss,
    totalProfitLossPct: totalProfitLossPct,
    avgProfitLossPct: avgProfitLossPct,
  );

  @override
  List<Object?> get props => [
    total, totalBuy, totalSell, active, closed,
    profitable, unprofitable, winRate,
    totalProfitLoss, totalProfitLossPct, avgProfitLossPct,
  ];
}
