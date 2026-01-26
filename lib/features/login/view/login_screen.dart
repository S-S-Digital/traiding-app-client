import 'dart:io';
import 'package:aspiro_trade/features/login/bloc/bloc.dart';
import 'package:aspiro_trade/features/login/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                    buildWhen: (previous, current) =>
                        current.status.isBuildable,
                    builder: (context, state) {
                      if (state.status == Status.loading) {
                        return const Scaffold(
                          body: Center(child: PlatformProgressIndicator()),
                        );
                      } else if (state.status != Status.initial) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const WelcomeHeader(
                              title: 'Добро пожаловать',
                              subtitle: 'Войдите в свой аккаунт',
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

                                // Google показываем и на iOS, и на Android
                                if (Platform.isIOS || Platform.isAndroid)
                                  SocialsButton(
                                    text: 'Google',
                                    picturePath: 'assets/svg/google_logo.svg',
                                    onTap: () async {
                                      context.read<LoginBloc>().add(
                                        LoginWithGoogle(),
                                      );
                                    },
                                  ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            const DividerWithText(),

                            const SizedBox(height: 20),

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
                            const SizedBox(height: 20),
                            PasswordTextField(
                              passwordFocus: passwordFocus,
                              passwordController: passwordController,
                              onChanged: (String value) {
                                context.read<LoginBloc>().add(
                                  OnChangedPassword(password: value),
                                );
                              },
                            ),

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

                            AuthButton(
                              isValid: state.status == Status.submit,
                              text: 'Войти'.toUpperCase(),
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
                            AuthFooter(
                              firstText: 'Нет аккаунта?',
                              secondText: 'Зарегистрироваться',
                              onPressed: () => AutoRouter.of(
                                context,
                              ).push(const RegisterRoute()),
                            ),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Я ознакомлен(а) с '),
                  TextSpan(
                    text: 'Политикой конфиденциальности',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkAccentBlue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        AutoRouter.of(context).push(const PrivacyPolicyRoute());
                      },
                  ),
                  const TextSpan(text: ' и '),
                  TextSpan(
                    text: 'Условиями использования',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkAccentBlue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        AutoRouter.of(context).push(const TermsOfUseRoute());
                      },
                  ),
                  
                ],
              ),
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}
