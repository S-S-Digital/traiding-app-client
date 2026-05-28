import 'dart:io';
import 'package:aspiro_trade/features/profile/cubit/profile_cubit.dart';
import 'package:aspiro_trade/features/subscription/bloc/subscription_bloc.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlanIndex = -1; // -1 = auto-select annual
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    // Always refresh both subscription data and profile (isPremium)
    context.read<SubscriptionBloc>().add(Start());
    context.read<ProfileCubit>().start();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listenWhen: (prev, curr) =>
            curr.status == SubscriptionStatus.failure ||
            curr.status == SubscriptionStatus.success,
        listener: (context, state) {
          if (state.status == SubscriptionStatus.failure) {
            final error = state.error;
            if (error is AppException) {
              context.handleException(error, context);
            } else {
              showErrorDialog(
                context,
                error?.toString() ?? 'Unknown error',
                AppLocalizations.ok,
                () => Navigator.of(context).pop(),
              );
            }
          }
          if (state.status == SubscriptionStatus.success) {
            HapticFeedback.heavyImpact();
            // Refresh profile to update isPremium immediately
            context.read<ProfileCubit>().start();
            // Reload subscription data so paywall UI updates
            context.read<SubscriptionBloc>().add(Start());
            context.showSuccesDialog(
              title: AppLocalizations.accessGranted,
              message: AppLocalizations.accessGrantedMessage,
              onPressed: () => Navigator.of(context).pop(),
            );
          }
        },
        buildWhen: (prev, curr) => curr.isBuildable,
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: PlatformProgressIndicator());
          }
          if (state.status != SubscriptionStatus.initial) {
            return _buildPaywall(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  ProductDetails? _productFor(SubscriptionState state, SubscriptionPlans plan) {
    final productId = Platform.isIOS ? plan.appleProductId : plan.googleProductId;
    for (final p in state.productDetails) {
      if (p.id == productId) return p;
    }
    return null;
  }

  String _localizedPrice(SubscriptionPlans plan, ProductDetails? product) {
    if (product != null) return product.price;
    final amount = double.tryParse(plan.price) ?? 0;
    try {
      return NumberFormat.currency(
        locale: Platform.localeName,
        name: plan.currency,
      ).format(amount);
    } catch (_) {
      return '${plan.currency} ${plan.price}';
    }
  }

  double? _localizedMonthlyAmount(ProductDetails? product) {
    if (product == null) return null;
    final raw = product.rawPrice;
    if (raw > 0) return raw / 12;
    return null;
  }

  String _localizedMonthlyString(SubscriptionPlans plan, ProductDetails? product) {
    final amount = _localizedMonthlyAmount(product) ??
        ((double.tryParse(plan.price) ?? 0) / 12);
    final currencyCode = product?.currencyCode ?? plan.currency;
    try {
      return NumberFormat.currency(
        locale: Platform.localeName,
        name: currencyCode,
      ).format(amount);
    } catch (_) {
      return '$currencyCode ${amount.toStringAsFixed(2)}';
    }
  }

  Widget _buildPaywall(BuildContext context, SubscriptionState state) {
    final paidPlans = state.plans
        .where((p) => p.price != '0' && p.duration > 0)
        .toList();

    // Sort: annual first (duration desc)
    paidPlans.sort((a, b) => b.duration.compareTo(a.duration));

    // Auto-select annual (first = longest duration)
    if (_selectedPlanIndex == -1 && paidPlans.isNotEmpty) {
      _selectedPlanIndex = 0;
    }

    final hasActivePro = state.subscription != null &&
        state.subscription!.status == 'active' &&
        state.subscription!.endDate.isAfter(DateTime.now());

    final hasTrial = state.subscription != null &&
        state.subscription!.status == 'trial';

    final renewDate = hasActivePro
        ? DateFormat('MMM d, yyyy').format(state.subscription!.endDate)
        : '';

    return SafeArea(
      child: Stack(
        children: [
          // ── Ambient Background Glow ──
          Positioned(
            top: -120,
            left: -40,
            right: -40,
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brand.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  radius: 0.75,
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
            child: Column(
              children: [
                // ── Close button with spring effect ──
                Align(
                  alignment: Alignment.topRight,
                  child: _SpringyCloseButton(
                    onTap: () {
                      AutoRouter.of(context).back();
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // ── Premium 3D Overlapping Credit Cards Paywall Header ──
                const _GlassmorphicSubscriptionPaywallStack(),
                const SizedBox(height: 24),

                // ── Title ──
                if (hasActivePro || hasTrial) ...[
                  Text(
                    hasActivePro ? AppLocalizations.youArePro : '🎉 Trial Active',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasActivePro
                        ? AppLocalizations.subscriptionActiveUntil(renewDate)
                        : AppLocalizations.trialDisclaimer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                  ),
                ] else ...[
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(text: AppLocalizations.upgradeToPro),
                        const TextSpan(text: ' Pro', style: TextStyle(color: AppColors.brand)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.proDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
                const SizedBox(height: 24),

                // ── Trial banner ──
                if (!hasActivePro && !hasTrial) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.card_giftcard_rounded,
                          color: AppColors.brand,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                height: 1.35,
                              ),
                              children: [
                                TextSpan(
                                  text: AppLocalizations.trialFree3Days,
                                  style: const TextStyle(
                                    color: AppColors.brand,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const TextSpan(text: '  ·  '),
                                TextSpan(text: AppLocalizations.trialDisclaimer),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Active Pro badge ──
                if (hasActivePro) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF14241B), Color(0xFF0F1611)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.brand.withValues(alpha: 0.35), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.brand.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.verified_rounded, color: AppColors.brand, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.proActiveBadge,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppLocalizations.autoRenews(renewDate),
                                style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.brand.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.active.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brand,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Manage / Cancel subscription ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        if (Platform.isAndroid) {
                          _launchURL('https://play.google.com/store/account/subscriptions?package=com.aspiro.trade');
                        } else {
                          _launchURL('https://apps.apple.com/account/subscriptions');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        AppLocalizations.isRu ? 'Управление подпиской' : 'Manage Subscription',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Plan cards ──
                if (!hasActivePro && paidPlans.isNotEmpty) ...[
                  ...List.generate(paidPlans.length, (i) {
                    final plan = paidPlans[i];
                    final isSelected = _selectedPlanIndex == i;
                    final isAnnual = plan.duration >= 365;
                    final product = _productFor(state, plan);
                    final displayPrice = _localizedPrice(plan, product);
                    final monthlyPriceStr =
                        isAnnual ? _localizedMonthlyString(plan, product) : null;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedPlanIndex = i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brand.withValues(alpha: 0.05)
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.brand : AppColors.border,
                            width: isSelected ? 1.8 : 1.0,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.brand.withValues(alpha: 0.12),
                                blurRadius: 16,
                                spreadRadius: 0,
                              )
                            else
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Custom elegant Radio button
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.brand : AppColors.textQuaternary,
                                  width: 2,
                                ),
                                color: isSelected ? AppColors.brand : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 13, color: AppColors.background)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            // Plan info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          plan.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isAnnual)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: AppColors.up.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            AppLocalizations.save20,
                                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.up),
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: AppColors.brand.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            AppLocalizations.mostPopular,
                                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.brand),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (isAnnual && monthlyPriceStr != null)
                                    Text(
                                      AppLocalizations.equivalentPerMonth(monthlyPriceStr),
                                      style: const TextStyle(fontSize: 12.5, color: AppColors.up, fontWeight: FontWeight.w600),
                                    )
                                  else
                                    Text(
                                      plan.description,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  displayPrice,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  plan.readableDuration,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),

                  // ── Checkbox ──
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _agreedToTerms = !_agreedToTerms);
                    },
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _agreedToTerms ? AppColors.brand : AppColors.textQuaternary,
                              width: 1.5,
                            ),
                            color: _agreedToTerms ? AppColors.brand : Colors.transparent,
                          ),
                          child: _agreedToTerms
                              ? const Icon(Icons.check, size: 14, color: AppColors.background)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppLocalizations.agreeToTerms,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Premium Checkout button ──
                  _PulsingCheckoutButton(
                    isPurchasing: state.isPurchasing,
                    isEnabled: _agreedToTerms,
                    onTap: () {
                      if (_selectedPlanIndex >= 0 && _selectedPlanIndex < paidPlans.length) {
                        final plan = paidPlans[_selectedPlanIndex];
                        var product = _productFor(state, plan);
                        product ??= state.productDetails.isNotEmpty ? state.productDetails.first : null;
                        if (product != null) {
                          context.read<SubscriptionBloc>().add(PurchasePlan(product));
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Restore ──
                if (!hasActivePro)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: state.isRestoring
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              context.read<SubscriptionBloc>().add(RestorePurchases());
                            },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.brand, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          state.isRestoring ? AppLocalizations.restoring : AppLocalizations.cancelRestore,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.brand),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 18),

                // ── Legal links ──
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    GestureDetector(
                      onTap: () => context.router.push(const TermsOfUseRoute()),
                      child: Text(
                        AppLocalizations.termsOfService,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Text('  ·  ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => context.router.push(const PrivacyPolicyRoute()),
                      child: Text(
                        AppLocalizations.privacyPolicy,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                if (Platform.isIOS) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _launchURL(
                        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
                    child: Text(
                      AppLocalizations.isRu
                          ? 'См. также: Apple Standard EULA'
                          : 'See also: Apple Standard EULA',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Spring-Interactive Close Button ──
class _SpringyCloseButton extends StatefulWidget {
  const _SpringyCloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_SpringyCloseButton> createState() => _SpringyCloseButtonState();
}

class _SpringyCloseButtonState extends State<_SpringyCloseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.elevated,
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

// ── Pulsing Green-Gradient Glassmorphic Checkout Button ──
class _PulsingCheckoutButton extends StatefulWidget {
  const _PulsingCheckoutButton({
    required this.isPurchasing,
    required this.isEnabled,
    required this.onTap,
  });

  final bool isPurchasing;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  State<_PulsingCheckoutButton> createState() => _PulsingCheckoutButtonState();
}

class _PulsingCheckoutButtonState extends State<_PulsingCheckoutButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isEnabled && !widget.isPurchasing;

    return GestureDetector(
      onTapDown: active ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: active ? () => setState(() => _pressed = false) : null,
      onTapUp: active
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.mediumImpact();
              widget.onTap();
            }
          : null,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseVal = _pulseController.value;
          final double scale = active ? (_pressed ? 0.96 : 1.0 + (pulseVal * 0.015)) : 1.0;

          return Transform.scale(
            scale: scale,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(
                        colors: [Color(0xFF20B26C), Color(0xFF2DC77A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: active ? null : AppColors.elevated,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (active)
                    BoxShadow(
                      color: AppColors.brand.withValues(alpha: 0.25 + (pulseVal * 0.15)),
                      blurRadius: 14 + (pulseVal * 6),
                      spreadRadius: 1.0 + (pulseVal * 1.5),
                    ),
                ],
              ),
              child: Center(
                child: widget.isPurchasing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                      )
                    : Text(
                        AppLocalizations.startFreeTrial.toUpperCase(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: active ? AppColors.background : AppColors.textQuaternary,
                          letterSpacing: 0.8,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Overlapping 3D Glassmorphic Credit Cards Subscription Paywall Header ──
class _GlassmorphicSubscriptionPaywallStack extends StatelessWidget {
  const _GlassmorphicSubscriptionPaywallStack();

  @override
  Widget build(BuildContext context) {
    Widget card({
      required String cardType,
      required IconData icon,
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
              width: 210,
              height: 122,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isFront
                      ? [
                          const Color(0xFF142B1F).withValues(alpha: 0.95),
                          const Color(0xFF0F1712).withValues(alpha: 0.95),
                        ]
                      : [
                          const Color(0xFF1B2130).withValues(alpha: 0.9),
                          const Color(0xFF10131B).withValues(alpha: 0.9),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.withValues(alpha: isFront ? 0.35 : 0.15),
                  width: isFront ? 1.2 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isFront ? 0.12 : 0.03),
                    blurRadius: isFront ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(icon, size: 16, color: color),
                        if (isFront)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'VIP ACCESS',
                              style: TextStyle(
                                fontSize: 6.5,
                                fontWeight: FontWeight.w900,
                                color: color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cardType,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: isFront ? 0.95 : 0.45),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '**** **** **** 2026',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: isFront ? 0.5 : 0.25),
                                fontFamily: 'monospace',
                              ),
                            ),
                            Icon(
                              Icons.wifi_rounded,
                              size: 10,
                              color: Colors.white.withValues(alpha: isFront ? 0.25 : 0.1),
                            ),
                          ],
                        ),
                      ],
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
      height: 155,
      width: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // PRO SIGNALS CARD (Bottom)
          card(
            cardType: 'PRO SIGNALS VIP',
            icon: Icons.offline_bolt_rounded,
            color: AppColors.info,
            rotationRad: -0.16,
            scale: 0.88,
            offsetY: -18,
            isFront: false,
          ),

          // VIP NODE CARD (Top)
          card(
            cardType: 'PRO NODE ACCESS',
            icon: Icons.workspace_premium_rounded,
            color: AppColors.brand,
            rotationRad: -0.02,
            scale: 1.0,
            offsetY: 10,
            isFront: true,
          ),
        ],
      ),
    );
  }
}
