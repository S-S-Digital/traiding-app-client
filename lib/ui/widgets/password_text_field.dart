import 'package:aspiro_trade/ui/theme/theme.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          focusNode: passwordFocus,
          controller: passwordController,
          textInputAction: textInputAction,
          keyboardType: TextInputType.text,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          onFieldSubmitted: onFieldSubmitted ??
              (_) => FocusScope.of(context).unfocus(),
          onChanged: onChanged,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter password'),
        ),
      ],
    );
  }
}