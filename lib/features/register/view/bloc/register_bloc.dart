import 'package:aspiro_trade/features/login/bloc/bloc.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({required AuthRepositoryI authRepository})
    : _authRepository = authRepository,
      super(RegisterInitial()) {
    on<ChangeEmail>(_onChangeField);
    on<ChangePassword>(_onChangeField);
    on<ChangePhone>(_onChangeField);
  }

  final AuthRepositoryI _authRepository;

  void _onChangeField<T>(RegisterEvent event, Emitter<RegisterState> emit) {
    final currentState = state;
    if (currentState is! RegisterLoaded) return;

    String phone = currentState.phone;
    String email = currentState.email;
    String password = currentState.password;

    
    if (event is ChangeEmail) {
      email = event.email;
    } else if (event is ChangePhone) {
      phone = event.phone;
    } else if (event is ChangePassword) {
      password = event.password;
    }

    
    final isValid = _validateCredentials(
      phone: phone,
      password: password,
      email: email,
    );

    emit(
      currentState.copyWith(
        phone: phone,
        email: email,
        password: password,
        isValid: isValid,
      ),
    );
  }



  bool _validateCredentials({
    required String phone,
    required String password,
    required String email,
  }) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    final isEmailValid = emailRegex.hasMatch(email);
    final isPhoneValid = digits.length == 11;
    final isPasswordValid = password.length >= 6;

    return isEmailValid && isPhoneValid && isPasswordValid;
  }
}
