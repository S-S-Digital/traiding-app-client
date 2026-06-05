// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignalStatsDto _$SignalStatsDtoFromJson(Map<String, dynamic> json) =>
    SignalStatsDto(
      total: json['total'] as num,
      totalBuy: json['totalBuy'] as num,
      totalSell: json['totalSell'] as num,
      active: json['active'] as num,
      closed: json['closed'] as num,
      profitable: json['profitable'] as num,
      unprofitable: json['unprofitable'] as num,
      winRate: json['winRate'] as num,
      totalProfitLoss: json['totalProfitLoss'] as num,
      totalProfitLossPct: json['totalProfitLossPct'] as num,
      avgProfitLossPct: json['avgProfitLossPct'] as num,
    );

Map<String, dynamic> _$SignalStatsDtoToJson(SignalStatsDto instance) =>
    <String, dynamic>{
      'total': instance.total,
      'totalBuy': instance.totalBuy,
      'totalSell': instance.totalSell,
      'active': instance.active,
      'closed': instance.closed,
      'profitable': instance.profitable,
      'unprofitable': instance.unprofitable,
      'winRate': instance.winRate,
      'totalProfitLoss': instance.totalProfitLoss,
      'totalProfitLossPct': instance.totalProfitLossPct,
      'avgProfitLossPct': instance.avgProfitLossPct,
    };
