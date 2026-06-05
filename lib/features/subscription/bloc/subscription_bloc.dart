import 'dart:async';
import 'dart:io';
import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

const String _packageName = String.fromEnvironment(
  'PACKAGE_NAME',
  defaultValue: 'com.aspiro.trade',
);

const Duration _restoreTimeout = Duration(seconds: 15);

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc({
    required PaymentsRepositoryI paymentsRepository,
  }) : _paymentsRepository = paymentsRepository,
       super(const SubscriptionState()) {
    on<Start>(_onStart);
    on<PurchasePlan>(_onPurchasePlan);
    on<UpdatePurchaseStatus>(_onUpdatePurchaseStatus);
    on<RestorePurchases>(_onRestorePurchases);

    _subscription = _iap.purchaseStream.listen(
      (purchases) => add(UpdatePurchaseStatus(purchases)),
      onError: (error) => talker.error('IAP Stream Error: $error'),
    );
  }

  final PaymentsRepositoryI _paymentsRepository;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /* ---------------- START ---------------- */

  Future<void> _onStart(Start event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    try {
      final isAvailable = await _iap.isAvailable();
      talker.debug('IAP isAvailable: $isAvailable');
      if (!isAvailable) {
        emit(
          state.copyWith(
            status: SubscriptionStatus.failure,
            error: 'Store unavailable',
          ),
        );
        return;
      }

      final plans = await _paymentsRepository.fetchAllPlans();
      talker.debug('Plans loaded: ${plans.length}');
      for (final p in plans) {
        talker.debug('  Plan: ${p.name} | apple: ${p.appleProductId} | google: ${p.googleProductId} | price: ${p.price}');
      }

      final myPlan = await _paymentsRepository.getCurrentSubscription();
      talker.debug('Current subscriptions: ${myPlan.length}');

      final ids = plans
          .map((p) => Platform.isIOS ? p.appleProductId : p.googleProductId)
          .where((id) => id.isNotEmpty)
          .toSet();

      talker.debug('Querying product IDs: $ids');
      final response = await _iap.queryProductDetails(ids);

      if (response.error != null) {
        talker.error('IAP query error: ${response.error}');
        throw Exception(response.error);
      }

      talker.debug('Found products: ${response.productDetails.length}');
      for (final pd in response.productDetails) {
        talker.debug('  Product: ${pd.id} | ${pd.title} | ${pd.price}');
      }

      if (response.notFoundIDs.isNotEmpty) {
        talker.error('IAP not found IDs: ${response.notFoundIDs}');
      }

      emit(
        state.copyWith(
          status: SubscriptionStatus.loaded,
          plans: plans,
          productDetails: response.productDetails,
          subscription: myPlan.isNotEmpty ? myPlan.last : null,
          error: null,
        ),
      );
    } catch (e) {
      talker.error('IAP Start error: $e');
      emit(state.copyWith(status: SubscriptionStatus.failure, error: e));
    }
  }

  /* ---------------- PURCHASE ---------------- */

  Future<void> _onPurchasePlan(
    PurchasePlan event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      talker.debug('Purchase initiated: ${event.productDetails.id} | ${event.productDetails.title} | ${event.productDetails.price}');
      emit(state.copyWith(status: SubscriptionStatus.purchasing));

      final PurchaseParam param;
      if (Platform.isAndroid) {
        final userId = _paymentsRepository.getCurrentUserId();
        param = GooglePlayPurchaseParam(
          productDetails: event.productDetails,
          applicationUserName: userId,
        );
      } else {
        param = PurchaseParam(productDetails: event.productDetails);
      }

      talker.debug('Calling buyNonConsumable...');
      final result = await _iap.buyNonConsumable(purchaseParam: param);
      talker.debug('buyNonConsumable returned: $result');
    } catch (e) {
      talker.error('Purchase initiation error: $e');
      // Handle cancellation on both iOS (StoreKit2) and Android
      if (e is PlatformException && 
          (e.code == 'storekit2_purchase_cancelled' || 
           e.code == 'purchase_cancelled')) {
        talker.debug('Purchase cancelled by user');
        emit(state.copyWith(status: SubscriptionStatus.loaded));
        return;
      }
      emit(state.copyWith(status: SubscriptionStatus.failure, error: e));
    }
  }
  /* ---------------- PURCHASE STREAM ---------------- */

  Future<void> _onUpdatePurchaseStatus(
    UpdatePurchaseStatus event,
    Emitter<SubscriptionState> emit,
  ) async {
    for (final purchase in event.purchases) {
      talker.debug(purchase.status);
      
      // Handle cancellation (Android sends this via stream)
      if (purchase.status == PurchaseStatus.canceled) {
        talker.debug('Purchase cancelled by user (stream)');
        emit(state.copyWith(status: SubscriptionStatus.loaded));
        continue;
      }
      
      if (purchase.status == PurchaseStatus.pending) {
        emit(state.copyWith(status: SubscriptionStatus.purchasing));
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }

        emit(
          state.copyWith(
            status: SubscriptionStatus.failure,
            error: purchase.error?.message ?? 'Purchase error',
          ),
        );

        add(Start());
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final verifyData = purchase.verificationData.serverVerificationData;
        talker.debug(
          'Verify data type: ${verifyData.startsWith('eyJ') ? 'JWS' : 'legacy'}, len=${verifyData.length}',
        );

        bool verified = false;
        try {
          if (Platform.isIOS) {
            await _paymentsRepository.applePayments(
              AppleReceipts(
                receiptData: verifyData,
                transactionId: purchase.purchaseID ?? '',
              ),
            );
          } else {
            // Cast to GooglePlayPurchaseDetails to get the REAL purchase token —
            // serverVerificationData may return order ID instead of purchase token.
            final googleDetails = purchase as GooglePlayPurchaseDetails;
            final realToken = googleDetails.billingClientPurchase.purchaseToken;

            talker.debug('Google purchase token length: ${realToken.length}');

            await _paymentsRepository.googlePayments(
              GoogleReceipts(
                purchaseToken: realToken,
                productId: purchase.productID,
                packageName: _packageName,
              ),
            );
          }
          verified = true;
        } catch (e) {
          talker.error('Verification error: $e');

          // PERMANENT backend rejection (4xx — e.g. expired or already-used
          // transaction): we MUST finish the transaction. Otherwise StoreKit /
          // Play Billing keeps the purchase unfinished and re-delivers it via
          // purchaseStream on every launch — an infinite verify loop that also
          // blocks the user from making any NEW purchase of the same product.
          // TRANSIENT failures (network/timeout/5xx → statusCode null or >=500)
          // are intentionally left unfinished so the purchase is retried later.
          final status = e is AppException ? e.statusCode : null;
          final isPermanentReject =
              status != null && status >= 400 && status < 500;
          if (isPermanentReject && purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }

          // Pass the typed exception (not an interpolated String) so
          // context.handleException can map it to a friendly localized message
          // instead of dumping the raw backend text (e.g. the "Testflight
          // receipts aren't supported" string) into a user-facing snackbar.
          emit(
            state.copyWith(
              status: SubscriptionStatus.failure,
              error: e,
            ),
          );
        }

        if (verified) {
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          emit(state.copyWith(status: SubscriptionStatus.success));
        }

        add(Start());
      }
    }
  }

  /* ---------------- RESTORE ---------------- */

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state.status != SubscriptionStatus.loaded) return;

    emit(state.copyWith(status: SubscriptionStatus.restoring));

    try {
      await _iap.restorePurchases().timeout(_restoreTimeout);
      await _iap.isAvailable();
      // результат придёт через purchaseStream; если за таймаут ничего не пришло —
      // возвращаем UI в loaded, чтобы loader не висел вечно.
      if (state.status == SubscriptionStatus.restoring) {
        emit(state.copyWith(status: SubscriptionStatus.loaded));
      }
    } on TimeoutException {
      talker.debug('Restore timed out after ${_restoreTimeout.inSeconds}s');
      emit(
        state.copyWith(
          status: SubscriptionStatus.failure,
          error: 'Nothing to restore',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.failure,
          error: 'Restore failed',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
