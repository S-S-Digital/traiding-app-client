import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthButton extends StatefulWidget {
  const AuthButton({super.key, required this.text, required this.onPressed, required this.isValid});

  final String text;
  final VoidCallback onPressed;
  final bool isValid;

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isValid ? (_) => _controller.forward() : null,
      onTapUp: widget.isValid
          ? (_) {
              _controller.reverse();
              HapticFeedback.mediumImpact();
              widget.onPressed();
            }
          : null,
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: widget.isValid
                ? const LinearGradient(
                    colors: [AppColors.brand, AppColors.brandLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isValid ? null : AppColors.elevated,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isValid
                ? [
                    BoxShadow(
                      color: AppColors.brand.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: widget.isValid
                    ? AppColors.background
                    : AppColors.textQuaternary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
