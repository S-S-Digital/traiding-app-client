import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    super.key,
    required this.passwordFocus,
    required this.passwordController,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
  });

  final FocusNode passwordFocus;
  final TextEditingController passwordController;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: passwordFocus,
      controller: passwordController,
      textInputAction: textInputAction,
      keyboardType: TextInputType.text,
      onFieldSubmitted: onFieldSubmitted ??
          (_) => FocusScope.of(context).unfocus(),
      obscureText: true,
      decoration: InputDecoration(hintText: 'Введите пароль'),
    );
  }
}