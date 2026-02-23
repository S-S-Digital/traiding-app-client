import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.brand,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}