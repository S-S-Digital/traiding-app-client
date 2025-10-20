import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({
    super.key,
    required this.emailFocus,
    required this.emailController,
    required this.passwordFocus,
  });

  final FocusNode emailFocus;
  final TextEditingController emailController;
  final FocusNode passwordFocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: emailFocus,
      controller: emailController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(passwordFocus);
      },

      decoration: InputDecoration(hintText: 'user@example.com'),
    );
  }
}