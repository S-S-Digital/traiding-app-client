// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_plans_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionPlansDto _$SubscriptionPlansDtoFromJson(
  Map<String, dynamic> json,
) => SubscriptionPlansDto(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  duration: (json['duration'] as num).toInt(),
  price: json['price'] as String,
  currency: json['currency'] as String,
  appleProductId: json['appleProductId'] as String?,
  googleProductId: json['googleProductId'] as String?,
  maxTickers: (json['maxTickers'] as num).toInt(),
  features: (json['features'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SubscriptionPlansDtoToJson(
  SubscriptionPlansDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'duration': instance.duration,
  'price': instance.price,
  'currency': instance.currency,
  'appleProductId': instance.appleProductId,
  'googleProductId': instance.googleProductId,
  'maxTickers': instance.maxTickers,
  'features': instance.features,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
