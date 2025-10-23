// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'register_bloc.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();
  bool get isBuildable => true;
  @override
  List<Object> get props => [];
}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

class RegisterFailure extends RegisterState {
  final Object error;
  final DateTime timestamp;

  RegisterFailure({required this.error}) : timestamp = DateTime.now();

  @override
  List<Object> get props => super.props..add(timestamp);
  @override
  bool get isBuildable => false;
}

class RegisterLoaded extends RegisterState {
  const RegisterLoaded({
    required this.email,
    required this.password,
    required this.phone,
    required this.isValid,
  });

  final String email;
  final String password;
  final String phone;
  final bool isValid;

  @override
  List<Object> get props =>
      super.props..addAll([email, password, phone, isValid]);

  RegisterLoaded copyWith({
    String? email,
    String? password,
    String? phone,
    bool? isValid,
  }) {
    return RegisterLoaded(
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      isValid: isValid ?? this.isValid,
    );
  }
}

final class LoginSuccess extends RegisterState {
  @override
  bool get isBuildable => false;
}
