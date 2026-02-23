import 'dart:io';

import 'package:aspiro_trade/features/subscription/bloc/subscription_bloc.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlanIndex = -1;

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(Start());
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
                error?.toString() ?? 'Неизвестная ошибка',
                'OK',
                () => Navigator.of(context).pop(),
              );
            }
          }
          if (state.status == SubscriptionStatus.success) {
            context.showSuccesDialog(
              title: 'Доступ открыт!',
              message:
                  'Спасибо, что выбрали нас! Теперь вы — PRO-пользователь.',
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
    // Find pro plan (last one)
    final proPlan =
        state.plans.isNotEmpty ? state.plans.last : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
        child: Column(
          children: [
            // ── Close button ──
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => AutoRouter.of(context).back(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.card,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Crown ──
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.brand, AppColors.brandLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3320B26C),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 28,
                color: AppColors.background,
              ),
            ),
            const SizedBox(height: 14),

            // ── Title ──
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(text: 'Upgrade to '),
                  TextSpan(
                    text: 'Pro',
                    style: TextStyle(color: AppColors.brand),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Unlimited signals, real-time alerts,\nand advanced analytics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // ── Plan cards ──
            if (state.plans.isNotEmpty)
              Row(
                children: List.generate(state.plans.length, (i) {
                  final plan = state.plans[i];
                  final isSelected = _selectedPlanIndex == i;
                  final isLast = i == state.plans.length - 1;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPlanIndex = i),
                      child: Container(
                        margin: EdgeInsets.only(
                          left: i > 0 ? 4 : 0,
                          right: i < state.plans.length - 1 ? 4 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brand.withValues(alpha: 0.04)
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brand
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${plan.price}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              plan.readableDuration,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            const SizedBox(height: 20),

            // ── Features ──
            ...[
              'Unlimited tickers — track all assets',
              'Real-time signals — instant delivery',
              'Push notifications — never miss',
              'Full signal history — deep analytics',
              'Priority support — 24/7 help',
            ].map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.brand.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),

            // ── Subscribe button ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (state.isPurchasing || _selectedPlanIndex < 0)
                    ? null
                    : () {
                        final plan = state.plans[_selectedPlanIndex];
                        final productId = Platform.isIOS
                            ? plan.appleProductId
                            : plan.googleProductId;
                        final product = state.productDetails.firstWhere(
                          (p) => p.id == productId,
                        );
                        context
                            .read<SubscriptionBloc>()
                            .add(PurchasePlan(product));
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: AppColors.background,
                  disabledBackgroundColor: AppColors.elevated,
                  disabledForegroundColor: AppColors.textQuaternary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: state.isPurchasing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : Text(
                        _selectedPlanIndex >= 0
                            ? 'Subscribe — \$${state.plans[_selectedPlanIndex].price}/${state.plans[_selectedPlanIndex].readableDuration}'
                            : 'Выберите тариф',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Restore ──
            TextButton(
              onPressed: state.isRestoring
                  ? null
                  : () => context
                      .read<SubscriptionBloc>()
                      .add(RestorePurchases()),
              child: Text(
                state.isRestoring
                    ? 'Восстановление...'
                    : 'Cancel anytime · Restore purchase',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textQuaternary,
                ),
              ),
            ),

            // ── Legal ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (Platform.isIOS) {
                      _launchURL(
                        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                      );
                    } else {
                      context.router.push(TermsOfUseRoute());
                    }
                  },
                  child: const Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textQuaternary,
                    ),
                  ),
                ),
                const Text(
                  ' · ',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textQuaternary,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      context.router.push(PrivacyPolicyRoute()),
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textQuaternary,
                    ),
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
