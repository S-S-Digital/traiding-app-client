import 'package:aspiro_trade/features/register/bloc/bloc.dart';
import 'package:aspiro_trade/features/register/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<RegisterBloc>().add(Start());
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RegisterBloc>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
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
                    title: AppLocalizations.createAccount,
                    subtitle: AppLocalizations.joinSubtitle,
                  ),
                  const SizedBox(height: 32),

                  BlocConsumer<RegisterBloc, RegisterState>(
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
                    buildWhen: (previous, current) =>
                        current.status.isBuildable,
                    builder: (context, state) {
                      return Container(
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
                        child: state.status == Status.loading || state.status == Status.initial
                            ? const SizedBox(
                                height: 260,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.brand,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  EmailTextField(
                                    emailFocus: emailFocus,
                                    emailController: emailController,
                                    passwordFocus: passwordFocus,
                                    onChanged: (String value) {
                                      bloc.add(ChangeEmail(email: value));
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  PasswordTextField(
                                    passwordFocus: passwordFocus,
                                    passwordController: passwordController,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => FocusScope.of(
                                      context,
                                    ).requestFocus(phoneFocus),
                                    onChanged: (String value) {
                                      bloc.add(ChangePassword(password: value));
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  PhoneTextField(
                                    phoneController: phoneController,
                                    phoneFocus: phoneFocus,
                                    onChanged: (String value) {
                                      bloc.add(ChangePhone(phone: value));
                                    },
                                  ),
                                  const SizedBox(height: 28),
                                  AuthButton(
                                    isValid: state.status == Status.submit,
                                    text: AppLocalizations.createAccount,
                                    onPressed: () {
                                      if (state.status == Status.submit) {
                                        bloc.add(
                                          Auth(
                                            phone: phoneController.text.trim(),
                                            password: passwordController.text.trim(),
                                            email: emailController.text.trim(),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  AuthFooter(
                    onPressed: () => AutoRouter.of(context).back(),
                    firstText: AppLocalizations.alreadyHaveAccount,
                    secondText: AppLocalizations.login,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
