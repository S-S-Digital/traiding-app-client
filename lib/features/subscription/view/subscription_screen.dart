import 'dart:io';

import 'package:aspiro_trade/features/subscription/bloc/subscription_bloc.dart';
import 'package:aspiro_trade/features/subscription/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
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
              context.showBusinessErrorSnackbar(
                error?.toString() ?? 'Неизвестная ошибка',
                () {},
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
          } else if (state.status != SubscriptionStatus.initial) {
            return CustomScrollView(
              slivers: [
                const SliverAppBar(title: Text('Подписки')),
                const SubscriptionTitle(),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Выбери свой тариф',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                //rauan_aitanatov@icloud.com
                /// Обычные планы
                SliverList.builder(
                  itemCount: state.plans.length - 1,
                  itemBuilder: (context, index) {
                    final plan = state.plans[index];

                    return SubscriptionItem(
                      plans: plan,
                      subscriptions: state.subscription,
                      onPay: () => state.isPurchasing || state.isRestoring
                          ? null
                          : () {
                              //Тут можно ничего не делать как бы бесплатный план будет всегда
                              // context.read<SubscriptionBloc>().add(
                              //       PurchasePlan(product),
                              //     );
                            },
                    );
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                /// PRO план
                PrimeSubscription(
                  plans: state.plans.last,
                  subscriptions: state.subscription,
                  isLoading: state.isPurchasing,
                  onPay: () {
                    final plan = state.plans.last;
                    final productId = Platform.isIOS
                        ? plan.appleProductId
                        : plan.googleProductId;
                    final product = state.productDetails.firstWhere(
                      (p) => p.id == productId,
                    );
                    context.read<SubscriptionBloc>().add(PurchasePlan(product));
                  },
                ),

                /// Restore purchases
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: state.isRestoring
                          ? null
                          : () => context.read<SubscriptionBloc>().add(
                              RestorePurchases(),
                            ),
                      icon: state.isRestoring
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restore),
                      label: Text(
                        state.isRestoring
                            ? 'Восстановление...'
                            : 'Восстановить покупки',
                      ),
                    ),
                  ),
                ),

                /// Legal
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
                    child: Column(
                      children: [
                        Text(
                          'Оплата будет списана с учетной записи Apple ID при '
                          'подтверждении покупки. Подписка продлевается автоматически, '
                          'если она не будет отменена как минимум за 24 часа до окончания '
                          'текущего периода.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  if (Platform.isIOS) {
                                    // Для Apple — только внешняя ссылка на их стандартный EULA
                                    _launchURL(
                                      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                                    );
                                  } else {
                                    
                                    
                                    context.router.push(const TermsOfUseRoute());
                                  }
                                },
                                child: const Text('Условия использования (EULA)'),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () => context.router.push(
                                  const PrivacyPolicyRoute(),
                                ),
                                child: const Text('Конфиденциальность (Privacy Policy)'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
