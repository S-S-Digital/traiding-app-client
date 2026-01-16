import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/payments/domain/domain.dart';
import 'package:aspiro_trade/repositories/payments/models/models.dart';

abstract interface class PaymentsRepositoryI{
  Future<List<SubscriptionPlans>> fetchAllPlans();
  Future<void> getCurrentSubscription();
  Future<PaymentReceiptDto> applePayments(AppleReceipts receipts);
  Future<PaymentReceiptDto> googlePayments(GoogleReceipts receipts);
}