import 'package:aspiro_trade/features/analytics/cubit/asset_analytics_cubit.dart';
import 'package:aspiro_trade/repositories/analytics/analytics.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/methods/price_formatter.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Premium per-asset AI analytics section (backend Task #3). Self-contained:
/// provides its own [AssetAnalyticsCubit], fetches today's feed, and renders the
/// card for [symbol] — full detail for subscribers, teaser + paywall otherwise.
class AssetAnalyticsSection extends StatelessWidget {
  const AssetAnalyticsSection({super.key, required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AssetAnalyticsCubit(
        analyticsRepository: context.read<AnalyticsRepositoryI>(),
      )..fetch(),
      child: _AssetAnalyticsBody(symbol: symbol),
    );
  }
}

class _AssetAnalyticsBody extends StatelessWidget {
  const _AssetAnalyticsBody({required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.brand),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.assetAnalyticsTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<AssetAnalyticsCubit, AssetAnalyticsState>(
            builder: (context, state) {
              if (state is AssetAnalyticsLoading || state is AssetAnalyticsInitial) {
                return const _AnalyticsSkeleton();
              }
              if (state is AssetAnalyticsFailure) {
                return _AnalyticsRetry(
                  onRetry: () => context.read<AssetAnalyticsCubit>().fetch(),
                );
              }
              final feed = (state as AssetAnalyticsLoaded).feed;
              final asset = feed.forSymbol(symbol);
              if (asset == null) {
                return const _AnalyticsMessage(text: null);
              }
              if (asset.isLocked || feed.isLocked) {
                return const _AnalyticsTeaser();
              }
              return _AnalyticsCard(asset: asset);
            },
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.asset});
  final AssetAnalytics asset;

  Color _sentimentColor(String? s) {
    switch (s) {
      case 'BULLISH':
        return AppColors.up;
      case 'BEARISH':
        return AppColors.down;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final levels = asset.levels;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chips: trend / regime / volatility
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                label: AppLocalizations.analyticsTrend,
                value: AppLocalizations.trendValue(asset.trend),
                color: asset.trend == 'UP'
                    ? AppColors.up
                    : asset.trend == 'DOWN'
                        ? AppColors.down
                        : AppColors.textSecondary,
              ),
              _Chip(
                label: AppLocalizations.analyticsRegime,
                value: AppLocalizations.regimeValue(asset.regime),
                color: AppColors.brandLight,
              ),
              if (asset.atrPct != null)
                _Chip(
                  label: AppLocalizations.analyticsVolatility,
                  value: '${asset.atrPct!.toStringAsFixed(2)}%',
                  color: AppColors.info,
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Narrative
          if (asset.narrative.isNotEmpty)
            Text(
              asset.narrative,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          // Levels
          if (levels != null &&
              (levels.support.isNotEmpty || levels.resistance.isNotEmpty)) ...[
            const SizedBox(height: 16),
            Text(
              AppLocalizations.analyticsLevels,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LevelColumn(
                    title: AppLocalizations.supportWord,
                    values: levels.support,
                    color: AppColors.up,
                  ),
                ),
                Expanded(
                  child: _LevelColumn(
                    title: AppLocalizations.resistanceWord,
                    values: levels.resistance,
                    color: AppColors.down,
                  ),
                ),
              ],
            ),
          ],
          // Scenarios
          if (asset.scenarios.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              AppLocalizations.analyticsScenariosTitle,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            ...asset.scenarios.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.arrow_right_rounded,
                            size: 18, color: AppColors.brand),
                      ),
                      Expanded(
                        child: Text(
                          '${AppLocalizations.scenarioType(s.type)}: ${s.condition} → ${s.target}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          // Signals-likely + sentiment footer
          const SizedBox(height: 14),
          Row(
            children: [
              if (asset.signalsLikely != null)
                Icon(
                  asset.signalsLikely! ? Icons.bolt_rounded : Icons.bolt_outlined,
                  size: 16,
                  color: asset.signalsLikely! ? AppColors.brand : AppColors.textTertiary,
                ),
              if (asset.signalsLikely != null) const SizedBox(width: 6),
              if (asset.signalsLikely != null)
                Expanded(
                  child: Text(
                    asset.signalsLikely!
                        ? AppLocalizations.analyticsSignalsLikely
                        : AppLocalizations.analyticsSignalsUnlikely,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: asset.signalsLikely! ? AppColors.brandLight : AppColors.textTertiary,
                    ),
                  ),
                ),
              if (asset.sentiment != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _sentimentColor(asset.sentiment).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    asset.sentiment == 'BULLISH'
                        ? AppLocalizations.bullishImpact
                        : asset.sentiment == 'BEARISH'
                            ? AppLocalizations.bearishImpact
                            : AppLocalizations.neutralImpact,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _sentimentColor(asset.sentiment),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelColumn extends StatelessWidget {
  const _LevelColumn({required this.title, required this.values, required this.color});
  final String title;
  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
        ),
        const SizedBox(height: 4),
        if (values.isEmpty)
          const Text('—', style: TextStyle(fontSize: 13, color: AppColors.textTertiary))
        else
          ...values.map((v) => Text(
                PriceFormatter.price(v, withSymbol: true),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              )),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTeaser extends StatelessWidget {
  const _AnalyticsTeaser();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brand.withOpacity(0.12),
            AppColors.brand.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brand.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline_rounded, size: 32, color: AppColors.brand),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.premiumAiAnalytics,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.analyticsLockedTeaser,
            style: const TextStyle(fontSize: 13, color: AppColors.textTertiary, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => AutoRouter.of(context).push(const SubscriptionRoute()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.upgradeToPlan,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4), width: 0.5),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brand),
        ),
      ),
    );
  }
}

class _AnalyticsMessage extends StatelessWidget {
  const _AnalyticsMessage({required this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4), width: 0.5),
      ),
      child: Text(
        text ?? AppLocalizations.analyticsNoData,
        style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _AnalyticsRetry extends StatelessWidget {
  const _AnalyticsRetry({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4), width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.errorLoadingAnalytics,
            style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.retry),
          ),
        ],
      ),
    );
  }
}
