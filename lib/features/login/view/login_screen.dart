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
              context.handleException(
                state.error,
                context,
                kickToLoginOnUnauthorized: false,
              );
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
            return Stack(
              children: [
                // ── Ambient Background Radial Glow 1 (Emerald Brand Green) ──
                Positioned(
                  top: -140,
                  left: -50,
                  right: -50,
                  child: Container(
                    height: 380,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.brand.withOpacity(0.09),
                          Colors.transparent,
                        ],
                        radius: 0.7,
                      ),
                    ),
                  ),
                ),

                // ── Ambient Background Radial Glow 2 (Sapphire/Purple Brand Accent) ──
                Positioned(
                  bottom: -100,
                  right: -80,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.purple.withOpacity(0.06),
                          Colors.transparent,
                        ],
                        radius: 0.75,
                      ),
                    ),
                  ),
                ),

                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      WelcomeHeader(
                        title: AppLocalizations.welcomeBack,
                        subtitle: AppLocalizations.signInSubtitle,
                      ),
                      const SizedBox(height: 32),

                      // ── Premium Form Glass Card ──
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.card,
                              AppColors.elevated.withOpacity(0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.7),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: AppColors.brand.withOpacity(0.03),
                              blurRadius: 40,
                              offset: const Offset(0, 2),
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                            const SizedBox(height: 12),
                            ForgotPasswordButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.card,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    content: Text(
                                      AppLocalizations.forgotPassword,
                                      style: const TextStyle(color: AppColors.textPrimary),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 26),
                            AuthButton(
                              isValid: state.status == Status.submit,
                              text: AppLocalizations.login,
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const DividerWithText(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (Platform.isIOS)
                            SocialsButton(
                              text: 'Apple',
                              picturePath: 'assets/svg/apple_logo.svg',
                              onTap: () {
                                context.read<LoginBloc>().add(LoginWithApple());
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
                      const SizedBox(height: 28),
                      AuthFooter(
                        firstText: AppLocalizations.noAccount,
                        secondText: AppLocalizations.register,
                        onPressed: () => AutoRouter.of(
                          context,
                        ).push(const RegisterRoute()),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
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
              TextSpan(text: AppLocalizations.agreePrefix),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => AutoRouter.of(context).push(const PrivacyPolicyRoute()),
                  child: Text(
                    AppLocalizations.privacyPolicy,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.brand,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              TextSpan(text: AppLocalizations.and),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => AutoRouter.of(context).push(const TermsOfUseRoute()),
                  child: Text(
                    AppLocalizations.termsOfUse,
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
