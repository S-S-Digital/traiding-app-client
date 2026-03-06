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
      body: SafeArea(
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      const Text(
                        'Market',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.router.push(const AssetsRoute()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.brand,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 18, color: AppColors.background),
                              SizedBox(width: 4),
                              Text('Add', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.background)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Column headers ──
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SizedBox(width: 52),
                      Expanded(
                        child: Text('Name', style: TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
                      ),
                      Text('Price', style: TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 72,
                        child: Text('24h', style: TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500), textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── Ticker List ──
              BlocConsumer<TickersBloc, TickersState>(
                listener: (context, state) {
                  if (state.status == Status.failure) {
                    if (state.error is AppException) {
                      final error = state.error as AppException;
                      context.handleException(error, context);
                    }
                  }
                },
                buildWhen: (previous, current) => current.status.isBuildable,
                builder: (context, state) {
                  if (state.status == Status.loading) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
                        ),
                      ),
                    );
                  }

                  if (state.status != Status.initial && state.tickers.isNotEmpty) {
                    return SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...state.tickers.asMap().entries.map((entry) {
                              final index = entry.key;
                              final ticker = entry.value;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TickersItem(
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
                                  ),
                                  if (index < state.tickers.length - 1)
                                    const Divider(height: 1, color: AppColors.border, indent: 68, endIndent: 16),
                                ],
                              );
                            }),
                          ],
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
                              const Text(
                                'No tickers yet',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add your first ticker to start\ntracking the market',
                                style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
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
                                  child: const Text(
                                    'Add Tickers',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.background),
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
    );
  }
}
