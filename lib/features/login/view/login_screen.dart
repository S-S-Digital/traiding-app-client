import 'package:aspiro_trade/features/login/widgets/widgets.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';


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
                        title: 'Добро пожаловать',
                        subtitle: 'Войдите в свой аккаунт',
                      ),

                      SizedBox(height: 10),

                      

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SocialsButton(
                            text: 'Apple',
                            picturePath: 'assets/svg/apple_logo.svg',
                            onTap: () {},
                          ),
                          SocialsButton(
                            text: 'Google',
                            picturePath: 'assets/svg/google_logo.svg',
                            onTap: () {},
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      DividerWithText(),

                      SizedBox(height: 20),

                      EmailTextField(
                        emailFocus: emailFocus,
                        emailController: emailController,
                        passwordFocus: passwordFocus, onChanged: (String value) {  },
                      ),
                      SizedBox(height: 20),
                      PasswordTextField(
                        passwordFocus: passwordFocus,
                        passwordController: passwordController, onChanged: (String value) {  },
                      ),

                      ForgotPasswordButton(onPressed: () {}),

                      AuthButton(text: 'Войти'.toUpperCase(), onPressed: () {}),

                      AuthFooter(
                        firstText: 'Нет аккаунта?',
                        secondText: 'Зарегистрироваться',
                        onPressed: () =>AutoRouter.of(context).push(RegisterRoute()),
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
