// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsersDto _$UsersDtoFromJson(Map<String, dynamic> json) => UsersDto(
  id: json['id'] as String,
  email: json['email'] as String,
  passwordHash: json['passwordHash'] as String,
  phone: json['phone'] as String,
  fcmToken: json['fcmToken'] as String?,
  isActive: json['isActive'] as bool,
  isPremium: json['isPremium'] as bool,
  premiumUntil: json['premiumUntil'] == null
      ? null
      : DateTime.parse(json['premiumUntil'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UsersDtoToJson(UsersDto instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'passwordHash': instance.passwordHash,
  'phone': instance.phone,
  'fcmToken': instance.fcmToken,
  'isActive': instance.isActive,
  'isPremium': instance.isPremium,
  'premiumUntil': instance.premiumUntil?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
