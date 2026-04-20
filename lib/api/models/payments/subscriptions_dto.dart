import 'package:aspiro_trade/api/models/payments/payments.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscriptions_dto.g.dart';

@JsonSerializable()
class SubscriptionsDto {
  final String id;
  final String userId;
  final String planId;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String platform;
  final String? originalTransactionId;
  final String? purchaseToken;
  final bool autoRenew;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SubscriptionPlansDto plan;
  final bool? isSandbox;
  final String? ownershipType;
  final String? linkedPurchaseToken;
  final bool? isTrial;
  final DateTime? trialEndDate;

  SubscriptionsDto({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.platform,
    this.originalTransactionId,
    this.purchaseToken,
    required this.autoRenew,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
    required this.plan,
    this.isSandbox,
    this.ownershipType,
    this.linkedPurchaseToken,
    this.isTrial,
    this.trialEndDate,
  });

  factory SubscriptionsDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionsDtoToJson(this);
}
