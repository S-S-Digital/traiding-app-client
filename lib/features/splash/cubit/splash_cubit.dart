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

      // Validate session by refreshing the token. Hard-cap it: if anything in
      // the refresh chain stalls (secure storage, a hung platform channel),
      // time out and keep the user logged in rather than hanging the splash.
      try {
        await _authRepository.refresh().timeout(const Duration(seconds: 12));
      } on UnauthorizedException {
        // Refresh token is invalid/revoked — the session is genuinely gone.
        await _storage.clear();
        emit(const SplashLoaded(false));
        return;
      } catch (_) {
        // Transient failure (offline, timeout, 5xx). Do NOT clear the session
        // for a connectivity blip — keep the user logged in with the tokens we
        // already have; the interceptor will refresh once the network returns.
        emit(const SplashLoaded(true));
        return;
      }

      emit(const SplashLoaded(true));
    } on UnauthorizedException {
      await _storage.clear();
      emit(const SplashLoaded(false));
    } catch (e) {
      // We have a refresh token but couldn't validate it due to a transient
      // error — keep the user logged in rather than forcing re-login offline.
      emit(const SplashLoaded(true));
    }
  }
}
