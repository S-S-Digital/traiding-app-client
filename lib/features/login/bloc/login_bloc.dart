import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required AuthRepositoryI authRepository})
    : _authRepository = authRepository,
      super(LoginInitial()) {
    on<LoginStart>((event, emit) async {
      emit(const LoginLoaded(email: '', password: ''));
    });
    on<OnChangedEmail>(_onChangeField);
    on<OnChangedPassword>(_onChangeField);
    on<Auth>(_login);
    on<LoginWithGoogle>(_loginWithGoogle);
    on<LoginWithApple>(_loginWithApple);
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

  Future<void> _loginWithGoogle(
    LoginWithGoogle event,
    Emitter<LoginState> emit,
  ) async {
    try {
      // init();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

    await _authRepository.googleSignIn(
        GoogleAuth(
          provider: 'google.com',
          providerId: credential.providerId,
          email: googleUser.email,
          firstName: googleUser.displayName ?? '',
          lastName: googleUser.displayName ?? '',
          picture: googleUser.photoUrl ?? '',
          accessToken: googleAuth.accessToken ?? '',
        ),
      );

      emit(LoginSuccess());
    } on AppException catch (error) {
      emit(LoginFailure(error: error));
    } catch (error) {
      talker.error(error);
      emit(LoginFailure(error: error));
    }
  }

  Future<void> _loginWithApple(
    LoginWithApple event,
    Emitter<LoginState> emit,
  ) async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      talker.debug(appleCredential.identityToken);
      talker.debug(appleCredential.email);
      talker.debug(appleCredential.familyName);

      talker.debug(appleCredential.userIdentifier);
      talker.debug(appleCredential.familyName);
      talker.debug(appleCredential.givenName);
      talker.debug(oauthCredential.accessToken);

       await _authRepository.appleSignIn(
        AppleAuth(
          provider: 'apple.com',

          // бек хочет providerId → даём стабильный Apple user id
          providerId: appleCredential.userIdentifier ?? '',

          // email / имя — только если есть
          email: appleCredential.email ?? '',
          firstName: appleCredential.givenName ?? '',
          lastName: appleCredential.familyName ?? '',

          // Apple не даёт аватар
          picture: '',

          // accessToken у Apple отсутствует → пустая строка, не null
          accessToken: appleCredential.identityToken ?? '',
        ),
      );

      emit(LoginSuccess());
    } catch (error) {
      talker.debug(error);
      emit(LoginFailure(error: error));
    }
  }

  String _generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _validateCredentials({required String password, required String email}) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    final isEmailValid = emailRegex.hasMatch(email);

    final isPasswordValid = password.length >= 6;

    return isEmailValid && isPasswordValid;
  }
}
