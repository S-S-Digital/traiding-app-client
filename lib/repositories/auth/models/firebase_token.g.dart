// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirebaseToken _$FirebaseTokenFromJson(Map<String, dynamic> json) =>
    FirebaseToken(
      fcmToken: json['fcmToken'] as String,
      platform: json['platform'] as String,
    );

Map<String, dynamic> _$FirebaseTokenToJson(FirebaseToken instance) =>
    <String, dynamic>{
      'fcmToken': instance.fcmToken,
      'platform': instance.platform,
    };
