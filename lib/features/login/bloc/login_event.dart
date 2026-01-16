part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

final class LoginStart extends LoginEvent{}

class OnChangedEmail extends LoginEvent {
  const OnChangedEmail({required this.email});
  final String email;
}

class OnChangedPassword extends LoginEvent {
  const OnChangedPassword({required this.password});
  final String password;
}

class ForgotPassword extends LoginEvent {}

class Auth extends LoginEvent {
  const Auth({required this.email, required this.password});
  final String email;
  final String password;
}


class LoginWithGoogle extends LoginEvent {
}

class LoginWithApple extends LoginEvent {}
