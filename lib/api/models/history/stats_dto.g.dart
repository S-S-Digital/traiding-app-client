// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatsDto _$StatsDtoFromJson(Map<String, dynamic> json) => StatsDto(
  totalSignals: json['totalSignals'] as num,
  successfulSignals: json['successfulSignals'] as num,
  winRate: json['winRate'] as num,
  totalProfit: json['totalProfit'] as num,
);

Map<String, dynamic> _$StatsDtoToJson(StatsDto instance) => <String, dynamic>{
  'totalSignals': instance.totalSignals,
  'successfulSignals': instance.successfulSignals,
  'winRate': instance.winRate,
  'totalProfit': instance.totalProfit,
};
