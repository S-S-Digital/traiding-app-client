import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({required AuthRepositoryI authRepository})
    : _authRepository = authRepository,
      super(const RegisterState()) {
    on<ChangeEmail>(_onChangeField);
    on<ChangePassword>(_onChangeField);
    on<ChangePhone>(_onChangeField);
    on<Auth>(_register);
    on<Start>((event, emit) {
      emit(state.copyWith(status: Status.loaded));
    });
  }

  final AuthRepositoryI _authRepository;

  void _onChangeField<T>(RegisterEvent event, Emitter<RegisterState> emit) {
    String phone = _normalizePhone(state.phone);
    String email = state.email;
    String password = state.password;

    if (event is ChangeEmail) {
      email = event.email;
    } else if (event is ChangePhone) {
      phone = _normalizePhone(event.phone);
    } else if (event is ChangePassword) {
      password = event.password;
    }

    final isValid = _validateCredentials(
      phone: phone,
      password: password,
      email: email,
    );

    emit(
      state.copyWith(
        phone: phone,
        email: email,
        password: password,
        status: isValid ? Status.submit : Status.loaded,
      ),
    );
  }

  Future<void> _register(Auth event, Emitter<RegisterState> emit) async {
    try {
      await _authRepository.register(
        Register(
          email: event.email,
          password: event.password,
          phone: _normalizePhone(event.phone),
        ),
      );

      emit(state.copyWith(status: Status.success));
    } catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  String _normalizePhone(String phone) {
    // Phone already comes as "+{dialCode}{localDigits}" from PhoneTextField
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    return phone.startsWith('+') ? phone : '+$digits';
  }

  bool _validateCredentials({
    required String phone,
    required String password,
    required String email,
  }) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    final isEmailValid = emailRegex.hasMatch(email);
    // E.164: international numbers are 7-15 digits (including country code)
    final isPhoneValid = digits.length >= 7 && digits.length <= 15;
    final isPasswordValid = password.length >= 6;

    return isEmailValid && isPhoneValid && isPasswordValid;
  }
}
