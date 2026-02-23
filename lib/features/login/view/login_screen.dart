import 'dart:io';
import 'package:aspiro_trade/features/login/bloc/bloc.dart';
import 'package:aspiro_trade/features/login/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<LoginBloc>().add(LoginStart());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == Status.failure) {
              if (state.error is AppException) {
                context.handleException(
                  state.error as AppException,
                  context,
                );
              } else {
                context.showBusinessErrorSnackbar(
                  state.error.toString(),
                  () {
                    context.read<LoginBloc>().add(LoginStart());
                  },
                );
              }
            } else if (state.status == Status.success) {
              AutoRouter.of(context).pushAndPopUntil(
                const HomeRoute(),
                predicate: (value) => false,
              );
            }
          },
          buildWhen: (previous, current) => current.status.isBuildable,
          builder: (context, state) {
            if (state.status == Status.loading) {
              return const Center(child: PlatformProgressIndicator());
            }
            if (state.status == Status.initial) {
              return const SizedBox();
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const WelcomeHeader(
                    title: 'Welcome back',
                    subtitle: 'Sign in to Aspiro Trade',
                  ),
                  const SizedBox(height: 32),
                  EmailTextField(
                    emailFocus: emailFocus,
                    emailController: emailController,
                    passwordFocus: passwordFocus,
                    onChanged: (String value) {
                      context.read<LoginBloc>().add(
                        OnChangedEmail(email: value),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  PasswordTextField(
                    passwordFocus: passwordFocus,
                    passwordController: passwordController,
                    onChanged: (String value) {
                      context.read<LoginBloc>().add(
                        OnChangedPassword(password: value),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ForgotPasswordButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              TalkerScreen(talker: talker),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  AuthButton(
                    isValid: state.status == Status.submit,
                    text: 'Sign In',
                    onPressed: () {
                      if (state.status == Status.submit) {
                        context.read<LoginBloc>().add(
                          Auth(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const DividerWithText(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (Platform.isIOS)
                        SocialsButton(
                          text: 'Apple',
                          picturePath: 'assets/svg/apple_logo.svg',
                          onTap: () {
                            context.read<LoginBloc>().add(
                              LoginWithApple(),
                            );
                          },
                        ),
                      if (Platform.isIOS) const SizedBox(width: 16),
                      if (Platform.isIOS || Platform.isAndroid)
                        SocialsButton(
                          text: 'Google',
                          picturePath: 'assets/svg/google_logo.svg',
                          onTap: () {
                            context.read<LoginBloc>().add(
                              LoginWithGoogle(),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AuthFooter(
                    firstText: "Don't have an account?",
                    secondText: 'Sign Up',
                    onPressed: () => AutoRouter.of(
                      context,
                    ).push(const RegisterRoute()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textQuaternary,
            ),
            children: [
              const TextSpan(text: 'By continuing, you agree to our '),
              TextSpan(
                text: 'Privacy Policy',
                style: const TextStyle(
                  color: AppColors.brand,
                  fontWeight: FontWeight.w500,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    AutoRouter.of(context).push(const PrivacyPolicyRoute());
                  },
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'Terms of Use',
                style: const TextStyle(
                  color: AppColors.brand,
                  fontWeight: FontWeight.w500,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    AutoRouter.of(context).push(const TermsOfUseRoute());
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
