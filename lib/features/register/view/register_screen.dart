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
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final MaskedTextController phoneController = MaskedTextController(
    mask: '+7(000)-000-00-00',
  );
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final phoneFocus = FocusNode();

  @override
  void initState() {
    context.read<RegisterBloc>().add(Start());
    super.initState();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const WelcomeHeader(
                title: 'Create Account',
                subtitle: 'Join Aspiro Trade today',
              ),
              const SizedBox(height: 32),
              BlocConsumer<RegisterBloc, RegisterState>(
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
                          context.read<RegisterBloc>().add(Start());
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
                    return const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.brand,
                          strokeWidth: 2.5,
                        ),
                      ),
                    );
                  }
                  if (state.status == Status.initial) {
                    return const SizedBox(height: 300);
                  }
                  return Column(
                    children: [
                      EmailTextField(
                        emailFocus: emailFocus,
                        emailController: emailController,
                        passwordFocus: passwordFocus,
                        onChanged: (String value) {
                          bloc.add(ChangeEmail(email: value));
                        },
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      PhoneTextField(
                        phoneController: phoneController,
                        phoneFocus: phoneFocus,
                        onChanged: (String value) {
                          bloc.add(ChangePhone(phone: value));
                        },
                      ),
                      const SizedBox(height: 32),
                      AuthButton(
                        isValid: state.status == Status.submit,
                        text: 'Create Account',
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
                  );
                },
              ),
              const SizedBox(height: 16),
              AuthFooter(
                onPressed: () => AutoRouter.of(context).back(),
                firstText: 'Already have an account?',
                secondText: 'Sign In',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
