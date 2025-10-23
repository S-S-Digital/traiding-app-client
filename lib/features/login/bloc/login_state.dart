part of 'login_bloc.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  bool get isBuildable => true;

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {
  @override
  bool get isBuildable => true;
}

class LoginLoaded extends LoginState {
  const LoginLoaded({
    required this.email,
    required this.password,
    this.isValid = false,
  });

  LoginLoaded copyWith({String? email, bool? isValid, String? password}) {
    return LoginLoaded(
      email: email ?? this.email,
      isValid: isValid ?? this.isValid,
      password: password ?? this.password,
    );
  }

  final String email;
  final String password;
  final bool isValid;

  @override
  List<Object> get props => super.props..addAll([email, password, isValid]);
}

class LoginFailure extends LoginState {
  LoginFailure({required this.error}) : timestamp = DateTime.now();
  final Object error;
  final DateTime timestamp;

  @override
  List<Object> get props => [timestamp];

  @override
  bool get isBuildable => false;
}

final class LoginSuccess extends LoginState {
  @override
  bool get isBuildable => false;
}
