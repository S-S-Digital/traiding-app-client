import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialsButton extends StatelessWidget {
  const SocialsButton({
    super.key,
    required this.text,
    required this.picturePath,
    required this.onTap,
  });
  final String picturePath;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Center(
          child: SvgPicture.asset(picturePath, height: 22, width: 22),
        ),
      ),
    );
  }
}
