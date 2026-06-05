import 'package:aspiro_trade/ui/localization/app_localizations.dart';
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            AppLocalizations.email.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary.withOpacity(0.8),
              letterSpacing: 0.8,
            ),
          ),
        ),
        TextFormField(
          focusNode: emailFocus,
          controller: emailController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(passwordFocus);
          },
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'you@email.com',
            prefixIcon: const Icon(
              Icons.alternate_email_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
            filled: true,
            fillColor: AppColors.background.withOpacity(0.4),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.down, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.down, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}