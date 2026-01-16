
import 'package:json_annotation/json_annotation.dart';

part 'payment_receipt_dto.g.dart';

@JsonSerializable()
class PaymentReceiptDto {
  final String id;
  final String userId;
  final String planId;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String platform;
  final bool autoRenew;
  final DateTime cancelledAt;
  final DateTime createdAt;
  final dynamic plan;

  PaymentReceiptDto({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.platform,
    required this.autoRenew,
    required this.cancelledAt,
    required this.createdAt,
    required this.plan,
  });

  factory PaymentReceiptDto.fromJson(Map<String, dynamic> json) => _$PaymentReceiptDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentReceiptDtoToJson(this);

  
}
