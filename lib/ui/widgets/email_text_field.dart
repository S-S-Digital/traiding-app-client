import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({
    super.key,
    required this.emailFocus,
    required this.emailController,
    required this.passwordFocus,
    required this.onChanged,
  });

  final FocusNode emailFocus;
  final TextEditingController emailController;
  final FocusNode passwordFocus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          focusNode: emailFocus,
          controller: emailController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(passwordFocus);
          },
          onChanged: onChanged,
          decoration: const InputDecoration(hintText: 'you@email.com'),
        ),
      ],
    );
  }
}