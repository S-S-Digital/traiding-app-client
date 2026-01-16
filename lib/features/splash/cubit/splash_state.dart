part of 'splash_cubit.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

final class SplashInitial extends SplashState {}


final class SplashLoading extends SplashState {}


final class SplashLoaded extends SplashState {
  final bool isAuthenticated;
  const SplashLoaded(this.isAuthenticated);

  @override
  List<Object> get props => [isAuthenticated];
}


final class SplashError extends SplashState {
  final Object message;
  const SplashError(this.message);

  @override
  List<Object> get props => [message];
}