import 'package:aspiro_trade/features/register/widgets/widgets.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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

                      EmailTextField(
                        emailFocus: emailFocus,
                        emailController: emailController,
                        passwordFocus: passwordFocus,
                        onChanged: (String value) {},
                      ),
                      SizedBox(height: 15),
                      PasswordTextField(
                        passwordFocus: passwordFocus,
                        passwordController: passwordController,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(phoneFocus),
                        onChanged: (String value) {},
                      ),
                      SizedBox(height: 15),
                      PhoneTextField(
                        phoneController: phoneController,
                        phoneFocus: phoneFocus,
                      ),
                      SizedBox(height: 30),
                      AuthButton(
                        isValid: false,
                        text: 'зарегистрироваться'.toUpperCase(),
                        onPressed: () {
                          AutoRouter.of(context).pushAndPopUntil(
                            HomeRoute(),
                            predicate: (value) => false,
                          );
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
