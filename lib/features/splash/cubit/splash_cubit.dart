import 'package:aspiro_trade/repositories/core/core.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final TokenStorage _storage;

  SplashCubit({required TokenStorage storage})
    : _storage = storage,
      super(SplashInitial());

  Future<void> initializeApp() async {
    emit(SplashLoading());

    try {
      // Получаем токены
      final (_, refreshToken) = await _storage.getTokens();

      if (refreshToken == null || refreshToken.isEmpty) {
        emit(const SplashLoaded(false));
        return;
      }

      // Всё ок, авторизован
      emit(const SplashLoaded(true));
    } on UnauthorizedException {
      await _storage.clear();
      emit(const SplashLoaded(false));
    } catch (e) {
      await _storage.clear();
      emit(const SplashLoaded(false));
    }
  }
}
