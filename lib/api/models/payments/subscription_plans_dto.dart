import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription_plans_dto.g.dart';

@JsonSerializable()
class SubscriptionPlansDto extends Equatable {
  const SubscriptionPlansDto({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.currency,
    required this.appleProductId,
    required this.googleProductId,
    required this.maxTickers,
    required this.features,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final int duration;
  final String price;
  final String currency;
  final String? appleProductId;
  final String? googleProductId;
  final int maxTickers;
  final List<String> features;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SubscriptionPlansDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlansDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPlansDtoToJson(this);

  SubscriptionPlans toEntity() => SubscriptionPlans(
    id: id,
    name: name,
    description: description,
    duration: duration,
    price: price,
    currency: currency,
    appleProductId: appleProductId ?? '',
    googleProductId: googleProductId ?? '',
    maxTickers: maxTickers,
    features: features,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  SubscriptionPlansLocal toLocal() => SubscriptionPlansLocal(
    id,
    name,
    description,
    duration,
    price,
    currency,
    appleProductId ?? '',
    googleProductId ?? '',
    maxTickers,
    isActive,
    createdAt,
    updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    duration,
    price,
    currency,
    appleProductId,
    googleProductId,
    maxTickers,
    features,
    isActive,
    createdAt,
    updatedAt,
  ];
}
