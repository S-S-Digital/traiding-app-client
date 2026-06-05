import 'dart:io';
import 'dart:math' as math;
import 'package:aspiro_trade/features/profile/cubit/profile_cubit.dart';
import 'package:aspiro_trade/features/subscription/bloc/subscription_bloc.dart';
import 'package:aspiro_trade/features/subscription/view/purchase_error_mapper.dart';
import 'package:aspiro_trade/features/subscription/view/purchase_failure_screen.dart';
import 'package:aspiro_trade/features/subscription/view/purchase_success_screen.dart';
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

  // Tracks a user-initiated purchase/restore so the full-screen result screens
  // only appear for real attempts (initial-load failures stay non-blocking).
  bool _purchaseFlowActive = false;
  // Last product the user tried to buy — enables "Try Again" on the failure screen.
  ProductDetails? _lastProduct;

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

  // ── Purchase result screens ──────────────────────────────────────────────

  void _openResult(BuildContext context, Widget screen) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: AppColors.background,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: child,
        ),
      ),
    );
  }

  void _openSuccessScreen(BuildContext context) {
    _openResult(
      context,
      PurchaseSuccessScreen(
        onContinue: () {
          Navigator.of(context, rootNavigator: true).pop(); // close result
          AutoRouter.of(context).maybePop(); // close paywall → back to app
        },
      ),
    );
  }

  void _openFailureScreen(BuildContext context, Object? error) {
    _openResult(
      context,
      PurchaseFailureScreen(
        message: mapPurchaseError(error), // friendly + localized, never raw
        onRetry: _lastProduct == null
            ? null
            : () {
                Navigator.of(context, rootNavigator: true).pop();
                final product = _lastProduct;
                if (product != null) {
                  _purchaseFlowActive = true;
                  context.read<SubscriptionBloc>().add(PurchasePlan(product));
                }
              },
        onRestore: () {
          Navigator.of(context, rootNavigator: true).pop();
          _purchaseFlowActive = true;
          context.read<SubscriptionBloc>().add(RestorePurchases());
        },
        onContactSupport: _contactSupport,
        onClose: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );
  }

  Future<void> _contactSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppLocalizations.supportEmail,
      query: 'subject=${Uri.encodeComponent(AppLocalizations.supportSubject)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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
          if (state.status == SubscriptionStatus.success) {
            HapticFeedback.heavyImpact();
            // Refresh profile to update isPremium immediately
            context.read<ProfileCubit>().start();
            // Reload subscription data so paywall UI updates
            context.read<SubscriptionBloc>().add(Start());
            _purchaseFlowActive = false;
            _openSuccessScreen(context);
          } else if (state.status == SubscriptionStatus.failure) {
            // Full-screen result only for a real user-initiated purchase/restore.
            // Initial-load failures keep the lightweight, non-blocking handler.
            if (_purchaseFlowActive) {
              _purchaseFlowActive = false;
              _openFailureScreen(context, state.error);
            } else {
              context.handleException(state.error, context);
            }
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
    // Show the store's localized price ONLY when it's a real recurring price.
    // For a subscription with a free-trial offer the store reports the first
    // billing phase (the 3-day trial) with rawPrice == 0 / price == "Free" —
    // showing that as the headline is misleading. Fall back to the recurring
    // backend price; the "3 дня бесплатно" badge already conveys the trial.
    if (product != null && product.rawPrice > 0) return product.price;
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

    // Auto-select monthly (duration < 365) by default
    if (_selectedPlanIndex == -1 && paidPlans.isNotEmpty) {
      final monthlyIdx = paidPlans.indexWhere((p) => p.duration < 365);
      _selectedPlanIndex = monthlyIdx != -1 ? monthlyIdx : 0;
    }

    final hasActivePro = state.subscription != null &&
        state.subscription!.status == 'active' &&
        state.subscription!.endDate.isAfter(DateTime.now());

    final hasTrial = state.subscription != null &&
        state.subscription!.status == 'trial';

    final renewDate = hasActivePro
        ? DateFormat('dd.MM.yyyy').format(state.subscription!.endDate)
        : '';

    final isAnnualSub = state.subscription != null &&
        state.subscription!.status == 'active' &&
        (state.subscription!.plan.duration >= 365 || state.subscription!.endDate.difference(DateTime.now()).inDays > 60);

    final isAnnualSelected = hasActivePro
        ? isAnnualSub
        : (paidPlans.isNotEmpty &&
            _selectedPlanIndex >= 0 &&
            _selectedPlanIndex < paidPlans.length &&
            paidPlans[_selectedPlanIndex].duration >= 365);

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

                // ── Premium 3D Flipping Credit Card Paywall Header ──
                _Futuristic3DSubscriptionCard(
                  isAnnualSelected: isAnnualSelected,
                  holderName: 'sporyshev.savelii',
                  cardNumber: '**** **** **** 2026',
                  expiryDate: '19.06.2026',
                ),
                const SizedBox(height: 24),

                // ── Title ──
                if (hasActivePro || hasTrial) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasActivePro ? AppLocalizations.youArePro : (AppLocalizations.isRu ? 'Пробный период' : 'Trial Active'),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        hasActivePro ? Icons.verified_rounded : Icons.card_giftcard_rounded,
                        color: (hasActivePro && isAnnualSub) ? const Color(0xFFD4AF37) : AppColors.brand,
                        size: 28,
                      ),
                    ],
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
                      gradient: isAnnualSub
                          ? const LinearGradient(
                              colors: [Color(0xFF241F14), Color(0xFF16130F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF14241B), Color(0xFF0F1611)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isAnnualSub ? const Color(0xFFD4AF37) : AppColors.brand).withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (isAnnualSub ? const Color(0xFFD4AF37) : AppColors.brand).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.verified_rounded,
                            color: isAnnualSub ? const Color(0xFFD4AF37) : AppColors.brand,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAnnualSub
                                    ? (AppLocalizations.isRu ? 'Pro план на год активен' : 'Pro Year Plan Active')
                                    : AppLocalizations.proActiveBadge,
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
                            color: (isAnnualSub ? const Color(0xFFD4AF37) : AppColors.brand).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.active.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isAnnualSub ? const Color(0xFFD4AF37) : AppColors.brand,
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
                        AppLocalizations.manageSubscription,
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
                        // Buy ONLY the product matching the selected plan. Do NOT
                        // fall back to productDetails.first — that charged the user
                        // for the WRONG plan (e.g. Monthly when Annual was selected)
                        // whenever the selected plan's product failed to load.
                        final product = _productFor(state, plan);
                        if (product != null) {
                          _lastProduct = product;
                          _purchaseFlowActive = true;
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
                              _purchaseFlowActive = true;
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
                      AppLocalizations.seeAlsoAppleEula,
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

// ── Premium 3D Flipping Bank Card ──
class _Futuristic3DSubscriptionCard extends StatefulWidget {
  const _Futuristic3DSubscriptionCard({
    required this.isAnnualSelected,
    required this.holderName,
    required this.cardNumber,
    required this.expiryDate,
  });

  final bool isAnnualSelected;
  final String holderName;
  final String cardNumber;
  final String expiryDate;

  @override
  State<_Futuristic3DSubscriptionCard> createState() =>
      _Futuristic3DSubscriptionCardState();
}

class _Futuristic3DSubscriptionCardState
    extends State<_Futuristic3DSubscriptionCard>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
    if (widget.isAnnualSelected) _flipController.value = 1.0;

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant _Futuristic3DSubscriptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnnualSelected != oldWidget.isAnnualSelected) {
      widget.isAnnualSelected
          ? _flipController.forward()
          : _flipController.reverse();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flipAnimation, _shimmerController]),
      builder: (context, _) {
        final angle = _flipAnimation.value;
        final isFront = angle < math.pi / 2;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: isFront
              ? _buildMonthlyCard()
              : Transform(
                  transform: Matrix4.identity()..rotateY(math.pi),
                  alignment: Alignment.center,
                  child: _buildAnnualCard(),
                ),
        );
      },
    );
  }

  // ── Monthly PRO Card (Green) ──
  Widget _buildMonthlyCard() {
    return _SubscriptionBankCard(
      shimmerProgress: _shimmerController.value,
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
      holderName: widget.holderName,
      cardNumber: widget.cardNumber,
      expiryDate: widget.expiryDate,
      chipStyle: _ChipStyle.standard,
    );
  }

  // ── Annual VIP Card (Gold) ──
  Widget _buildAnnualCard() {
    return _SubscriptionBankCard(
      shimmerProgress: _shimmerController.value,
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
      holderName: widget.holderName,
      cardNumber: widget.cardNumber,
      expiryDate: widget.expiryDate,
      chipStyle: _ChipStyle.gold,
    );
  }
}

// ── Chip visual style ──
enum _ChipStyle { standard, gold }

// ── Reusable Bank Card Widget ──
class _SubscriptionBankCard extends StatelessWidget {
  const _SubscriptionBankCard({
    required this.shimmerProgress,
    required this.gradient,
    required this.accentColor,
    required this.borderColor,
    required this.glowColor,
    required this.shimmerColor,
    required this.badgeText,
    required this.holderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.chipStyle,
  });

  final double shimmerProgress;
  final LinearGradient gradient;
  final Color accentColor;
  final Color borderColor;
  final Color glowColor;
  final Color shimmerColor;
  final String badgeText;
  final String holderName;
  final String cardNumber;
  final String expiryDate;
  final _ChipStyle chipStyle;

  @override
  Widget build(BuildContext context) {
    final isGold = chipStyle == _ChipStyle.gold;
    final chipBaseColor = isGold ? const Color(0xFFE8C245) : const Color(0xFFD4AF37);
    final chipDarkColor = isGold ? const Color(0xFF8B6914) : const Color(0xFF8B6914);

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
              // Shimmer sweep
              Positioned.fill(
                child: CustomPaint(
                  painter: _ShimmerPainter(progress: shimmerProgress, shimmerColor: shimmerColor),
                ),
              ),
              // Card content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top Row: Logo + Badge ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Aspiro Trade logo (PNG transparent)
                        Image.asset(
                          'assets/logo/logo_transparent.png',
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                        // Badge
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
                    // ── EMV Chip ──
                    Container(
                      width: 40,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            chipBaseColor,
                            chipBaseColor.withValues(alpha: 0.85),
                            chipBaseColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: chipDarkColor.withValues(alpha: 0.5), width: 0.6),
                      ),
                      child: CustomPaint(painter: _ChipContactsPainter(lineColor: chipDarkColor)),
                    ),
                    const Spacer(flex: 2),
                    // ── Card Number ──
                    Text(
                      cardNumber,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.88),
                        letterSpacing: 2.8,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(flex: 2),
                    // ── Bottom Row: Name + Expiry ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARD HOLDER',
                              style: TextStyle(
                                fontSize: 6.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.25),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              holderName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: accentColor.withValues(alpha: 0.75),
                                letterSpacing: 1.0,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'VALID THRU',
                              style: TextStyle(
                                fontSize: 6.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.25),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              expiryDate,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.6),
                                letterSpacing: 0.8,
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
    );
  }
}

// ═══════════════════════════════════════════════
// ── Custom Painters ──
// ═══════════════════════════════════════════════

/// EMV chip contact grid
class _ChipContactsPainter extends CustomPainter {
  _ChipContactsPainter({required this.lineColor});
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.5)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Vertical dividers
    canvas.drawLine(Offset(w * 0.33, h * 0.1), Offset(w * 0.33, h * 0.9), linePaint);
    canvas.drawLine(Offset(w * 0.66, h * 0.1), Offset(w * 0.66, h * 0.9), linePaint);
    // Horizontal divider
    canvas.drawLine(Offset(w * 0.08, h * 0.5), Offset(w * 0.92, h * 0.5), linePaint);

    // Contact pads
    final padPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06, h * 0.14, w * 0.24, h * 0.3), const Radius.circular(1)), padPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.7, h * 0.14, w * 0.24, h * 0.3), const Radius.circular(1)), padPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06, h * 0.56, w * 0.24, h * 0.3), const Radius.circular(1)), padPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.7, h * 0.56, w * 0.24, h * 0.3), const Radius.circular(1)), padPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated diagonal shimmer light sweep
class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({required this.progress, required this.shimmerColor});
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
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}

