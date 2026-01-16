// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_list_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryListDto _$HistoryListDtoFromJson(Map<String, dynamic> json) =>
    HistoryListDto(
      data: (json['data'] as List<dynamic>)
          .map((e) => HistoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: StatsDto.fromJson(json['stats'] as Map<String, dynamic>),
      meta: MetaDto.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HistoryListDtoToJson(HistoryListDto instance) =>
    <String, dynamic>{
      'data': instance.data,
      'stats': instance.stats,
      'meta': instance.meta,
    };
