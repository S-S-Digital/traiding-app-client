import 'dart:io';
import 'package:aspiro_trade/features/login/bloc/bloc.dart';
import 'package:aspiro_trade/features/login/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as siwa;


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
    super.initState();
    context.read<LoginBloc>().add(LoginStart());
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.card,
                          content: Text(
                            'Password reset is coming soon',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
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
                        SizedBox(
                          width: 56,
                          height: 48,
                          child: siwa.SignInWithAppleButton(
                            onPressed: () {
                              context.read<LoginBloc>().add(LoginWithApple());
                            },
                            style: siwa.SignInWithAppleButtonStyle.black,
                            iconAlignment: siwa.IconAlignment.center,
                            text: '',
                            borderRadius: BorderRadius.circular(8),
                          ),
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
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => AutoRouter.of(context).push(const PrivacyPolicyRoute()),
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.brand,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const TextSpan(text: ' and '),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => AutoRouter.of(context).push(const TermsOfUseRoute()),
                  child: const Text(
                    'Terms of Use',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.brand,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
