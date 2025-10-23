// ignore_for_file: public_member_api_docs, sort_constructors_first
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
    this.isEmailValid = false,
    this.isPasswordValid = false,
  });

  LoginLoaded copyWith({
    String? email,
    bool? isEmailValid,
    String? password,
    bool? isPasswordValid,
  }) {
    return LoginLoaded(
      email: email ?? this.email,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      password: password ?? this.password,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
    );
  }

  final String email;
  final bool isEmailValid;
  final String password;
  final bool isPasswordValid;

  @override
  List<Object> get props =>
      super.props..addAll([email, password, isEmailValid, isPasswordValid]);
}

class LoginFailure extends LoginState {
  final Object error;
  final DateTime timestamp;

  LoginFailure({required this.error}) : timestamp = DateTime.now();

  @override
  List<Object> get props => [timestamp];

  @override

  bool get isBuildable => false;
}



final class LoginSuccess extends LoginState {
  @override
  bool get isBuildable => false;
}
