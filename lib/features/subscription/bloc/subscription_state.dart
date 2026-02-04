part of 'subscription_bloc.dart';

enum SubscriptionStatus {
  initial,
  loading,
  loaded,
  purchasing,
  restoring,
  success,
  failure,
}



class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.plans = const [],
    this.productDetails = const [],
    this.subscription,
    this.error,
  });

  final SubscriptionStatus status;
  final List<SubscriptionPlans> plans;
  final List<ProductDetails> productDetails;
  final SubscriptionsDto? subscription;
  final Object? error;

  bool get isLoading => status == SubscriptionStatus.loading;
  bool get isPurchasing => status == SubscriptionStatus.purchasing;
  bool get isRestoring => status == SubscriptionStatus.restoring;
  bool get isLoaded => status == SubscriptionStatus.loaded;

  /// UI можно не перестраивать на success / failure
  bool get isBuildable =>
      status != SubscriptionStatus.failure &&
      status != SubscriptionStatus.success;

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    List<SubscriptionPlans>? plans,
    List<ProductDetails>? productDetails,
    SubscriptionsDto? subscription,
    Object? error,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      productDetails: productDetails ?? this.productDetails,
      subscription: subscription ?? this.subscription,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        plans,
        productDetails,
        subscription,
        error,
      ];
}
