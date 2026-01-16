part of 'subscription_bloc.dart';

sealed class SubscriptionState extends Equatable {
  const SubscriptionState();
  bool get isBuildable => true;
  @override
  List<Object?> get props => [];
}

final class SubscriptionInitial extends SubscriptionState {}
final class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionPlans> plans;
  // Данные напрямую из AppStore/GooglePlay (цены, валюта)
  final List<ProductDetails> productDetails;

  const SubscriptionLoaded({
    required this.plans, 
    required this.productDetails
  });

  @override
  List<Object?> get props => [plans, productDetails];
}

class SubscriptionFailure extends SubscriptionState {
  SubscriptionFailure({required this.error}) : timestamp = DateTime.now();
  final Object error;
  final DateTime timestamp;

  @override
  bool get isBuildable => false;
  @override
  List<Object?> get props => [error, timestamp];
}