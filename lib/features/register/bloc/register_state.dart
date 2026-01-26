part of 'register_bloc.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.status = Status.initial,
    this.email = '',
    this.password = '',
    this.phone = '',
    this.error,
  });

  final Status status;
  final String email;
  final String password;
  final String phone;
  final Object? error;

  RegisterState copyWith({
    Status? status,
    String? email,
    String? password,
    String? phone,
    Object? error,
  }) {
    return RegisterState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, email, password, phone, error];
}
