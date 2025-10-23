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
    on<OnChangedEmail>(_onChangeField);
    on<OnChangedPassword>(_onChangeField);
    on<Auth>(_login);
  }

  final AuthRepositoryI _authRepository;

  void _onChangeField<T>(LoginEvent event, Emitter<LoginState> emit) {
    try {
      final currentState = state;
      if (currentState is! LoginLoaded) return;

      String email = currentState.email;
      String password = currentState.password;

      if (event is OnChangedEmail) {
        email = event.email;
      } else if (event is OnChangedPassword) {
        password = event.password;
      }

      final isValid = _validateCredentials(password: password, email: email);

      emit(
        currentState.copyWith(
          email: email,
          password: password,
          isValid: isValid,
        ),
      );
    } catch (error) {
      emit(LoginFailure(error: error));
    }
  }

  Future<void> _login(Auth event, Emitter<LoginState> emit) async {
    try {
      if (event.email.isEmpty || event.password.isEmpty) {
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

  bool _validateCredentials({required String password, required String email}) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    final isEmailValid = emailRegex.hasMatch(email);

    final isPasswordValid = password.length >= 6;

    return isEmailValid && isPasswordValid;
  }
}
