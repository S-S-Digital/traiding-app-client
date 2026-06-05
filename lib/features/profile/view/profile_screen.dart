import 'dart:math' as math;
import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/features/profile/cubit/profile_cubit.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/core/logs/app_logger.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              AppLocalizations.editProfile,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
            centerTitle: true,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                AutoRouter.of(context).back();
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),

          BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileFailure) {
                if (state.error is AppException) {
                  final error = state.error as AppException;
                  context.handleException(error, context);
                }
              }
              if (state is DeleteSuccess) {
                AutoRouter.of(context).pushAndPopUntil(
                  const LoginRoute(),
                  predicate: (value) => false,
                );
              }
            },
            buildWhen: (previous, current) => current.isBuildable,
            builder: (context, state) {
              if (state is ProfileLoaded) {
                final user = state.users;
                final limits = state.limits;
                
                final isAnnual = limits.isPremium && user.premiumUntil != null &&
                    user.premiumUntil!.difference(DateTime.now()).inDays > 60;
                
                final themeColor = isAnnual
                    ? const Color(0xFFD4AF37)
                    : (limits.isPremium ? AppColors.brand : AppColors.info);
                final oppositeColor = limits.isPremium ? AppColors.info : AppColors.brand;

                return SliverToBoxAdapter(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // ── 1. Sleek top radial glow behind avatar ──
                      Positioned(
                        top: -100,
                        child: Container(
                          width: 420,
                          height: 420,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                themeColor.withValues(alpha: 0.08),
                                Colors.transparent,
                              ],
                              radius: 0.65,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),

                            // ── 2. Massive Redesigned Profile Avatar ──
                            GestureDetector(
                              onLongPress: () {
                                HapticFeedback.heavyImpact();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TalkerScreen(talker: talker),
                                  ),
                                );
                              },
                              child: OrbitingProfileAvatar(
                                name: user.email.split('@').first,
                                isPremium: limits.isPremium,
                                isAnnual: isAnnual,
                                imageUrl: 'assets/logo/elon_musk_nft.png',
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── 3. Redesigned Large User Info Block ──
                            Text(
                              user.email.split('@').first,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary.withValues(alpha: 0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                                     // ── 4. Premium Resized PRO Badge ──
                            if (limits.isPremium) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isAnnual
                                        ? [const Color(0xFFD4AF37), const Color(0xFFE8C245)]
                                        : [const Color(0xFF20B26C), const Color(0xFF2DC77A)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isAnnual ? const Color(0xFFD4AF37) : AppColors.brand)
                                          .withValues(alpha: 0.25),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      AppLocalizations.proNodeActive,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),

                            // ── 5. Premium Bank Card ──
                            _ProfileBankCard(
                              isPremium: limits.isPremium,
                              premiumUntil: user.premiumUntil,
                              holderName: user.email.split('@').first,
                              expiryDate: user.premiumUntilFormatted,
                            ),

                            const SizedBox(height: 36),

                            // ── 6. Metrics & Details Header ──
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 12),
                                child: Text(
                                  AppLocalizations.accountMetrics,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white.withValues(alpha: 0.36),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            // ── 7. Gorgeous Separate Glassmorphic Info Tiles with spring scale gestures ──
                            _InfoTile(
                              icon: Icons.email_rounded,
                              iconColor: AppColors.info,
                              label: AppLocalizations.email,
                              value: user.email,
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: user.email));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.card,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    content: Text(
                                      AppLocalizations.emailCopied,
                                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            _InfoTile(
                              icon: Icons.workspace_premium_rounded,
                              iconColor: isAnnual ? const Color(0xFFD4AF37) : AppColors.brand,
                              label: AppLocalizations.plan,
                              value: limits.isPremium
                                  ? (isAnnual ? AppLocalizations.proYear : 'Pro Membership')
                                  : AppLocalizations.free,
                              valueColor: limits.isPremium
                                  ? (isAnnual ? const Color(0xFFD4AF37) : AppColors.brand)
                                  : AppColors.textSecondary,
                              onTap: () {
                                AutoRouter.of(context).push(const SubscriptionRoute());
                              },
                            ),

                            _InfoTile(
                              icon: Icons.show_chart_rounded,
                              iconColor: AppColors.warning,
                              label: AppLocalizations.tickers,
                              value: limits.maxTickers.type == MaxTickersType.unlimited
                                  ? AppLocalizations.unlimited
                                  : '${limits.currentTickers} / ${limits.maxTickers.value}',
                              onTap: () {},
                            ),

                            if (limits.isPremium)
                              _InfoTile(
                                icon: Icons.event_rounded,
                                iconColor: const Color(0xFFFF5A79),
                                label: AppLocalizations.premiumUntil,
                                value: limits.premiumUntilFormatted,
                                onTap: () {},
                              ),

                            const SizedBox(height: 32),

                            // ── 8. Delete Account Button with premium outlines ──
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: () async {
                                  HapticFeedback.heavyImpact();
                                  final isConfirmed = await context.showDeleteAccountDialog(context);
                                  if (!mounted) return;
                                  if (isConfirmed == true) {
                                    context.read<ProfileCubit>().deleteAccount();
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColors.down.withValues(alpha: 0.25),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.deleteAccount,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.down,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state is ProfileLoading || state is ProfileInitial) {
                return const SliverFillRemaining(
                  child: Center(child: PlatformProgressIndicator()),
                );
              }
              return const SliverToBoxAdapter();
            },
          ),
        ],
      ),
    );
  }
}

// ── Highly Polished Glassmorphic List Tiles with Spring Scale gestures ──
class _InfoTile extends StatefulWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback onTap;

  @override
  State<_InfoTile> createState() => _InfoTileState();
}

class _InfoTileState extends State<_InfoTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pressed ? widget.iconColor.withValues(alpha: 0.3) : AppColors.border,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Translucent circular icon background
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.iconColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: widget.iconColor.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 19,
                    color: widget.iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              // Value
              Flexible(
                child: Text(
                  widget.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: widget.valueColor ?? AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile Bank Card (matches subscription screen design) ──
class _ProfileBankCard extends StatefulWidget {
  const _ProfileBankCard({
    required this.isPremium,
    required this.premiumUntil,
    required this.holderName,
    required this.expiryDate,
  });

  final bool isPremium;
  final DateTime? premiumUntil;
  final String holderName;
  final String expiryDate;

  @override
  State<_ProfileBankCard> createState() => _ProfileBankCardState();
}

class _ProfileBankCardState extends State<_ProfileBankCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  bool get _isAnnual {
    if (!widget.isPremium || widget.premiumUntil == null) return false;
    return widget.premiumUntil!.difference(DateTime.now()).inDays > 60;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        if (!widget.isPremium) return _buildFreeCard();
        return _isAnnual ? _buildAnnualCard() : _buildMonthlyCard();
      },
    );
  }

  Widget _buildFreeCard() {
    return _buildCardShell(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A1E26), Color(0xFF12151B), Color(0xFF1A1E26)],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentColor: AppColors.info,
      borderColor: AppColors.info.withValues(alpha: 0.15),
      glowColor: AppColors.info.withValues(alpha: 0.05),
      shimmerColor: Colors.white.withValues(alpha: 0.03),
      badgeText: 'FREE',
      chipBaseColor: const Color(0xFF8B8B8B),
      chipDarkColor: const Color(0xFF555555),
    );
  }

  Widget _buildMonthlyCard() {
    return _buildCardShell(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A2E20), Color(0xFF0D1811), Color(0xFF152818)],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentColor: AppColors.brand,
      borderColor: AppColors.brand.withValues(alpha: 0.22),
      glowColor: AppColors.brand.withValues(alpha: 0.1),
      shimmerColor: AppColors.brand.withValues(alpha: 0.06),
      badgeText: 'PRO',
      chipBaseColor: const Color(0xFFD4AF37),
      chipDarkColor: const Color(0xFF8B6914),
    );
  }

  Widget _buildAnnualCard() {
    return _buildCardShell(
      gradient: const LinearGradient(
        colors: [Color(0xFF2A2213), Color(0xFF1A150B), Color(0xFF261E0E)],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentColor: const Color(0xFFD4AF37),
      borderColor: const Color(0xFFD4AF37).withValues(alpha: 0.25),
      glowColor: const Color(0xFFD4AF37).withValues(alpha: 0.12),
      shimmerColor: const Color(0xFFD4AF37).withValues(alpha: 0.06),
      badgeText: AppLocalizations.proYear,
      chipBaseColor: const Color(0xFFE8C245),
      chipDarkColor: const Color(0xFF8B6914),
    );
  }

  Widget _buildCardShell({
    required LinearGradient gradient,
    required Color accentColor,
    required Color borderColor,
    required Color glowColor,
    required Color shimmerColor,
    required String badgeText,
    required Color chipBaseColor,
    required Color chipDarkColor,
  }) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient,
          border: Border.all(color: borderColor, width: 0.8),
          boxShadow: [
            BoxShadow(color: glowColor, blurRadius: 28, offset: const Offset(0, 10)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 18, offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Shimmer
              Positioned.fill(
                child: CustomPaint(
                  painter: _ProfileShimmerPainter(
                    progress: _shimmerController.value,
                    shimmerColor: shimmerColor,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: Logo + Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo/logo_transparent.png',
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 0.8),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(flex: 2),
                    // EMV Chip
                    Container(
                      width: 40,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [chipBaseColor, chipBaseColor.withValues(alpha: 0.85), chipBaseColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: chipDarkColor.withValues(alpha: 0.5), width: 0.6),
                      ),
                      child: CustomPaint(painter: _ProfileChipPainter(lineColor: chipDarkColor)),
                    ),
                    const Spacer(flex: 2),
                    // Card Number
                    Text(
                      '**** **** **** ****',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.88),
                        letterSpacing: 2.8,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(flex: 2),
                    // Bottom: Name + Expiry
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CARD HOLDER',
                              style: TextStyle(fontSize: 6.5, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.25), letterSpacing: 1.0)),
                            const SizedBox(height: 2),
                            Text(widget.holderName.toUpperCase(),
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: accentColor.withValues(alpha: 0.75), letterSpacing: 1.0, fontFamily: 'monospace')),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('VALID THRU',
                              style: TextStyle(fontSize: 6.5, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.25), letterSpacing: 1.0)),
                            const SizedBox(height: 2),
                            Text(widget.expiryDate,
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.6), letterSpacing: 0.8, fontFamily: 'monospace')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile card painters ──
class _ProfileChipPainter extends CustomPainter {
  _ProfileChipPainter({required this.lineColor});
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()..color = lineColor.withValues(alpha: 0.5)..strokeWidth = 0.6..style = PaintingStyle.stroke;
    final w = size.width; final h = size.height;
    canvas.drawLine(Offset(w * 0.33, h * 0.1), Offset(w * 0.33, h * 0.9), linePaint);
    canvas.drawLine(Offset(w * 0.66, h * 0.1), Offset(w * 0.66, h * 0.9), linePaint);
    canvas.drawLine(Offset(w * 0.08, h * 0.5), Offset(w * 0.92, h * 0.5), linePaint);
    final padPaint = Paint()..color = lineColor.withValues(alpha: 0.18)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06, h * 0.14, w * 0.24, h * 0.3), const Radius.circular(1)), padPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.7, h * 0.14, w * 0.24, h * 0.3), const Radius.circular(1)), padPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06, h * 0.56, w * 0.24, h * 0.3), const Radius.circular(1)), padPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.7, h * 0.56, w * 0.24, h * 0.3), const Radius.circular(1)), padPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProfileShimmerPainter extends CustomPainter {
  _ProfileShimmerPainter({required this.progress, required this.shimmerColor});
  final double progress;
  final Color shimmerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bandWidth = size.width * 0.3;
    final startX = -bandWidth - size.height;
    final endX = size.width + bandWidth + size.height;
    final currentX = startX + (endX - startX) * progress;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.45);
    canvas.translate(-size.width / 2, -size.height / 2);
    final rect = Rect.fromLTWH(currentX, -size.height, bandWidth, size.height * 3);
    final gradient = LinearGradient(
      colors: [Colors.transparent, shimmerColor, shimmerColor, Colors.transparent],
      stops: const [0.0, 0.35, 0.65, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ProfileShimmerPainter old) => old.progress != progress;
}


// ── Massive Redesigned Orbiting Profile Avatar ──
class OrbitingProfileAvatar extends StatefulWidget {
  const OrbitingProfileAvatar({
    super.key,
    required this.name,
    required this.isPremium,
    this.isAnnual = false,
    this.imageUrl,
  });

  final String name;
  final bool isPremium;
  final bool isAnnual;
  final String? imageUrl;

  @override
  State<OrbitingProfileAvatar> createState() => _OrbitingProfileAvatarState();
}

class _OrbitingProfileAvatarState extends State<OrbitingProfileAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isAnnual
        ? const Color(0xFFD4AF37)
        : (widget.isPremium ? AppColors.brand : AppColors.info);
    final oppositeColor = widget.isPremium ? AppColors.info : AppColors.brand;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Soft Static Glow Halo
        Container(
          width: 122,
          height: 122,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.15),
                blurRadius: 24,
                spreadRadius: 2.0,
              ),
            ],
          ),
        ),

        // 2. Rotating Dash Arcs Ring
        RotationTransition(
          turns: _rotationController,
          child: CustomPaint(
            size: const Size(116, 116),
            painter: ProfileTokenRingPainter(
              ringColor: themeColor.withValues(alpha: 0.36),
            ),
          ),
        ),

        // 3. Static Thin Inner Circular Border
        Container(
          width: 106,
          height: 106,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: oppositeColor.withValues(alpha: 0.12),
              width: 1.0,
            ),
          ),
        ),

        // 4. Rounded Avatar/Monogram container
        Container(
          width: 98,
          height: 98,
          padding: const EdgeInsets.all(2.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: widget.isPremium
                    ? [AppColors.brand.withValues(alpha: 0.16), AppColors.brand.withValues(alpha: 0.04)]
                    : [AppColors.elevated, AppColors.card],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                        width: 98,
                        height: 98,
                        errorBuilder: (context, error, stackTrace) => _buildInitials(themeColor, oppositeColor),
                      ),
                    )
                  : _buildInitials(themeColor, oppositeColor),
            ),
          ),
        ),

        // 5. Active Connection/Badge status
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeColor,
              ),
              child: Icon(
                widget.isPremium ? Icons.verified_rounded : Icons.check_circle_rounded,
                size: 14.0,
                color: AppColors.background,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitials(Color themeColor, Color oppositeColor) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [themeColor, oppositeColor.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class ProfileTokenRingPainter extends CustomPainter {
  const ProfileTokenRingPainter({required this.ringColor});
  final Color ringColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ringColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    const segments = 10;
    const sweepAngle = (2 * math.pi / segments) * 0.65;
    const gapAngle = (2 * math.pi / segments) * 0.35;

    for (int i = 0; i < segments; i++) {
      final startAngle = i * (sweepAngle + gapAngle);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ProfileTokenRingPainter oldDelegate) =>
      oldDelegate.ringColor != ringColor;
}
