import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.onPressed,
    required this.firstText,
    required this.secondText,
  });

  final VoidCallback onPressed;
  final String firstText;
  final String secondText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            firstText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onPressed,
            child: Text(
              secondText,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.brand,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}