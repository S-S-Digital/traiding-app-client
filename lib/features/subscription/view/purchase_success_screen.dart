import 'dart:math' as math;

import 'package:aspiro_trade/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Celebratory, polished result screen shown after a successful purchase /
/// restore. Reusable + localized (RU/EN via [AppLocalizations]).
///
/// Pass [onContinue] to control where the user goes next (the screen never
/// navigates by itself — the caller owns navigation).
class PurchaseSuccessScreen extends StatefulWidget {
  const PurchaseSuccessScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<PurchaseSuccessScreen> createState() => _PurchaseSuccessScreenState();
}

class _PurchaseSuccessScreenState extends State<PurchaseSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro; // one-shot orchestrator
  late final AnimationController _glow; // looping ambient breathing
  late final List<_Confetto> _confetti;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    // Deterministic confetti (fixed seed → consistent, no per-frame allocation).
    final rnd = math.Random(7);
    const palette = [
      AppColors.brand,
      AppColors.brandLight,
      AppColors.warning,
      AppColors.info,
      Color(0xFFFFFFFF),
    ];
    _confetti = List.generate(22, (i) {
      return _Confetto(
        angle: (-math.pi / 2) + (rnd.nextDouble() - 0.5) * math.pi * 1.1,
        velocity: 0.55 + rnd.nextDouble() * 0.55,
        color: palette[i % palette.length],
        size: 4 + rnd.nextDouble() * 5,
        spin: (rnd.nextDouble() - 0.5) * 8,
        drift: (rnd.nextDouble() - 0.5) * 0.4,
      );
    });

    // Kick off after first frame so the entrance is visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _intro.forward();
    });
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _intro.dispose();
    _glow.dispose();
    super.dispose();
  }

  double _interval(double begin, double end, {Curve curve = Curves.easeOut}) {
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, end, curve: curve),
    ).value;
  }

  @override
  Widget build(BuildContext context) {
    final features = <String>[
      AppLocalizations.featureUnlimitedSignals,
      AppLocalizations.featureAdvancedAnalytics,
      AppLocalizations.featureUnlimitedTickers,
      AppLocalizations.featurePriorityAlerts,
    ];

    return PopScope(
      canPop: false, // continue only via the CTA → predictable flow
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // ── Ambient brand glow ──
            AnimatedBuilder(
              animation: _glow,
              builder: (context, _) {
                final t = _glow.value;
                return Positioned(
                  top: -140,
                  left: -60,
                  right: -60,
                  child: Container(
                    height: 420,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.brand.withValues(alpha: 0.10 + t * 0.06),
                          Colors.transparent,
                        ],
                        radius: 0.8,
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── Confetti burst ──
            AnimatedBuilder(
              animation: _intro,
              builder: (context, _) {
                final p = _interval(0.18, 1.0, curve: Curves.easeOut);
                if (p <= 0) return const SizedBox.shrink();
                return Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ConfettiPainter(progress: p, pieces: _confetti),
                    ),
                  ),
                );
              },
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Animated success badge ──
                    AnimatedBuilder(
                      animation: Listenable.merge([_intro, _glow]),
                      builder: (context, _) {
                        final pop = _interval(0.0, 0.45,
                            curve: Curves.elasticOut);
                        final check = _interval(0.28, 0.62);
                        final ring = _interval(0.0, 0.6, curve: Curves.easeOut);
                        return SizedBox(
                          width: 160,
                          height: 160,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Expanding halo ring
                              Opacity(
                                opacity: (1 - ring).clamp(0.0, 1.0) * 0.5,
                                child: Container(
                                  width: 80 + ring * 90,
                                  height: 80 + ring * 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.brand
                                          .withValues(alpha: 0.6),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              // Disc with breathing glow
                              Transform.scale(
                                scale: pop.clamp(0.0, 1.2),
                                child: Container(
                                  width: 104,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF20B26C),
                                        Color(0xFF2DC77A),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.brand.withValues(
                                            alpha: 0.35 + _glow.value * 0.2),
                                        blurRadius: 28 + _glow.value * 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CustomPaint(
                                    painter: _CheckPainter(progress: check),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // ── Headline ──
                    _Reveal(
                      animation: _intro,
                      begin: 0.45,
                      end: 0.7,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: AppColors.textPrimary,
                            height: 1.15,
                          ),
                          children: [
                            TextSpan(text: AppLocalizations.welcomeToPro),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Reveal(
                      animation: _intro,
                      begin: 0.52,
                      end: 0.78,
                      child: Text(
                        AppLocalizations.purchaseSuccessSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Unlocked features card ──
                    _Reveal(
                      animation: _intro,
                      begin: 0.6,
                      end: 0.9,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.brand.withValues(alpha: 0.18),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.whatsUnlocked.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            for (var i = 0; i < features.length; i++) ...[
                              if (i != 0) const SizedBox(height: 12),
                              _FeatureRow(
                                text: features[i],
                                animation: _intro,
                                begin: 0.66 + i * 0.06,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ── CTA ──
                    _Reveal(
                      animation: _intro,
                      begin: 0.78,
                      end: 1.0,
                      child: _GradientButton(
                        label: AppLocalizations.continueToApp,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onContinue();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feature row with staggered reveal ──
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.text,
    required this.animation,
    required this.begin,
  });

  final String text;
  final Animation<double> animation;
  final double begin;

  @override
  Widget build(BuildContext context) {
    return _Reveal(
      animation: animation,
      begin: begin.clamp(0.0, 0.94),
      end: (begin + 0.12).clamp(0.0, 1.0),
      offset: const Offset(14, 0),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_rounded,
                size: 16, color: AppColors.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable fade + slide reveal driven by a shared controller interval ──
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
    this.offset = const Offset(0, 18),
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;
  final Offset offset;

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
            offset: Offset(offset.dx * (1 - t), offset.dy * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ── Pulsing green-gradient CTA (matches paywall checkout button) ──
class _GradientButton extends StatefulWidget {
  const _GradientButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
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
                color: AppColors.brand.withValues(alpha: 0.3),
                blurRadius: 16,
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

// ── Animated checkmark stroke ──
class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final p1 = Offset(w * 0.30, h * 0.52);
    final p2 = Offset(w * 0.44, h * 0.66);
    final p3 = Offset(w * 0.72, h * 0.36);

    // First leg (0 → 0.4 of progress), second leg (0.4 → 1.0)
    final path = Path()..moveTo(p1.dx, p1.dy);
    final firstT = (progress / 0.4).clamp(0.0, 1.0);
    final mid = Offset.lerp(p1, p2, firstT)!;
    path.lineTo(mid.dx, mid.dy);
    if (progress > 0.4) {
      final secondT = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
      final end = Offset.lerp(p2, p3, secondT)!;
      path.lineTo(end.dx, end.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}

// ── Confetti ──
class _Confetto {
  _Confetto({
    required this.angle,
    required this.velocity,
    required this.color,
    required this.size,
    required this.spin,
    required this.drift,
  });

  final double angle;
  final double velocity;
  final Color color;
  final double size;
  final double spin;
  final double drift;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.pieces});
  final double progress;
  final List<_Confetto> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.34);
    final spread = size.shortestSide * 0.9;
    final fade = (1.0 - progress).clamp(0.0, 1.0);

    for (final c in pieces) {
      final dist = c.velocity * spread * progress;
      final dx = origin.dx +
          math.cos(c.angle) * dist +
          c.drift * spread * progress;
      // gravity: pieces arc up then fall
      final dy = origin.dy +
          math.sin(c.angle) * dist +
          progress * progress * spread * 0.9;

      final paint = Paint()..color = c.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(c.spin * progress);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: c.size, height: c.size * 0.6),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
