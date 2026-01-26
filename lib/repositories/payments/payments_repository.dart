import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/base/base.dart';
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:realm/realm.dart';

class PaymentsRepository extends BaseRepository implements PaymentsRepositoryI {
  PaymentsRepository(super.talker, {required this.api, required this.realm});

  final AspiroTradeApi api;
  final Realm realm;
  @override
  Future<List<SubscriptionPlans>> fetchAllPlans() => safeApiCall(() async {
    final response = await api.fetchAllPlans();
    final subcriptions = response.map((e) => e.toEntity()).toList();

    // realm.write(() {
    //   realm.deleteAll<SubscriptionPlansLocal>();
    //   realm.addAll(response.map((e) => e.toLocal()), update: true);
    // });

    return subcriptions;
  });

  @override
  Future<void> getCurrentSubscription() => safeApiCall(() async {
    await api.getCurrentSubscription();
  });

  @override
  Future<PaymentReceiptDto> applePayments(AppleReceipts receipts) =>
      safeApiCall(() async {
        return await api.applePayments(receipts);
      });

  @override
  Future<PaymentReceiptDto> googlePayments(GoogleReceipts receipts) =>
      safeApiCall(() async {
        return await api.googlePayments(receipts);
      });
}
