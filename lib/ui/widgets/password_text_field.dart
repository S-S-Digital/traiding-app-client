import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    super.key,
    required this.passwordFocus,
    required this.passwordController,
    required this.onChanged,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
  });

  final FocusNode passwordFocus;
  final TextEditingController passwordController;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: passwordFocus,
      controller: passwordController,
      textInputAction: textInputAction,
      keyboardType: TextInputType.text,
      onFieldSubmitted: onFieldSubmitted ??
          (_) => FocusScope.of(context).unfocus(),
      onChanged: (value) => onChanged,
      obscureText: true,
      decoration: InputDecoration(hintText: 'Введите пароль'),
    );
  }
}