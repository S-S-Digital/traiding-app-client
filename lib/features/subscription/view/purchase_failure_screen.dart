import 'package:aspiro_trade/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Calm, non-alarming result screen shown after a failed purchase / restore.
/// Reusable + localized (RU/EN via [AppLocalizations]).
///
/// [message] MUST already be a friendly, mapped string (see `mapPurchaseError`)
/// — never raw backend / store text.
///
/// The screen owns no navigation: every action is a callback supplied by the
/// caller. [onRetry] may be null (e.g. a restore failure) — the Try Again
/// button is then hidden.
class PurchaseFailureScreen extends StatefulWidget {
  const PurchaseFailureScreen({
    super.key,
    required this.message,
    required this.onRestore,
    required this.onContactSupport,
    required this.onClose,
    this.onRetry,
  });

  final String message;
  final VoidCallback onRestore;
  final VoidCallback onContactSupport;
  final VoidCallback onClose;
  final VoidCallback? onRetry;

  @override
  State<PurchaseFailureScreen> createState() => _PurchaseFailureScreenState();
}

class _PurchaseFailureScreenState extends State<PurchaseFailureScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _breathe;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _intro.forward();
    });
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _intro.dispose();
    _breathe.dispose();
    super.dispose();
  }

  double _at(double begin, double end, {Curve curve = Curves.easeOutCubic}) {
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, end, curve: curve),
    ).value;
  }

  @override
  Widget build(BuildContext context) {
    // Calm, neutral amber tone — deliberately NOT the harsh error red.
    const accent = AppColors.warning;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Soft ambient glow ──
          AnimatedBuilder(
            animation: _breathe,
            builder: (context, _) {
              final t = _breathe.value;
              return Positioned(
                top: -140,
                left: -60,
                right: -60,
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.06 + t * 0.04),
                        Colors.transparent,
                      ],
                      radius: 0.8,
                    ),
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                children: [
                  // ── Close ──
                  Align(
                    alignment: Alignment.topRight,
                    child: _CloseButton(onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onClose();
                    }),
                  ),

                  const Spacer(flex: 2),

                  // ── Calm animated icon ──
                  AnimatedBuilder(
                    animation: Listenable.merge([_intro, _breathe]),
                    builder: (context, _) {
                      final pop = _at(0.0, 0.5, curve: Curves.easeOutBack);
                      final breathe = 1.0 + _breathe.value * 0.04;
                      return Transform.scale(
                        scale: pop.clamp(0.0, 1.1) * breathe,
                        child: Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.12),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.30),
                              width: 1.4,
                            ),
                          ),
                          child: Icon(
                            Icons.sentiment_dissatisfied_rounded,
                            size: 52,
                            color: accent.withValues(alpha: 0.95),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // ── Title ──
                  _Reveal(
                    animation: _intro,
                    begin: 0.3,
                    end: 0.6,
                    child: Text(
                      AppLocalizations.purchaseFailedTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Reveal(
                    animation: _intro,
                    begin: 0.4,
                    end: 0.72,
                    child: Text(
                      widget.message, // already mapped → friendly + localized
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── Actions ──
                  if (widget.onRetry != null)
                    _Reveal(
                      animation: _intro,
                      begin: 0.6,
                      end: 0.85,
                      child: _PrimaryButton(
                        label: AppLocalizations.retryPayment,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onRetry!();
                        },
                      ),
                    ),
                  if (widget.onRetry != null) const SizedBox(height: 12),

                  _Reveal(
                    animation: _intro,
                    begin: 0.66,
                    end: 0.9,
                    child: _OutlineButton(
                      label: AppLocalizations.restorePurchase,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onRestore();
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  _Reveal(
                    animation: _intro,
                    begin: 0.72,
                    end: 0.95,
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onContactSupport();
                      },
                      child: Text(
                        AppLocalizations.contactSupport,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top-right close button ──
class _CloseButton extends StatefulWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.elevated,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: const Icon(Icons.close_rounded,
              size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

// ── Primary (brand) button ──
class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF20B26C), Color(0xFF2DC77A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withValues(alpha: 0.25),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label.toUpperCase(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.background,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Outline button ──
class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable fade + slide reveal ──
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final t = curved.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
