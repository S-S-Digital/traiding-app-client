// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResponseDto<T> _$BaseResponseDtoFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => BaseResponseDto<T>(
  data: fromJsonT(json['data']),
  meta: MetaDto.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BaseResponseDtoToJson<T>(
  BaseResponseDto<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{'data': toJsonT(instance.data), 'meta': instance.meta};
