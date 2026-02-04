import 'dart:async';
import 'dart:io';
import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/notifications/notifications.dart';
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc({
    required PaymentsRepositoryI paymentsRepository,
    required NotificationsRepositoryI notificationsRepository,
  }) : _paymentsRepository = paymentsRepository,
       _notificationsRepository = notificationsRepository,
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
  final NotificationsRepositoryI _notificationsRepository;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /* ---------------- START ---------------- */

  Future<void> _onStart(Start event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    try {
      if (!await _iap.isAvailable()) {
        emit(
          state.copyWith(
            status: SubscriptionStatus.failure,
            error: 'Store unavailable',
          ),
        );
        return;
      }

      final plans = await _paymentsRepository.fetchAllPlans();
      final myPlan = await _paymentsRepository.getCurrentSubscription();

      final ids = plans
          .map((p) => Platform.isIOS ? p.appleProductId : p.googleProductId)
          .where((id) => id.isNotEmpty)
          .toSet();

      final response = await _iap.queryProductDetails(ids);

      if (response.error != null) {
        throw Exception(response.error);
      }

      // МЕТА-КОММЕНТАРИЙ: Не блокируем работу, если какой-то ID не найден,
      // просто логируем. Это делает приложение стабильнее при проверке.
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
      talker.error(e);
      emit(state.copyWith(status: SubscriptionStatus.failure, error: e));
    }
  }

  /* ---------------- PURCHASE ---------------- */

  Future<void> _onPurchasePlan(
    PurchasePlan event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      // МЕТА-КОММЕНТАРИЙ: Немедленно уведомляем UI, что процесс пошел.
      // Это уберет претензию Apple "No action followed".
      emit(state.copyWith(status: SubscriptionStatus.purchasing));

      final param = PurchaseParam(productDetails: event.productDetails);

      // ВАЖНО: Мы не ждем результата покупки здесь,
      // результат придет в _onUpdatePurchaseStatus через стрим.
      await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      talker.error('Purchase initiation error: $e');
      if (e is PlatformException && e.code == 'storekit2_purchase_cancelled') {
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
        try {
          if (Platform.isIOS) {
            await _paymentsRepository.applePayments(
              AppleReceipts(
                receiptData: purchase.verificationData.serverVerificationData,
                transactionId: purchase.purchaseID ?? '',
              ),
            );
          } else {
            await _paymentsRepository.googlePayments(
              GoogleReceipts(
                purchaseToken: purchase.verificationData.serverVerificationData,
                productId: purchase.productID,
                packageName: 'com.aspiro.trade',
              ),
            );
          }

          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }

          emit(state.copyWith(status: SubscriptionStatus.success));
          add(Start());
        } catch (e) {
          talker.error('Verification error: $e');
          emit(
            state.copyWith(
              status: SubscriptionStatus.failure,
              error: 'Payment verification failed',
            ),
          );
        }
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
      await _iap.restorePurchases();

      await _iap.isAvailable();
      // результат придёт через purchaseStream
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
