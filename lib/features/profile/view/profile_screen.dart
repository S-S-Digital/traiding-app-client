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
                final themeColor = limits.isPremium ? AppColors.brand : AppColors.info;
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
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF20B26C),
                                      Color(0xFF2DC77A),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.brand.withValues(alpha: 0.25),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'PRO NODE ACTIVE',
                                      style: TextStyle(
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

                            // ── 5. Premium Overlapping 3D Credit Card Stack Centerpiece ──
                            const _GlassmorphicSubscriptionCardStack(
                              holderName: 'sporyshev.savelii',
                              cardNumber: '**** **** **** 2026',
                              expiryDate: '19.06.2026',
                            ),

                            const SizedBox(height: 36),

                            // ── 6. Metrics & Details Header ──
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 12),
                                child: Text(
                                  'ACCOUNT METRICS & DETAILS'.toUpperCase(),
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
                                    content: const Text(
                                      'Email copied to clipboard',
                                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            _InfoTile(
                              icon: Icons.workspace_premium_rounded,
                              iconColor: AppColors.brand,
                              label: AppLocalizations.plan,
                              value: limits.isPremium ? 'Pro Membership' : AppLocalizations.free,
                              valueColor: limits.isPremium ? AppColors.brand : AppColors.textSecondary,
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

// ── Overlapping 3D Glassmorphic Credit Card Stack Centerpiece ──
class _GlassmorphicSubscriptionCardStack extends StatelessWidget {
  const _GlassmorphicSubscriptionCardStack({
    required this.holderName,
    required this.cardNumber,
    required this.expiryDate,
  });

  final String holderName;
  final String cardNumber;
  final String expiryDate;

  @override
  Widget build(BuildContext context) {
    Widget creditCard({
      required String cardType,
      required Color color,
      required double rotationRad,
      required double scale,
      required double offsetY,
      required bool isFront,
    }) {
      return Transform.translate(
        offset: Offset(0, offsetY),
        child: Transform.rotate(
          angle: rotationRad,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 290,
              height: 172,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isFront
                      ? [
                          const Color(0xFF122A1D).withValues(alpha: 0.95),
                          const Color(0xFF0C1611).withValues(alpha: 0.95),
                        ]
                      : [
                          const Color(0xFF1B202E).withValues(alpha: 0.88),
                          const Color(0xFF10121A).withValues(alpha: 0.88),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: color.withValues(alpha: isFront ? 0.35 : 0.15),
                  width: isFront ? 1.2 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isFront ? 0.12 : 0.04),
                    blurRadius: isFront ? 24 : 10,
                    spreadRadius: isFront ? 2.0 : 0.0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    // Corner mesh light accent
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              color.withValues(alpha: isFront ? 0.12 : 0.03),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top row: Logo & Status indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color.withValues(alpha: 0.2),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isFront ? Icons.verified_user_rounded : Icons.cloud_done_rounded,
                                        size: 10,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    cardType,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white.withValues(alpha: isFront ? 0.9 : 0.5),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              if (isFront)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
                                  ),
                                  child: Text(
                                    'VIP MEMBER',
                                    style: TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w900,
                                      color: color,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Center row: Brass Gold Chip & Contactless indicator
                          if (isFront)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Gold Chip UI
                                Container(
                                  width: 32,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC5A862).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFC5A862).withValues(alpha: 0.4),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 8, right: 8, top: 0, bottom: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(color: const Color(0xFFC5A862).withValues(alpha: 0.3)),
                                              right: BorderSide(color: const Color(0xFFC5A862).withValues(alpha: 0.3)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8, bottom: 8, left: 0, right: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(color: const Color(0xFFC5A862).withValues(alpha: 0.3)),
                                              bottom: BorderSide(color: const Color(0xFFC5A862).withValues(alpha: 0.3)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // WiFi-like contactless icon
                                Transform.rotate(
                                  angle: math.pi / 2,
                                  child: Icon(
                                    Icons.wifi_rounded,
                                    size: 16,
                                    color: Colors.white.withValues(alpha: 0.36),
                                  ),
                                ),
                              ],
                            )
                          else
                            const SizedBox(height: 24),

                          // Bottom row: Card credentials
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cardNumber,
                                style: TextStyle(
                                  fontSize: isFront ? 14.5 : 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withValues(alpha: isFront ? 0.95 : 0.45),
                                  letterSpacing: 1.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    holderName,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withValues(alpha: isFront ? 0.7 : 0.3),
                                      letterSpacing: 0.5,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  Text(
                                    'EXP $expiryDate',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withValues(alpha: isFront ? 0.6 : 0.25),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
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
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      width: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // SOL SECURE BACKUP CARD (Bottom)
          creditCard(
            cardType: 'SECURE BACKUP NODE',
            color: AppColors.info,
            rotationRad: -0.16,
            scale: 0.88,
            offsetY: -22,
            isFront: false,
          ),

          // PRO NODE MEMBERSHIP CARD (Top)
          creditCard(
            cardType: 'PRO MEMBERSHIP',
            color: AppColors.brand,
            rotationRad: -0.02,
            scale: 1.0,
            offsetY: 8,
            isFront: true,
          ),
        ],
      ),
    );
  }
}

// ── Massive Redesigned Orbiting Profile Avatar ──
class OrbitingProfileAvatar extends StatefulWidget {
  const OrbitingProfileAvatar({
    super.key,
    required this.name,
    required this.isPremium,
    this.imageUrl,
  });

  final String name;
  final bool isPremium;
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
    final themeColor = widget.isPremium ? AppColors.brand : AppColors.info;
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
