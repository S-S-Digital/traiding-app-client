import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/core/core.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final TokenStorage _storage;
  final AuthRepositoryI _authRepository;

  SplashCubit({
    required TokenStorage storage,
    required AuthRepositoryI authRepository,
  }) : _storage = storage,
       _authRepository = authRepository,
       super(SplashInitial());

  Future<void> initializeApp() async {
    emit(SplashLoading());

    try {
      final (_, refreshToken) = await _storage.getTokens();

      if (refreshToken == null || refreshToken.isEmpty) {
        emit(const SplashLoaded(false));
        return;
      }

      // Validate session by refreshing token
      try {
        await _authRepository.refresh();
      } catch (_) {
        // Refresh failed — session expired
        await _storage.clear();
        emit(const SplashLoaded(false));
        return;
      }

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
