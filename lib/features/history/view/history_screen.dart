import 'package:aspiro_trade/features/history/bloc/history_bloc.dart';
import 'package:aspiro_trade/features/history/models/models.dart';
import 'package:aspiro_trade/features/history/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    context.read<HistoryBloc>().add(Start());
    super.initState();
  }

  String _dateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
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
            context.read<HistoryBloc>().add(Start());
          },
          child: CustomScrollView(
            slivers: [
              // ── Title ──
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'History',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Stats Bar ──
              SliverToBoxAdapter(
                child: BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    if (state.stats.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: state.stats.map((stat) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: stat == state.stats.last ? 0 : 8,
                              ),
                              child: Statistics(stat: stat),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── History List (grouped by date) ──
              BlocConsumer<HistoryBloc, HistoryState>(
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

                  if (state.status != Status.initial && state.histories.isNotEmpty) {
                    // Group by date
                    final groups = <String, List<CombinedHistory>>{};
                    for (final item in state.histories) {
                      final label = _dateGroupLabel(item.history.closedAt);
                      groups.putIfAbsent(label, () => []);
                      groups[label]!.add(item);
                    }

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        ...groups.entries.expand((group) => [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                            child: Text(
                              group.key,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTertiary),
                            ),
                          ),
                          // Card with items
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ...group.value.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  return Column(
                                    children: [
                                      HistoryItem(history: item),
                                      if (index < group.value.length - 1)
                                        const Divider(height: 1, color: AppColors.border, indent: 42),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ]),
                      ]),
                    );
                  }

                  if (state.histories.isEmpty && state.status != Status.loading) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.brand.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: const Icon(Icons.history_rounded, size: 36, color: AppColors.brand),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No history yet',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Completed signals will appear here',
                              style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                              textAlign: TextAlign.center,
                            ),
                          ],
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
