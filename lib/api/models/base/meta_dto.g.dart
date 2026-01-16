// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetaDto _$MetaDtoFromJson(Map<String, dynamic> json) => MetaDto(
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$MetaDtoToJson(MetaDto instance) => <String, dynamic>{
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
  'totalPages': instance.totalPages,
};
