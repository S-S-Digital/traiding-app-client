import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/payments/domain/domain.dart';
import 'package:aspiro_trade/repositories/payments/models/models.dart';

abstract interface class PaymentsRepositoryI{
  Future<List<SubscriptionPlans>> fetchAllPlans();
  Future<List<SubscriptionsDto>> getCurrentSubscription();
  Future<void> applePayments(AppleReceipts receipts);
  Future<PaymentReceiptDto> googlePayments(GoogleReceipts receipts);
}