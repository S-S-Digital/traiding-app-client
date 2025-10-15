// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthDto _$AuthDtoFromJson(Map<String, dynamic> json) => AuthDto(
  user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$AuthDtoToJson(AuthDto instance) => <String, dynamic>{
  'user': instance.user,
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
};
