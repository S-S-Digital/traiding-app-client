part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

final class Start extends RegisterEvent{}

class ChangeEmail extends RegisterEvent {
  const ChangeEmail({required this.email});

  final String email;
}

class ChangePassword extends RegisterEvent {
  const ChangePassword({required this.password});
  final String password;
}

class ChangePhone extends RegisterEvent {
  const ChangePhone({required this.phone});
  final String phone;
}

class Auth extends RegisterEvent {
  const Auth({
    required this.phone,
    required this.password,
    required this.email,
  });
  final String phone;
  final String password;
  final String email;
}


