
part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState({
    this.status = Status.initial,
    this.email = '',
    this.password = '',
    this.error,
  });

  final Status status;
  final String email;
  final String password;
  final Object? error;

  LoginState copyWith({
    Status? status,
    String? email,
    String? password,
    Object? error,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, email, password, error];
}
