import 'package:aspiro_trade/features/signals/bloc/signals_bloc.dart';
import 'package:aspiro_trade/features/signals/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SignalsScreen extends StatefulWidget {
  const SignalsScreen({super.key});

  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  final List<String> filters = ['All', 'Buy', 'Sell'];
  String activeFilter = 'All';

  @override
  void initState() {
    context.read<SignalsBloc>().add(Start());
    super.initState();
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
            context.read<SignalsBloc>().add(Start());
          },
          child: CustomScrollView(
            slivers: [
              // ── Title ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      const Text(
                        'Signals',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      BlocBuilder<SignalsBloc, SignalsState>(
                        builder: (context, state) {
                          if (state.signals.isEmpty) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.brand.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${state.signals.length} active',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brand),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Segmented Control ──
              SliverToBoxAdapter(
                child: BlocBuilder<SignalsBloc, SignalsState>(
                  builder: (context, state) {
                    if (state.status != Status.initial && state.signals.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final activeFilter = state.activeFilter;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: filters.map((filter) {
                          final isActive = filter == activeFilter;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                context.read<SignalsBloc>().add(ChangeFilter(filter));
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.elevated : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Content ──
              BlocConsumer<SignalsBloc, SignalsState>(
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
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Skeleton cards
                            ...List.generate(3, (i) => _SkeletonCard()),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state.status != Status.initial && state.signals.isNotEmpty) {
                    final filteredSignals = state.signals.where((signal) {
                      if (state.activeFilter == 'All') return true;
                      if (state.activeFilter == 'Buy') return signal.signal.direction.toLowerCase() == 'buy';
                      if (state.activeFilter == 'Sell') return signal.signal.direction.toLowerCase() == 'sell';
                      return true;
                    }).toList();

                    if (filteredSignals.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(message: 'No signals for this filter'),
                      );
                    }

                    return SliverList.builder(
                      itemCount: filteredSignals.length,
                      itemBuilder: (context, index) {
                        return SignalsItem(signal: filteredSignals[index]);
                      },
                    );
                  }

                  if (state.signals.isEmpty && state.status != Status.loading) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(message: 'No active signals'),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
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
              child: const Icon(Icons.cell_tower_rounded, size: 36, color: AppColors.brand),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a ticker to start receiving\ntrading signals',
              style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
        ),
      ),
    );
  }
}
