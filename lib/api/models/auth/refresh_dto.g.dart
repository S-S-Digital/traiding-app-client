// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshDto _$RefreshDtoFromJson(Map<String, dynamic> json) => RefreshDto(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$RefreshDtoToJson(RefreshDto instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
