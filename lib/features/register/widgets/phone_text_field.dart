import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class PhoneTextField extends StatelessWidget {
  const PhoneTextField({
    super.key,
    required this.phoneController,
    required this.phoneFocus,
    required this.onChanged,
  });

  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: phoneController,
          focusNode: phoneFocus,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          onChanged: onChanged,
          onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
          decoration: const InputDecoration(hintText: '+1 234 567 8900'),
        ),
      ],
    );
  }
}
