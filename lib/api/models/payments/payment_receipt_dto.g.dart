// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_receipt_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentReceiptDto _$PaymentReceiptDtoFromJson(Map<String, dynamic> json) =>
    PaymentReceiptDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      planId: json['planId'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      platform: json['platform'] as String,
      autoRenew: json['autoRenew'] as bool,
      cancelledAt: DateTime.parse(json['cancelledAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      plan: json['plan'],
    );

Map<String, dynamic> _$PaymentReceiptDtoToJson(PaymentReceiptDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'planId': instance.planId,
      'status': instance.status,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'platform': instance.platform,
      'autoRenew': instance.autoRenew,
      'cancelledAt': instance.cancelledAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'plan': instance.plan,
    };
