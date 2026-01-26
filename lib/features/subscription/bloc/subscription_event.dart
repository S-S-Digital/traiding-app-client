part of 'subscription_bloc.dart';

sealed class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}


final class Start extends SubscriptionEvent{}

// Событие инициации покупки
final class PurchasePlan extends SubscriptionEvent {
  final ProductDetails productDetails;
  final DateTime timestamp;
   PurchasePlan(this.productDetails) : timestamp = DateTime.now();

  @override

  List<Object> get props => super.props..addAll([productDetails, timestamp]);
}

// Внутреннее событие для обработки потока из магазина
final class UpdatePurchaseStatus extends SubscriptionEvent {
  final List<PurchaseDetails> purchases;
  final DateTime timestamp;
  UpdatePurchaseStatus(this.purchases) : timestamp = DateTime.now();

  @override
  List<Object> get props => super.props..addAll([purchases, timestamp]);
}

final class RestorePurchases extends SubscriptionEvent{}