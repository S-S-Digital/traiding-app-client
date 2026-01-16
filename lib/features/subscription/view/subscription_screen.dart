import 'dart:io';

import 'package:aspiro_trade/features/subscription/bloc/subscription_bloc.dart';
import 'package:aspiro_trade/features/subscription/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


@RoutePage()
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    context.read<SubscriptionBloc>().add(Start());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
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

          BlocConsumer<SubscriptionBloc, SubscriptionState>(
            listener: (context, state) {
              if (state is SubscriptionFailure) {
                if (state.error is AppException) {
                  final error = state.error as AppException;

                  showErrorDialog(context, error.message, 'ok', () {});
                }

                showErrorDialog(context, state.error.toString(), 'ok', () {
                  context.read<SubscriptionBloc>().add(Start());
                  Navigator.of(context).pop();
                });


              }
              
            },
            buildWhen: (previous, current) => current.isBuildable,
            builder: (context, state) {
              if(state is SubscriptionLoading){
                return const SliverFillRemaining(
                  child: Center(child: PlatformProgressIndicator()),
                );
              }
              else if (state is SubscriptionLoaded) {
                return SliverList.builder(
                  itemCount: state.plans.length - 1,
                  itemBuilder: (context, index) {
                    return SubscriptionItem(
                      plans: state.plans[index],
                      onPay: () {
                        // Внутри BlocBuilder<SubscriptionBloc, SubscriptionState>

                        final state = context.read<SubscriptionBloc>().state;
                        if (state is SubscriptionLoaded) {
                          // Находим ProductDetails, который соответствует нашему плану
                          final productId = Platform.isIOS
                              ? state.plans[index].appleProductId
                              : state.plans[index].googleProductId;
                          final product = state.productDetails.firstWhere(
                            (p) => p.id == productId,
                          );

                          context.read<SubscriptionBloc>().add(
                            PurchasePlan(product),
                          );
                        }
                      },
                    );
                  },
                );
              }
              return const SliverToBoxAdapter();
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          BlocConsumer<SubscriptionBloc, SubscriptionState>(
            listener: (context, state) {
              if (state is SubscriptionFailure) {
                if (state.error is AppException) {
                  final error = state.error as AppException;

                  showErrorDialog(context, error.message, 'ok', () {});
                }
              }
            },
            buildWhen: (previous, current) => current.isBuildable,
            builder: (context, state) {
              if (state is SubscriptionLoaded) {
                return PrimeSubscription(plans: state.plans.last, onPay: () {

                  final state = context.read<SubscriptionBloc>().state;
                        if (state is SubscriptionLoaded) {
                          // Находим ProductDetails, который соответствует нашему плану
                          final productId = Platform.isIOS
                              ? state.plans.last.appleProductId
                              : state.plans.last.googleProductId;
                          final product = state.productDetails.firstWhere(
                            (p) => p.id == productId,
                          );

                          context.read<SubscriptionBloc>().add(
                            PurchasePlan(product),
                          );
                        }
                });
              }
              return const SliverToBoxAdapter();
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}
