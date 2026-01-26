import 'dart:async';
import 'dart:io';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc({required PaymentsRepositoryI paymentsRepository})
    : _paymentsRepository = paymentsRepository,
      super(SubscriptionInitial()) {
    on<Start>(_start);
    on<PurchasePlan>(_onPurchasePlan);
    on<UpdatePurchaseStatus>(_onUpdatePurchaseStatus);

    // Подписываемся на поток покупок сразу при создании Блока
    _subscription = _iap.purchaseStream.listen(
      (purchases) => add(UpdatePurchaseStatus(purchases)),
      // onError: (error) => add(SubscriptionFailure(error: error) ),
    );
    on<RestorePurchases>(_onRestorePurchases);
  }

  final PaymentsRepositoryI _paymentsRepository;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> _start(Start event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      // 1. Получаем планы с вашего бэкенда
      final plans = await _paymentsRepository.fetchAllPlans();

      // 2. Проверяем доступность магазина
      final bool available = await _iap.isAvailable();
      if (!available) {
        throw Exception('Магазин приложений недоступен');
      }

      // 3. Запрашиваем детали продуктов у Apple/Google
      // Берем ID из ваших планов (в зависимости от платформы)
      final Set<String> ids = plans
          .map((p) => Platform.isIOS ? p.appleProductId : p.googleProductId)
          .where((id) => id.isNotEmpty)
          .toSet();

      final productResponse = await _iap.queryProductDetails(ids);

      // 4. Обогащаем планы читаемыми фичами (как было у вас)
      final enrichedPlans = plans.map((plan) {
        return plan.copyWith(features: plan.readableFeatures);
      }).toList();

      emit(
        SubscriptionLoaded(
          plans: enrichedPlans,
          productDetails: productResponse.productDetails,
        ),
      );
    } catch (error) {
      emit(SubscriptionFailure(error: error));
    }
  }

  Future<void> _onPurchasePlan(
    PurchasePlan event,
    Emitter<SubscriptionState> emit,
  ) async {
    final purchaseParam = PurchaseParam(productDetails: event.productDetails);

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      if (e is PlatformException && e.code == 'storekit2_purchase_cancelled') {
        return;
      } else {
        talker.debug(e);
        emit(SubscriptionFailure(error: e));
      }
    }
  }

  Future<void> _onUpdatePurchaseStatus(
    UpdatePurchaseStatus event,
    Emitter<SubscriptionState> emit,
  ) async {
    for (final purchase in event.purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        try {
          if (Platform.isIOS) {
            // Формируем ваш AppleReceipts DTO
            final receipt = AppleReceipts(
              receiptData: purchase.verificationData.serverVerificationData,
              transactionId: purchase.purchaseID ?? '',
            );
            await _paymentsRepository.applePayments(receipt);
          } else {
            // Формируем ваш GoogleReceipts DTO
            final receipt = GoogleReceipts(
              purchaseToken: purchase.verificationData.serverVerificationData,
              productId: purchase.productID,
              packageName:
                  'com.aspiro.trade', // Замените на ваш реальный package name
            );
            await _paymentsRepository.googlePayments(receipt);
          }

          // КРИТИЧНО: Подтверждаем покупку в магазине, чтобы не было возврата денег
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }

          // После успеха можно перезапустить загрузку, чтобы обновить статус пользователя
          add(Start());
        } catch (e) {
          emit(SubscriptionFailure(error: e));
        }
      } else if (purchase.status == PurchaseStatus.error) {
        emit(SubscriptionFailure(error: purchase.error ?? 'Ошибка покупки'));
      }
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! SubscriptionLoaded) return;
      emit(currentState.copyWith(isRestoring: true));

      // Вызываем метод репозитория
      await _iap.restorePurchases();

      // Apple требует, чтобы мы дали фидбек.
      // Если метод завершился без ошибок, говорим пользователю, что запрос отправлен.
      emit(
        const SubscriptionRestoreSuccess(
          'Запрос на восстановление отправлен. Ваши покупки обновятся в ближайшее время.',
        ),
      );

      add(Start());
    } catch (e) {
      talker.error("Restore Error: $e");
      emit(
        SubscriptionFailure(
          error: 'Не удалось восстановить покупки: ${e.toString()}',
        ),
      );
      add(Start()); // Возвращаем UI в рабочее состояние
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
