// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleAuth _$GoogleAuthFromJson(Map<String, dynamic> json) => GoogleAuth(
  provider: json['provider'] as String,
  providerId: json['providerId'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  picture: json['picture'] as String,
  accessToken: json['accessToken'] as String,
);

Map<String, dynamic> _$GoogleAuthToJson(GoogleAuth instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'providerId': instance.providerId,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'picture': instance.picture,
      'accessToken': instance.accessToken,
    };
