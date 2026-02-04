// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriptions_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionsDto _$SubscriptionsDtoFromJson(Map<String, dynamic> json) =>
    SubscriptionsDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      planId: json['planId'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      platform: json['platform'] as String,
      originalTransactionId: json['originalTransactionId'] as String?,
      purchaseToken: json['purchaseToken'] as String?,
      autoRenew: json['autoRenew'] as bool,
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      plan: SubscriptionPlansDto.fromJson(json['plan'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SubscriptionsDtoToJson(SubscriptionsDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'planId': instance.planId,
      'status': instance.status,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'platform': instance.platform,
      'originalTransactionId': instance.originalTransactionId,
      'purchaseToken': instance.purchaseToken,
      'autoRenew': instance.autoRenew,
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'plan': instance.plan,
    };
