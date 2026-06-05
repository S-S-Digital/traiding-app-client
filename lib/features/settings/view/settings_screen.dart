import 'dart:async';
import 'dart:math' as math;
import 'package:aspiro_trade/features/settings/bloc/settings_bloc.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
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
            String name = AppLocalizations.defaultUserName;
            bool isPremium = false;
            String premiumUntil = '';
            String appVersion = '1.0.0';

            bool isAnnual = false;
            if (state is SettingsLoaded) {
              email = state.users.email;
              name = state.users.email.split('@').first;
              isPremium = state.users.isPremiumActive;
              premiumUntil = state.users.premiumUntilFormatted;
              appVersion = state.appVersion;
              isAnnual = isPremium && state.users.premiumUntil != null &&
                  state.users.premiumUntil!.difference(DateTime.now()).inDays > 60;
            }

            final themeColor = isAnnual
                ? const Color(0xFFD4AF37)
                : (isPremium ? AppColors.brand : AppColors.info);

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
                      _buildWelcomeHeader(name, email, isPremium, themeColor, premiumUntil, isAnnual: isAnnual),

                      const SizedBox(height: 24),

                      // ── 2. Premium Yield Balance Card with 3D Overlapping Card Stack ──
                      TradingNodeBalanceCard(
                        isPremium: isPremium,
                        obscureBalance: _obscureBalance,
                        onToggleObscure: () => setState(() => _obscureBalance = !_obscureBalance),
                        stats: state is SettingsLoaded ? (state as SettingsLoaded).currentStats : null,
                        category: state is SettingsLoaded ? (state as SettingsLoaded).currentCategory : StatsCategory.all,
                        onToggleCategory: () => context.read<SettingsBloc>().add(ToggleStatsCategory()),
                      ),

                      const SizedBox(height: 24),

                      // ── 3. Quick Navigation Square Action Tiles Deck (Reference 1 style!) ──
                      _buildQuickActionsDeck(context),

                      const SizedBox(height: 28),

                      // ── 4. Trading Results Pipeline & Stats ──
                      _buildTradingResults(
                        state is SettingsLoaded ? (state as SettingsLoaded).currentStats : null,
                        state is SettingsLoaded ? (state as SettingsLoaded).currentCategory : StatsCategory.all,
                      ),

                      const SizedBox(height: 28),

                      // ── Account-level strategy mode selector (Task #4) ──
                      const StrategyModeSelector(),

                      const SizedBox(height: 28),

                      // ── 5. Clean Legal Rows (Reference 2 style!) ──
                      _buildSectionHeader(AppLocalizations.legalSecurity),
                      const SizedBox(height: 6),
                      PremiumOptionRow(
                        icon: Icons.description_outlined,
                        title: AppLocalizations.termsOfUse,
                        onTap: () => context.router.push(const TermsOfUseRoute()),
                      ),
                      PremiumOptionRow(
                        icon: Icons.shield_outlined,
                        title: AppLocalizations.privacyPolicy,
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
                          child: Center(
                            child: Text(
                              AppLocalizations.disconnectSession,
                              style: const TextStyle(
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

  Widget _buildWelcomeHeader(String name, String email, bool isPremium, Color themeColor, String premiumUntil, {bool isAnnual = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              OrbitingTokenAvatar(
                name: name,
                isPremium: isPremium,
                isAnnual: isAnnual,
                imageUrl: 'assets/logo/elon_musk_nft.png',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.welcomeBack}!',
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
                        '${AppLocalizations.proNodeActive} • $premiumUntil',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
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
            title: AppLocalizations.profile,
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
            title: AppLocalizations.subscription,
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
            title: AppLocalizations.language,
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
            title: AppLocalizations.earnFree,
            onTap: () => launchUrl(
              Uri.parse('https://docs.google.com/document/d/1-emJAJQjTSl8Y_crh6LuXqTqzw29J7v364BUC28hFkM/edit?usp=drivesdk'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTradingResults(SignalStats? stats, StatsCategory category) {
    Widget resultRow(
      String title,
      String subtitle,
      String value,
      String detail,
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
            // Icon
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

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),

            // Values
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isPositive ? AppColors.brand : AppColors.down,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
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

    final isRu = AppLocalizations.isRu;
    final winRate = stats?.winRate.toDouble() ?? 0;
    final totalProfit = stats?.totalProfitLossPct.toDouble() ?? 0;
    final avgProfit = stats?.avgProfitLossPct.toDouble() ?? 0;
    final closed = stats?.closed.toInt() ?? 0;
    final active = stats?.active.toInt() ?? 0;
    final profitable = stats?.profitable.toInt() ?? 0;
    final unprofitable = stats?.unprofitable.toInt() ?? 0;

    final categoryLabel = switch (category) {
      StatsCategory.all => isRu ? 'Все активы' : 'All Assets',
      StatsCategory.crypto => isRu ? 'Крипто' : 'Crypto',
      StatsCategory.nonCrypto => isRu ? 'Не крипто' : 'Non-crypto',
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Column(
        key: ValueKey(category),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(isRu ? 'РЕЗУЛЬТАТЫ ТОРГОВЛИ • $categoryLabel' : 'TRADING RESULTS • $categoryLabel'),
          const SizedBox(height: 8),
          resultRow(
            'Win Rate',
            isRu ? '$profitable из $closed ${closed == 1 ? 'сделки' : 'сделок'}' : '$profitable of $closed trades',
            '${winRate.toStringAsFixed(1)}%',
            isRu ? 'Точность' : 'Accuracy',
            winRate >= 50,
            Icons.analytics_rounded,
            AppColors.brand,
          ),
          resultRow(
            isRu ? 'Чистый профит' : 'Net Profit',
            isRu ? 'Общий процент за всё время' : 'Total % all time',
            '${totalProfit >= 0 ? '+' : ''}${totalProfit.toStringAsFixed(2)}%',
            isRu ? 'Сред. ${avgProfit >= 0 ? '+' : ''}${avgProfit.toStringAsFixed(2)}%' : 'Avg ${avgProfit >= 0 ? '+' : ''}${avgProfit.toStringAsFixed(2)}%',
            totalProfit >= 0,
            Icons.trending_up_rounded,
            totalProfit >= 0 ? AppColors.brand : AppColors.down,
          ),
          resultRow(
            isRu ? 'Сделки' : 'Trades',
            isRu ? '$active активных сейчас' : '$active active now',
            '$closed',
            isRu ? 'Закрыто' : 'Closed',
            true,
            Icons.swap_vert_rounded,
            AppColors.info,
          ),
        ],
      ),
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
    this.isAnnual = false,
    this.imageUrl,
  });

  final String name;
  final bool isPremium;
  final bool isAnnual;
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
    final themeColor = widget.isAnnual
        ? const Color(0xFFD4AF37)
        : (widget.isPremium ? AppColors.brand : AppColors.info);
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
                    ? (widget.isAnnual
                        ? [const Color(0xFFD4AF37).withValues(alpha: 0.16), const Color(0xFFD4AF37).withValues(alpha: 0.04)]
                        : [AppColors.brand.withValues(alpha: 0.16), AppColors.brand.withValues(alpha: 0.04)])
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
    this.stats,
    this.category = StatsCategory.all,
    this.onToggleCategory,
  });

  final bool isPremium;
  final bool obscureBalance;
  final VoidCallback onToggleObscure;
  final SignalStats? stats;
  final StatsCategory category;
  final VoidCallback? onToggleCategory;

  @override
  Widget build(BuildContext context) {
    final themeColor = isPremium ? AppColors.brand : AppColors.info;
    final isRu = AppLocalizations.isRu;
    final winRate = stats?.winRate.toDouble() ?? 0;
    final avgProfit = stats?.avgProfitLossPct.toDouble() ?? 0;

    final categoryLabel = switch (category) {
      StatsCategory.all => isRu ? 'Все' : 'All',
      StatsCategory.crypto => isRu ? 'Крипто' : 'Crypto',
      StatsCategory.nonCrypto => isRu ? 'Не крипто' : 'Non-crypto',
    };

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
          // Subtle glow gradient inside card
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
                          Flexible(
                            child: Text(
                              AppLocalizations.estimatedNodeValue,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary.withValues(alpha: 0.8),
                                letterSpacing: 0.8,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                        child: Text(
                          obscureBalance ? '••••••' : '${winRate.toStringAsFixed(1)}%',
                          key: ValueKey('wr_${category}_$obscureBalance'),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Yield indicator
                      Row(
                        children: [
                          Icon(
                            winRate >= 50 ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                            size: 13,
                            color: winRate >= 50 ? AppColors.brand : AppColors.down,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              obscureBalance ? '•••' : (isRu ? 'Точность стратегии' : 'Strategy Accuracy'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: winRate >= 50 ? AppColors.brand : AppColors.down,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: (avgProfit >= 0 ? AppColors.brand : AppColors.down).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                obscureBalance
                                    ? '•••'
                                    : '${avgProfit >= 0 ? '+' : ''}${avgProfit.toStringAsFixed(1)}% ${isRu ? 'сред. профит' : 'avg profit'}',
                                key: ValueKey('ap_${category}_$obscureBalance'),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: avgProfit >= 0 ? AppColors.brand : AppColors.down,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // ── Category toggle button with rotation icon ──
                          if (onToggleCategory != null)
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                onToggleCategory!();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: themeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.sync_rounded, size: 12, color: themeColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      categoryLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: themeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Overlapping 3D card stack — tappable, reorders by category
                GestureDetector(
                  onTap: () {
                    if (onToggleCategory != null) {
                      HapticFeedback.mediumImpact();
                      onToggleCategory!();
                    }
                  },
                  child: _GlassmorphicCardStack(category: category),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overlapping 3D-Style Card Stack — reorders by category ──
class _GlassmorphicCardStack extends StatelessWidget {
  const _GlassmorphicCardStack({this.category = StatsCategory.all});

  final StatsCategory category;

  @override
  Widget build(BuildContext context) {
    Widget card(String symbol, IconData icon, Color color, double rotateRad) {
      return Container(
        width: 86,
        height: 52,
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
        child: Transform.rotate(
          angle: rotateRad,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, size: 13, color: color),
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
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary.withValues(alpha: 0.9),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Define cards: (symbol, icon, color)
    final cryptoCard = card('BINANCE #9', Icons.currency_bitcoin_rounded, AppColors.btc, 0);
    final nonCryptoCard = card('STOCKS', Icons.show_chart_rounded, AppColors.info, 0);
    final smcCard = card('SMC SCAN', Icons.bolt_rounded, AppColors.sol, 0);

    // Order: [bottom, middle, top] — top card = front
    final List<Widget> ordered = switch (category) {
      StatsCategory.all => [smcCard, nonCryptoCard, cryptoCard],
      StatsCategory.crypto => [nonCryptoCard, smcCard, cryptoCard],
      StatsCategory.nonCrypto => [cryptoCard, smcCard, nonCryptoCard],
    };

    // Positions: bottom → middle → top (closer to user)
    final positions = [
      (right: 20.0, top: 0.0, rotate: -0.22),   // bottom
      (right: 10.0, top: 8.0, rotate: -0.12),    // middle
      (right: 0.0, top: 16.0, rotate: -0.02),    // top (front)
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: SizedBox(
        key: ValueKey(category),
        width: 110,
        height: 90,
        child: Stack(
          children: [
            for (int i = 0; i < 3; i++)
              Positioned(
                right: positions[i].right,
                top: positions[i].top,
                child: Transform.rotate(
                  angle: positions[i].rotate,
                  child: ordered[i],
                ),
              ),
          ],
        ),
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
