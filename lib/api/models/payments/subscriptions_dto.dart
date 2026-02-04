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
  });

  factory SubscriptionsDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionsDtoToJson(this);
}













// │ [http-response] [GET] http://208.92.226.129:3001/payments/plans
//          │ Status: 200
//          │ Message: OK
//          │ Data: [
//          │   {
//          │     "id": "2e02a086-86ff-44c9-ab94-e6b05f470305",
//          │     "name": "FREE",
//          │     "description": "Бесплатный тариф - только просмотр сигналов",
//          │     "duration": 0,
//          │     "price": "0",
//          │     "currency": "USD",
//          │     "appleProductId": null,
//          │     "googleProductId": null,
//          │     "maxTickers": 0,
//          │     "features": [
//          │       "view_signals"
//          │     ],
//          │     "isActive": true,
//          │     "createdAt": "2025-11-16T13:17:09.341Z",
//          │     "updatedAt": "2025-11-16T13:17:09.341Z"
//          │   },
//          │   {
//          │     "id": "ae88a6d1-286d-475b-8fc1-7038ff1d6291",
//          │     "name": "PRO",
//          │     "description": "PRO подписка - безлимитный доступ ко всем функциям",
//          │     "duration": 30,
//          │     "price": "49.99",
//          │     "currency": "USD",
//          │     "appleProductId": "com.tradingapp.pro.monthly",
//          │     "googleProductId": "pro_monthly",
//          │     "maxTickers": 999999,
//          │     "features": [
//          │       "view_signals",
//          │       "add_tickers",
//          │       "receive_signals",
//          │       "push_notifications",
//          │       "signal_history",
//          │       "advanced_analytics",
//          │       "priority_support"
//          │     ],
//          │     "isActive": true,
//          │     "createdAt": "2025-11-16T13:17:09.346Z",
//          │     "updatedAt": "2025-11-16T13:17:09.346Z"
//          │   }
//          │ ]
//          └──────────────────────────────────────────────────────────────────────────────────────────────────────────────
// [Talker] ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────
//          │ [http-request] [GET] http://208.92.226.129:3001/payments/subscriptions
//          └──────────────────────────────────────────────────────────────────────────────────────────────────────────────
// [Talker] ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────
//          │ [http-response] [GET] http://208.92.226.129:3001/payments/subscriptions
//          │ Status: 200
//          │ Message: OK
//          │ Data: [
//          │   {
//          │     "id": "bdb1d0cf-b2ad-45cb-a752-29bcfae11413",
//          │     "userId": "6d242346-2822-4f1f-8d44-07d2203657e2",
//          │     "planId": "ae88a6d1-286d-475b-8fc1-7038ff1d6291",
//          │     "status": "active",
//          │     "startDate": "2026-01-26T08:30:22.925Z",
//          │     "endDate": "2026-02-25T08:30:22.925Z",
//          │     "platform": "apple",
//          │     "originalTransactionId": "2000001109783498",
//          │     "purchaseToken": null,
//          │     "autoRenew": true,
//          │     "cancelledAt": null,
//          │     "createdAt": "2026-01-26T08:30:22.927Z",
//          │     "updatedAt": "2026-01-26T08:30:22.927Z",
//          │     "plan": {
//          │       "id": "ae88a6d1-286d-475b-8fc1-7038ff1d6291",
//          │       "name": "PRO",
//          │       "description": "PRO подписка - безлимитный доступ ко всем функциям",
//          │       "duration": 30,
//          │       "price": "49.99",
//          │       "currency": "USD",
//          │       "appleProductId": "com.tradingapp.pro.monthly",
//          │       "googleProductId": "pro_monthly",
//          │       "maxTickers": 999999,
//          │       "features": [
//          │         "view_signals",
//          │         "add_tickers",
//          │         "receive_signals",
//          │         "push_notifications",
//          │         "signal_history",
//          │         "advanced_analytics",
//          │         "priority_support"
//          │       ],
//          │       "isActive": true,
//          │       "createdAt": "2025-11-16T13:17:09.346Z",
//          │       "updatedAt": "2025-11-16T13:17:09.346Z"
//          │     }
//          │   }
//          │ ]