import 'dart:async';
import 'dart:math' as math;
import 'package:aspiro_trade/features/settings/bloc/settings_bloc.dart';
import 'package:aspiro_trade/features/settings/widgets/widgets.dart';
import 'package:aspiro_trade/features/settings/widgets/language_picker.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _obscureBalance = false;

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(Start());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0.0);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.card,
                  content: Text('Error: ${state.error}', style: const TextStyle(color: AppColors.down)),
                ),
              );
            }
            if (state is Close) {
              context.router.replaceAll([const LoginRoute()]);
            }
          },
          builder: (context, state) {
            String email = '';
            String name = 'User';
            bool isPremium = false;
            String premiumUntil = '';
            String appVersion = '1.0.0';

            if (state is SettingsLoaded) {
              email = state.users.email;
              name = state.users.email.split('@').first;
              isPremium = state.users.isPremiumActive;
              premiumUntil = state.users.premiumUntilFormatted;
              appVersion = state.appVersion;
            }

            final themeColor = isPremium ? AppColors.brand : AppColors.info;

            return Stack(
              children: [
                // ── Premium Ambient Background Radial Glow ──
                Positioned(
                  top: -100,
                  left: -50,
                  right: -50,
                  child: Container(
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          themeColor.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        radius: 0.7,
                      ),
                    ),
                  ),
                ),

                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // ── 1. Top Welcome Greeting Row (Reference 2 style!) ──
                      _buildWelcomeHeader(name, email, isPremium, themeColor, premiumUntil),

                      const SizedBox(height: 24),

                      // ── 2. Premium Yield Balance Card with 3D Overlapping Card Stack ──
                      TradingNodeBalanceCard(
                        isPremium: isPremium,
                        obscureBalance: _obscureBalance,
                        onToggleObscure: () => setState(() => _obscureBalance = !_obscureBalance),
                      ),

                      const SizedBox(height: 24),

                      // ── 3. Quick Navigation Square Action Tiles Deck (Reference 1 style!) ──
                      _buildQuickActionsDeck(context),

                      const SizedBox(height: 28),

                      // ── 4. Active Signal Pipeline & Sparklines (Reference 1 & 2 styles!) ──
                      _buildCopytradingPipeline(),

                      const SizedBox(height: 28),

                      // ── 5. Clean Legal Rows (Reference 2 style!) ──
                      _buildSectionHeader('LEGAL & SECURITY'),
                      const SizedBox(height: 6),
                      PremiumOptionRow(
                        icon: Icons.description_outlined,
                        title: 'Terms of Use',
                        onTap: () => context.router.push(const TermsOfUseRoute()),
                      ),
                      PremiumOptionRow(
                        icon: Icons.shield_outlined,
                        title: 'Privacy Policy',
                        onTap: () => context.router.push(const PrivacyPolicyRoute()),
                      ),

                      const SizedBox(height: 20),

                      // ── 6. Full-Width Disconnect Session Button ──
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => ExitDialog(
                              confirm: () {
                                context.read<SettingsBloc>().add(Exit());
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.down.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.down.withValues(alpha: 0.25),
                              width: 1.2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Disconnect Session',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.down,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),
                      Center(
                        child: Text(
                          'Aspiro Trading Engine v$appVersion',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.2),
                            letterSpacing: 0.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String name, String email, bool isPremium, Color themeColor, String premiumUntil) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              OrbitingTokenAvatar(
                name: name,
                isPremium: isPremium,
                imageUrl: 'assets/logo/elon_musk_nft.png',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isPremium && premiumUntil.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        'PRO node active • $premiumUntil',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brand,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Active Status & Bell Notification button
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.card,
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 19,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsDeck(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickActionTile(
            icon: Icons.person_outline_rounded,
            iconColor: AppColors.brand,
            title: 'Profile',
            onTap: () async {
              await context.router.push(const ProfileRoute());
              if (!context.mounted) return;
              context.read<SettingsBloc>().add(Start());
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: QuickActionTile(
            icon: Icons.stars_rounded,
            iconColor: AppColors.warning,
            title: 'Subscription',
            onTap: () async {
              await context.router.push(const SubscriptionRoute());
              if (!context.mounted) return;
              context.read<SettingsBloc>().add(Start());
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: QuickActionTile(
            icon: Icons.language_rounded,
            iconColor: AppColors.info,
            title: 'Language',
            onTap: () {
              HapticFeedback.mediumImpact();
              showLanguagePicker(context);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: QuickActionTile(
            icon: Icons.wallet_giftcard_rounded,
            iconColor: const Color(0xFFFF5A79),
            title: 'Earn Free',
            onTap: () => launchUrl(
              Uri.parse('https://docs.google.com/document/d/1-emJAJQjTSl8Y_crh6LuXqTqzw29J7v364BUC28hFkM/edit?usp=drivesdk'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCopytradingPipeline() {
    Widget pipelineRow(
      String symbol,
      String allocation,
      List<double> points,
      Color chartColor,
      String earnings,
      String yieldPct,
      bool isPositive,
      IconData icon,
      Color iconColor,
    ) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Row(
          children: [
            // Coin avatar icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.1),
                border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1.0),
              ),
              child: Center(
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ),
            const SizedBox(width: 12),

            // Text titles
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    allocation,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Animated Sparkline Chart (Image 1 style!)
            Expanded(
              flex: 3,
              child: Center(
                child: _AnimatedSparkline(
                  points: points,
                  color: chartColor,
                ),
              ),
            ),
            
            const SizedBox(width: 12),

            // Earnings values
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  earnings,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isPositive ? AppColors.brand : AppColors.down,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  yieldPct,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? AppColors.brand : AppColors.down,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ACTIVE COPYTRADING PIPELINE'),
        const SizedBox(height: 8),
        pipelineRow(
          'Bitcoin Copy Node',
          '1.5x allocation',
          [1.0, 1.15, 0.95, 1.25, 1.4, 1.3, 1.55],
          AppColors.brand,
          '+\$184.20',
          '+5.82%',
          true,
          Icons.currency_bitcoin_rounded,
          AppColors.btc,
        ),
        pipelineRow(
          'Ethereum Copy Node',
          '1.0x allocation',
          [1.4, 1.3, 1.5, 1.2, 1.1, 1.0, 0.95],
          AppColors.down,
          '-\$12.40',
          '-1.14%',
          false,
          Icons.token_rounded,
          AppColors.eth,
        ),
        pipelineRow(
          'Solana Copy Node',
          '2.0x allocation',
          [0.8, 1.0, 0.9, 1.2, 1.35, 1.6, 1.85],
          AppColors.brand,
          '+\$482.50',
          '+12.65%',
          true,
          Icons.bolt_rounded,
          AppColors.sol,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: Colors.white.withValues(alpha: 0.36),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Sleek Orbiting Token Circular Avatar ──
class OrbitingTokenAvatar extends StatefulWidget {
  const OrbitingTokenAvatar({
    super.key,
    required this.name,
    required this.isPremium,
    this.imageUrl,
  });

  final String name;
  final bool isPremium;
  final String? imageUrl;

  @override
  State<OrbitingTokenAvatar> createState() => _OrbitingTokenAvatarState();
}

class _OrbitingTokenAvatarState extends State<OrbitingTokenAvatar> with SingleTickerProviderStateMixin {
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
        // 1. Soft Static Glow Halo (No pulsation!)
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.12),
                blurRadius: 16,
                spreadRadius: 1.0,
              ),
            ],
          ),
        ),

        // 2. Rotating Dash Arcs Ring
        RotationTransition(
          turns: _rotationController,
          child: CustomPaint(
            size: const Size(72, 72),
            painter: TokenRingPainter(
              ringColor: themeColor.withValues(alpha: 0.36),
            ),
          ),
        ),

        // 3. Static Thin Inner Circular Border
        Container(
          width: 64,
          height: 64,
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
          width: 58,
          height: 58,
          padding: const EdgeInsets.all(1.5),
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
                        width: 58,
                        height: 58,
                        errorBuilder: (context, error, stackTrace) => _buildInitials(themeColor, oppositeColor),
                      ),
                    )
                  : _buildInitials(themeColor, oppositeColor),
            ),
          ),
        ),

        // 5. Active Connection/Verified Badge
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            padding: const EdgeInsets.all(1.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeColor,
              ),
              child: Icon(
                widget.isPremium ? Icons.verified_rounded : Icons.check_circle_rounded,
                size: 9.0,
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
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

// ── Segmented Circular Dashed Arc Painter ──
class TokenRingPainter extends CustomPainter {
  const TokenRingPainter({required this.ringColor});
  final Color ringColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ringColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    const segments = 8;
    const sweepAngle = (2 * math.pi / segments) * 0.6; // 60% of segment is arc
    const gapAngle = (2 * math.pi / segments) * 0.4;  // 40% is gap

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
  bool shouldRepaint(covariant TokenRingPainter oldDelegate) =>
      oldDelegate.ringColor != ringColor;
}

// ── Premium Yield Dashboard Card with 3D stacked widgets ──
class TradingNodeBalanceCard extends StatelessWidget {
  const TradingNodeBalanceCard({
    super.key,
    required this.isPremium,
    required this.obscureBalance,
    required this.onToggleObscure,
  });

  final bool isPremium;
  final bool obscureBalance;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    final themeColor = isPremium ? AppColors.brand : AppColors.info;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle glow gradient inside card (Bybit ambient style!)
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    themeColor.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Balance & stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'ESTIMATED NODE VALUE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary.withValues(alpha: 0.8),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onToggleObscure();
                            },
                            child: Icon(
                              obscureBalance
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        obscureBalance ? '••••••' : '\$24,568.25',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Yield indicator
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            size: 13,
                            color: AppColors.brand,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            obscureBalance ? '•••' : '+\$8,450.00',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brand,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.brand.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '+34.2%',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.brand,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Modern Pill Button (Matches View More button in Reference 1!)
                      ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textPrimary,
                          foregroundColor: AppColors.background,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'View More',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Overlapping 3D card stack
                const _GlassmorphicCardStack(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overlapping 3D-Style Copied Node Cards Stack ──
class _GlassmorphicCardStack extends StatelessWidget {
  const _GlassmorphicCardStack();

  @override
  Widget build(BuildContext context) {
    Widget card(String symbol, IconData icon, Color color, double rotateRad, double offsetX, double offsetY) {
      return Transform.translate(
        offset: Offset(offsetX, offsetY),
        child: Transform.rotate(
          angle: rotateRad,
          child: Container(
            width: 90,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.36),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(icon, size: 14, color: color),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.brand.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary.withValues(alpha: 0.9),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 130,
      height: 90,
      child: Stack(
        children: [
          // SOL card (bottom)
          Positioned(
            right: 28,
            top: 0,
            child: card('SOL NODE', Icons.bolt_rounded, AppColors.sol, -0.22, 0, 0),
          ),
          // ETH card (middle)
          Positioned(
            right: 14,
            top: 8,
            child: card('ETH NODE', Icons.token_rounded, AppColors.eth, -0.12, 0, 0),
          ),
          // BTC card (top)
          Positioned(
            right: 0,
            top: 16,
            child: card('BTC NODE', Icons.currency_bitcoin_rounded, AppColors.btc, -0.02, 0, 0),
          ),
        ],
      ),
    );
  }
}

// ── Quick Navigation Rounded Square Action Tile ──
class QuickActionTile extends StatefulWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _pressed ? widget.iconColor.withValues(alpha: 0.4) : AppColors.border,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                // Translucent circle around icon matching Reference 1 Add button!
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.iconColor.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: widget.iconColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom Animated Sparkline Chart Stateful Widget ──
class _AnimatedSparkline extends StatefulWidget {
  const _AnimatedSparkline({required this.points, required this.color});
  final List<double> points;
  final Color color;

  @override
  State<_AnimatedSparkline> createState() => _AnimatedSparklineState();
}

class _AnimatedSparklineState extends State<_AnimatedSparkline> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(64, 28),
          painter: _SparklinePainter(
            points: widget.points,
            color: widget.color,
            animationProgress: _controller.value,
          ),
        );
      },
    );
  }
}

// ── Custom Paint: Sparkline Trend Line and Underglow Fill ──
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.points,
    required this.color,
    required this.animationProgress,
  });

  final List<double> points;
  final Color color;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final double widthStep = size.width / (points.length - 1);
    
    final minVal = points.reduce(math.min);
    final maxVal = points.reduce(math.max);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    double getY(double val) {
      return size.height - ((val - minVal) / range) * size.height;
    }

    path.moveTo(0, getY(points[0]));

    // Only draw up to current animation progress
    final int activePoints = (points.length * animationProgress).clamp(1, points.length).toInt();

    for (int i = 1; i < activePoints; i++) {
      path.lineTo(i * widthStep, getY(points[i]));
    }

    // Smooth interpolation for current drawing point
    if (activePoints < points.length && activePoints > 0) {
      final double prevX = (activePoints - 1) * widthStep;
      final double prevY = getY(points[activePoints - 1]);
      final double nextX = activePoints * widthStep;
      final double nextY = getY(points[activePoints]);
      
      final double currentProgress = (points.length * animationProgress) - activePoints;
      final double curX = prevX + (nextX - prevX) * currentProgress;
      final double curY = prevY + (nextY - prevY) * currentProgress;
      path.lineTo(curX, curY);
    }

    canvas.drawPath(path, paint);
    
    // Draw background gradient under sparkline (image 1 gradient style!)
    final fillPath = Path.from(path);
    fillPath.lineTo((activePoints - 1) * widthStep, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.12),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.animationProgress != animationProgress || oldDelegate.color != color;
}

// ── Clean Premium Legal Option Row ──
class PremiumOptionRow extends StatelessWidget {
  const PremiumOptionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
