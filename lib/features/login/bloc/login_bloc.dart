import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/core/core.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required AuthRepositoryI authRepository})
    : _authRepository = authRepository,
      super(LoginInitial()) {
    on<LoginStart>((event, emit) {
      emit(LoginLoaded(email: '', password: ''));
    });
    on<OnChangedEmail>(_emailChanged);
    on<OnChangedPassword>(_passwordChanged);
    on<Auth>(_login);
  }

  final AuthRepositoryI _authRepository;

  Future<void> _emailChanged(
    OnChangedEmail event,
    Emitter<LoginState> emit,
  ) async {
    try {
      final currentState = state;

      if (currentState is LoginLoaded) {
        final isValid = _validateEmail(event.email);

        emit(currentState.copyWith(email: event.email, isEmailValid: isValid));
      }
      else{
        return;
      }
    } catch (error) {
      emit(LoginFailure(error: error));
    }
  }

  Future<void> _passwordChanged(
    OnChangedPassword event,
    Emitter<LoginState> emit,
  ) async {
    final currentState = state;

    // Обрабатываем только если экран в состоянии ввода
    if (currentState is LoginLoaded) {
      final isValid = event.password.trim().length >= 8;

      emit(
        currentState.copyWith(
          password: event.password,
          isPasswordValid: isValid,
        ),
      );
    } else {
      // Если вдруг не в LoginLoaded, возвращаем форму в рабочее состояние
      return;
    }
  }

  Future<void> _login(Auth event, Emitter<LoginState> emit) async {
    try {
      if(event.email.isEmpty || event.password.isEmpty){
        emit(LoginFailure(error: 'заполните все поля'));
        return;
      }
      await _authRepository.login(
        Login(email: event.email, password: event.password),
      );

      emit(LoginSuccess());
    } on AppException catch (e) {
      emit(LoginFailure(error: e.message));
    } catch (e) {
      emit(LoginFailure(error: 'Неизвестная ошибка: $e'));
    }
  }

  bool _validateEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }
}
