
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class PhoneTextField extends StatelessWidget {
  const PhoneTextField({
    super.key,
    required this.phoneController,
    required this.phoneFocus,
  });

  final MaskedTextController phoneController;
  final FocusNode phoneFocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: phoneController,
      focusNode: phoneFocus,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.phone,
      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(hintText: 'Введите номер телефона'),
    );
  }
}