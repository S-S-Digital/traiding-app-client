// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  final bool isRestoring;

  const SubscriptionLoaded({
    required this.plans, 
    required this.productDetails,
    this.isRestoring = false
  });

  @override
  List<Object?> get props => [plans, productDetails, isRestoring];

  SubscriptionLoaded copyWith({
    List<SubscriptionPlans>? plans,
    List<ProductDetails>? productDetails,
    bool? isRestoring,
  }) {
    return SubscriptionLoaded(
      plans: plans ?? this.plans,
      productDetails: productDetails ?? this.productDetails,
      isRestoring: isRestoring ?? this.isRestoring,
    );
  }
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

class SubscriptionPurchasing extends SubscriptionState {
  @override
  bool get isBuildable => true;
}

final class SubscriptionRestoreSuccess extends SubscriptionState {
  final String message;
  const SubscriptionRestoreSuccess(this.message);
  
  @override
  bool get isBuildable => false; // Нам не нужно перерисовывать экран, только показать уведомление
  @override
  List<Object?> get props => [message];
}