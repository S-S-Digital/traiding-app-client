import 'package:aspiro_trade/features/tickers/bloc/tickers_bloc.dart';
import 'package:aspiro_trade/features/tickers/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class TickersScreen extends StatefulWidget {
  const TickersScreen({super.key});

  @override
  State<TickersScreen> createState() => _TickersScreenState();
}

class _TickersScreenState extends State<TickersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TickersBloc>().add(Start());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumGate(
        // When premium is regained, reload tickers immediately.
        onUnlocked: () => context.read<TickersBloc>().add(Start()),
        child: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brand,
          backgroundColor: AppColors.card,
          onRefresh: () async {
            context.read<TickersBloc>().add(Refresh());
          },
          child: CustomScrollView(
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.market,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.router.push(const AssetsRoute()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.brand, AppColors.brandLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brand.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.addAsset,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Column headers ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 48),
                      Expanded(
                        child: Text(
                          AppLocalizations.assetColumn,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Text(
                        AppLocalizations.trendColumn,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 46),
                      Text(
                        AppLocalizations.priceColumn,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 6)),

              // ── Ticker List ──
              BlocConsumer<TickersBloc, TickersState>(
                listener: (context, state) {
                  if (state.status == Status.failure) {
                    if (state.error is AppException && state.error is! FordibenException) {
                      final error = state.error as AppException;
                      context.handleException(error, context);
                    }
                  }
                },
                buildWhen: (previous, current) =>
                    current.status.isBuildable || (current.status == Status.failure && current.error is FordibenException),
                builder: (context, state) {
                  // 403 — Premium required: show inline upsell
                  if (state.status == Status.failure && state.error is FordibenException) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: PremiumRequiredView(),
                    );
                  }

                  if (state.status == Status.loading && state.tickers.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
                        ),
                      ),
                    );
                  }

                  if (state.status != Status.initial && state.tickers.isNotEmpty) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final ticker = state.tickers[index];
                            return TickersItem(
                              tickers: ticker,
                              onSwipe: () async {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => const DeleteTickerDialog(),
                                );
                                if (result == true && context.mounted) {
                                  context.read<TickersBloc>().add(DeleteTicker(id: ticker.tickers.id));
                                }
                              },
                              onEdit: () {
                                context.router.push(AssetDetailsRoute(assets: ticker.assets));
                              },
                            );
                          },
                          childCount: state.tickers.length,
                        ),
                      ),
                    );
                  }

                  if (state.tickers.isEmpty && state.status != Status.loading) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72, height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.brand.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(36),
                                ),
                                child: const Icon(Icons.show_chart_rounded, size: 36, color: AppColors.brand),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                AppLocalizations.noTickersYet,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.addFirstTicker,
                                style: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () => context.router.push(const AssetsRoute()),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.brand,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    AppLocalizations.addTicker,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.background),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
