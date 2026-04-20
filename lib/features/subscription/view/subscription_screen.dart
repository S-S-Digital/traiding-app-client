import 'dart:io';

import 'package:aspiro_trade/features/profile/cubit/profile_cubit.dart';
import 'package:aspiro_trade/features/subscription/bloc/subscription_bloc.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
        child: Column(
          children: [
            // ── Close button ──
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  AutoRouter.of(context).back();
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.elevated,
                  ),
                  child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Crown icon ──
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.brand, AppColors.brandLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brand.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium, size: 30, color: AppColors.background),
            ),
            const SizedBox(height: 16),

            // ── Title ──
            if (hasActivePro || hasTrial) ...[
              Text(
                hasActivePro ? AppLocalizations.youArePro : '🎉 Trial Active',
                style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  letterSpacing: -0.5, color: AppColors.textPrimary,
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
                    fontSize: 26, fontWeight: FontWeight.w800,
                    letterSpacing: -0.5, color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(text: AppLocalizations.upgradeToPro),
                    const TextSpan(text: 'Pro', style: TextStyle(color: AppColors.brand)),
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
            const SizedBox(height: 20),

            // ── Trial banner ──
            if (!hasActivePro && !hasTrial) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.brand.withValues(alpha: 0.12),
                      AppColors.brand.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.brand.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.card_giftcard_rounded, color: AppColors.brand, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.trialFree3Days,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.brand),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.trialDisclaimer,
                            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Active Pro badge ──
            if (hasActivePro) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A2A1F), Color(0xFF162016)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
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
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppColors.brand, letterSpacing: 0.5,
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
                height: 48,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    AppLocalizations.isRu ? 'Управление подпиской' : 'Manage Subscription',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
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
                final monthlyEquivalent = isAnnual
                    ? (double.tryParse(plan.price) ?? 0) / 12
                    : null;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedPlanIndex = i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.brand.withValues(alpha: 0.06)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.brand : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Radio
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.brand : AppColors.textQuaternary,
                              width: 2,
                            ),
                            color: isSelected ? AppColors.brand : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: AppColors.background)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        // Plan info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(plan.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                  const SizedBox(width: 8),
                                  if (isAnnual)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.up.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        AppLocalizations.save20,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.up),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.brand.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        AppLocalizations.mostPopular,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.brand),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              if (isAnnual && monthlyEquivalent != null)
                                Text(
                                  AppLocalizations.equivalentPerMonth('\$${monthlyEquivalent.toStringAsFixed(1)}'),
                                  style: const TextStyle(fontSize: 12, color: AppColors.up, fontWeight: FontWeight.w500),
                                )
                              else
                                Text(plan.description, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${plan.price}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            Text(plan.readableDuration, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),

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
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
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
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Subscribe button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (state.isPurchasing || !_agreedToTerms)
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          if (_selectedPlanIndex >= 0 && _selectedPlanIndex < paidPlans.length) {
                            final plan = paidPlans[_selectedPlanIndex];
                            final productId = Platform.isIOS ? plan.appleProductId : plan.googleProductId;
                            ProductDetails? product;
                            for (final p in state.productDetails) {
                              if (p.id == productId) {
                                product = p;
                                break;
                              }
                            }
                            product ??= state.productDetails.isNotEmpty ? state.productDetails.first : null;
                            if (product != null) {
                              context.read<SubscriptionBloc>().add(PurchasePlan(product));
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: AppColors.background,
                    disabledBackgroundColor: AppColors.elevated,
                    disabledForegroundColor: AppColors.textQuaternary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: state.isPurchasing
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                        )
                      : Text(
                          AppLocalizations.startFreeTrial,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // ── Restore ──
            TextButton(
              onPressed: state.isRestoring
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      context.read<SubscriptionBloc>().add(RestorePurchases());
                    },
              child: Text(
                state.isRestoring ? AppLocalizations.restoring : AppLocalizations.cancelRestore,
                style: const TextStyle(fontSize: 11, color: AppColors.textQuaternary),
              ),
            ),

            // ── Legal ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (Platform.isIOS) {
                      _launchURL('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
                    } else {
                      context.router.push(TermsOfUseRoute());
                    }
                  },
                  child: Text(
                    AppLocalizations.termsOfService,
                    style: const TextStyle(fontSize: 10, color: AppColors.textQuaternary),
                  ),
                ),
                const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.textQuaternary)),
                GestureDetector(
                  onTap: () => context.router.push(PrivacyPolicyRoute()),
                  child: Text(
                    AppLocalizations.privacyPolicy,
                    style: const TextStyle(fontSize: 10, color: AppColors.textQuaternary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
