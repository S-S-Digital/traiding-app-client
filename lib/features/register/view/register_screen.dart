import 'package:aspiro_trade/features/register/bloc/bloc.dart';
import 'package:aspiro_trade/features/register/widgets/widgets.dart';
import 'package:aspiro_trade/router/app_router.dart';

import 'package:aspiro_trade/ui/ui.dart';
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
    final theme = Theme.of(context);
    final bloc = context.read<RegisterBloc>();
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
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WelcomeHeader(
                        title: 'Создать аккаунт',
                        subtitle: 'Присоединяйтесь к нам',
                      ),
                      SizedBox(height: 30),

                      BlocConsumer<RegisterBloc, RegisterState>(
                        listener: (context, state) {
                          if (state is RegisterFailure) {
                            showErrorDialog(context, state.error.toString());
                          } else if (state is RegisterSuccess) {
                            AutoRouter.of(context).pushAndPopUntil(
                              HomeRoute(),
                              predicate: (value) => false,
                            );
                          }
                        },
                        buildWhen: (previous, current) => current.isBuildable,
                        builder: (context, state) {
                          if (state is RegisterLoading) {
                            return SizedBox(
                              height: 300,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,

                                  children: [
                                    PlatformProgressIndicator(),
                                    SizedBox(height: 10),
                                    Text('Загрузка'),
                                  ],
                                ),
                              ),
                            );
                          }
                          if (state is RegisterLoaded) {
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
                                SizedBox(height: 15),
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
                                SizedBox(height: 15),
                                PhoneTextField(
                                  phoneController: phoneController,
                                  phoneFocus: phoneFocus,
                                  onChanged: (String value) {
                                    bloc.add(ChangePhone(phone: value));
                                  },
                                ),
                                SizedBox(height: 30),
                                AuthButton(
                                  isValid: state.isValid,
                                  text: 'зарегистрироваться'.toUpperCase(),
                                  onPressed: () {
                                    if (state.isValid) {
                                      bloc.add(
                                        Auth(
                                          phone: phoneController.text.trim(),
                                          password: passwordController.text
                                              .trim(),
                                          email: emailController.text.trim(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          }
                          return SizedBox(height: 300);
                        },
                      ),

                      AuthFooter(
                        onPressed: () => AutoRouter.of(context).back(),
                        firstText: 'Уже есть аккаунт? ',
                        secondText: 'Войти',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
