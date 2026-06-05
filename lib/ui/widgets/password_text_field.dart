import 'package:aspiro_trade/ui/localization/app_localizations.dart';
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            AppLocalizations.password.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary.withOpacity(0.8),
              letterSpacing: 0.8,
            ),
          ),
        ),
        TextFormField(
          focusNode: passwordFocus,
          controller: passwordController,
          textInputAction: textInputAction,
          keyboardType: TextInputType.text,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          onFieldSubmitted: onFieldSubmitted ??
              (_) => FocusScope.of(context).unfocus(),
          onChanged: onChanged,
          obscureText: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.enterPassword,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
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