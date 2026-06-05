import 'package:aspiro_trade/features/history/bloc/history_bloc.dart';
import 'package:aspiro_trade/features/history/models/models.dart';
import 'package:aspiro_trade/features/history/widgets/widgets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (d == today) return AppLocalizations.today;
    if (d == yesterday) return AppLocalizations.yesterday;
    // Locale-neutral numeric date — avoids leaking English month names in a
    // RU-first product (audit M11).
    return DateFormat('dd.MM.yyyy').format(date);
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    AppLocalizations.history,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Performance Dashboard ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlocBuilder<HistoryBloc, HistoryState>(
                    builder: (context, state) {
                      return PerformanceDashboard(
                        histories: state.histories,
                        activePeriod: state.activePeriod,
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Period Picker ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlocBuilder<HistoryBloc, HistoryState>(
                    buildWhen: (prev, curr) => prev.activePeriod != curr.activePeriod,
                    builder: (context, state) {
                      return _PeriodSegmentedPicker(
                        selectedPeriod: state.activePeriod,
                        onPeriodChanged: (period) {
                          context.read<HistoryBloc>().add(ChangePeriod(period));
                        },
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── History List (grouped by date) ──
              BlocConsumer<HistoryBloc, HistoryState>(
                listener: (context, state) {},
                buildWhen: (previous, current) =>
                    current.status.isBuildable || current.status == Status.failure,
                builder: (context, state) {
                  // 403 — Premium required: show inline upsell
                  if (state.status == Status.failure && state.error is FordibenException) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: PremiumRequiredView(),
                    );
                  }

                  // Graceful inline error state (e.g. offline or server down) when no data is cached
                  if (state.status == Status.failure && state.histories.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72, height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.darkAccentRed.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(36),
                                ),
                                child: const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 36,
                                  color: AppColors.darkAccentRed,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                AppLocalizations.failedToLoad,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.noInternet,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textTertiary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brand,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  context.read<HistoryBloc>().add(Start());
                                },
                                child: Text(
                                  AppLocalizations.tryAgain,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                    final now = DateTime.now();
                    final filteredHistories = state.histories.where((h) {
                      final period = state.activePeriod;
                      if (period == 'All') return true;
                      if (period == 'Today') {
                        final today = DateTime(now.year, now.month, now.day);
                        final d = h.history.closedAt;
                        return DateTime(d.year, d.month, d.day) == today;
                      }
                      if (period == '7d') {
                        final cutoff = now.subtract(const Duration(days: 7));
                        return h.history.closedAt.isAfter(cutoff);
                      }
                      return true;
                    }).toList();

                    if (filteredHistories.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72, height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.brand.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(36),
                                ),
                                child: const Icon(Icons.history_rounded, size: 36, color: AppColors.brand),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                AppLocalizations.noHistoryPeriod,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.completedSignalsHere,
                                style: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Group by date
                    final groups = <String, List<CombinedHistory>>{};
                    for (final item in filteredHistories) {
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
                            Text(
                              AppLocalizations.noHistoryYet,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.completedSignalsHere,
                              style: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
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

class _PeriodSegmentedPicker extends StatelessWidget {
  const _PeriodSegmentedPicker({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final periods = [
      {'label': AppLocalizations.today, 'value': 'Today'},
      {'label': AppLocalizations.sevenDays, 'value': '7d'},
      {'label': AppLocalizations.allTime, 'value': 'All'},
    ];

    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: periods.map((p) {
          final isSelected = selectedPeriod == p['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onPeriodChanged(p['value']!);
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.elevated : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.border.withOpacity(0.8),
                          width: 1,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  p['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
