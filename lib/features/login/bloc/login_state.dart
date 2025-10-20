part of 'login_bloc.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

class LoginLoaded extends LoginState {
  final String email;
  final String password;

  const LoginLoaded({required this.email, required this.password});
  @override
  List<Object> get props => super.props..addAll([email, password]);
}

class LoginFailure extends LoginState {
  final Object error;

  const LoginFailure({required this.error});

  @override
  List<Object> get props => super.props..add(error);
}
