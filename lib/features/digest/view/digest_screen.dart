import 'dart:ui';
import 'package:aspiro_trade/features/analytics/view/asset_analytics_section.dart';
import 'package:aspiro_trade/features/digest/cubit/digest_cubit.dart';
import 'package:aspiro_trade/features/profile/cubit/profile_cubit.dart';
import 'package:aspiro_trade/repositories/digest/domain/market_digest.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/ui/widgets/auth_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DigestScreen extends StatefulWidget {
  const DigestScreen({super.key});

  @override
  State<DigestScreen> createState() => _DigestScreenState();
}

class _DigestScreenState extends State<DigestScreen> {
  int _activeCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DigestCubit>().fetchDigests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // The general market digest is FREE for everyone (per-card backend lock
      // still applies to premium-only digests). The premium per-coin analytics
      // section below carries its own teaser/paywall. Refetch the digest when
      // premium is granted so any locked cards unlock immediately.
      body: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (prev, curr) =>
            PremiumGate.isPremium(prev) == false &&
            PremiumGate.isPremium(curr) == true,
        listener: (context, _) => context.read<DigestCubit>().fetchDigests(),
        child: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brand,
          backgroundColor: AppColors.card,
          onRefresh: () async {
            await context.read<DigestCubit>().fetchDigests();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                  child: Text(
                    AppLocalizations.aiAnalytics,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              // ── Segment Control ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SegmentTab(
                            label: AppLocalizations.cryptocurrencies,
                            isActive: _activeCategoryIndex == 0,
                            icon: Icons.currency_bitcoin_rounded,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _activeCategoryIndex = 0);
                            },
                          ),
                        ),
                        Expanded(
                          child: _SegmentTab(
                            label: AppLocalizations.marketsAndCurrencies,
                            isActive: _activeCategoryIndex == 1,
                            icon: Icons.candlestick_chart_rounded,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _activeCategoryIndex = 1);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Content ──
              BlocBuilder<DigestCubit, DigestState>(
                builder: (context, state) {
                  if (state is DigestLoading) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                color: AppColors.brand,
                                strokeWidth: 3,
                                backgroundColor: AppColors.brand.withOpacity(0.1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.analyzingMarkets,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is DigestFailure) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _ErrorView(
                        error: state.error.toString(),
                        onRetry: () => context.read<DigestCubit>().fetchDigests(),
                      ),
                    );
                  }

                  if (state is DigestLoaded) {
                    final currentType = _activeCategoryIndex == 0
                        ? DigestType.crypto
                        : DigestType.tradfi;
                    final filtered = state.digests
                        .where((d) => d.type == currentType)
                        .toList();

                    if (filtered.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(
                                  Icons.analytics_outlined,
                                  color: AppColors.textTertiary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.noDigestReviewsYet,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final digest = filtered[index];
                            // First card gets hero treatment
                            if (index == 0) {
                              return _HeroDigestCard(digest: digest);
                            }
                            return _CompactDigestCard(digest: digest);
                          },
                          childCount: filtered.length,
                        ),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // ── Premium per-coin AI analytics (relocated from asset cards) ──
              // Shows full per-coin breakdown to subscribers, a teaser+paywall
              // to free users (backend returns a locked teaser for them).
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 100),
                  child: AssetAnalyticsSection(),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SEGMENT TAB
// ═══════════════════════════════════════════════════════

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.isActive,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF1B9B5E), Color(0xFF20B26C)],
                )
              : null,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.brand.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? Colors.white : AppColors.textQuaternary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.textQuaternary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HERO DIGEST CARD (first/latest card — large, prominent)
// ═══════════════════════════════════════════════════════

class _HeroDigestCard extends StatelessWidget {
  const _HeroDigestCard({required this.digest});
  final MarketDigest digest;

  @override
  Widget build(BuildContext context) {
    final sentimentColor = _sentimentColor(digest.sentiment);
    final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(digest.generatedAt);
    final blocks = digest.blocks;
    final hasBlocks = blocks.isNotEmpty && blocks['summary'] != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.card,
              AppColors.card.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: sentimentColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: sentimentColor.withOpacity(0.06),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Subtle gradient accent at top
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        sentimentColor.withOpacity(0.08),
                        sentimentColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header: sentiment badge + date ──
                    Row(
                      children: [
                        Flexible(
                          child: _SentimentBadge(
                            sentiment: digest.sentiment,
                            color: sentimentColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textQuaternary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Title ──
                    Text(
                      digest.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Key Indicators (pill chips) ──
                    if (digest.keyIndicators.isNotEmpty) ...[
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: digest.keyIndicators.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final entry = digest.keyIndicators.entries.elementAt(index);
                            final value = entry.value.toString();
                            final isNegative = value.contains('-');
                            final isPositive = value.contains('+');
                            return _IndicatorChip(
                              label: entry.key,
                              value: value,
                              valueColor: isNegative
                                  ? AppColors.down
                                  : isPositive
                                      ? AppColors.up
                                      : AppColors.textPrimary,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Divider ──
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.border.withOpacity(0.0),
                            AppColors.border.withOpacity(0.6),
                            AppColors.border.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Content Blocks ──
                    if (hasBlocks) ...[
                      _SummaryBlock(summary: blocks['summary'] as String),
                      if (blocks['news'] != null &&
                          (blocks['news'] as List).isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _NewsBlock(news: blocks['news'] as List),
                      ],
                      if (blocks['technical'] != null) ...[
                        const SizedBox(height: 16),
                        _TechnicalBlock(
                          tech: blocks['technical'] as Map<String, dynamic>,
                          sentimentColor: sentimentColor,
                        ),
                      ],
                      if (blocks['risk_management'] != null &&
                          (blocks['risk_management'] as String).isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _RiskBlock(risk: blocks['risk_management'] as String),
                      ],
                    ] else ...[
                      MarkdownBody(
                        data: digest.content,
                        styleSheet: _markdownStyle(),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Premium Lock Overlay ──
              if (digest.isLocked) _PremiumOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// COMPACT DIGEST CARD (subsequent cards — collapsed)
// ═══════════════════════════════════════════════════════

class _CompactDigestCard extends StatefulWidget {
  const _CompactDigestCard({required this.digest});
  final MarketDigest digest;

  @override
  State<_CompactDigestCard> createState() => _CompactDigestCardState();
}

class _CompactDigestCardState extends State<_CompactDigestCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final sentimentColor = _sentimentColor(widget.digest.sentiment);
    final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(widget.digest.generatedAt);
    final blocks = widget.digest.blocks;
    final hasBlocks = blocks.isNotEmpty && blocks['summary'] != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _expanded = !_expanded);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(_expanded ? 1 : 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _expanded
                  ? sentimentColor.withOpacity(0.2)
                  : AppColors.border.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: _expanded
                ? [
                    BoxShadow(
                      color: sentimentColor.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Collapsed Header ──
                      Row(
                        children: [
                          _SentimentDot(color: sentimentColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.digest.title,
                                  maxLines: _expanded ? 10 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textQuaternary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _sentimentText(widget.digest.sentiment),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: sentimentColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textQuaternary,
                              size: 22,
                            ),
                          ),
                        ],
                      ),

                      // ── Expanded Content ──
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Key indicators
                              if (widget.digest.keyIndicators.isNotEmpty) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: widget.digest.keyIndicators.entries.map((entry) {
                                    return _IndicatorChip(
                                      label: entry.key,
                                      value: entry.value.toString(),
                                      valueColor: AppColors.textPrimary,
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 14),
                              ],

                              Container(
                                height: 1,
                                color: AppColors.border.withOpacity(0.3),
                              ),
                              const SizedBox(height: 14),

                              if (hasBlocks) ...[
                                _SummaryBlock(summary: blocks['summary'] as String),
                                if (blocks['news'] != null &&
                                    (blocks['news'] as List).isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  _NewsBlock(news: blocks['news'] as List),
                                ],
                                if (blocks['technical'] != null) ...[
                                  const SizedBox(height: 14),
                                  _TechnicalBlock(
                                    tech: blocks['technical'] as Map<String, dynamic>,
                                    sentimentColor: sentimentColor,
                                  ),
                                ],
                                if (blocks['risk_management'] != null &&
                                    (blocks['risk_management'] as String).isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  _RiskBlock(risk: blocks['risk_management'] as String),
                                ],
                              ] else ...[
                                MarkdownBody(
                                  data: widget.digest.content,
                                  styleSheet: _markdownStyle(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        crossFadeState: _expanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),

                // Premium lock
                if (widget.digest.isLocked) _PremiumOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// CONTENT BLOCKS
// ═══════════════════════════════════════════════════════

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({required this.summary});
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brand.withOpacity(0.06),
            AppColors.brand.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brand.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.brand.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.brand, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.marketSummary,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsBlock extends StatelessWidget {
  const _NewsBlock({required this.news});
  final List<dynamic> news;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.newspaper_rounded, color: AppColors.info, size: 14),
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.mainEvents,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(news.length, (index) {
          final newsMap = news[index] as Map<String, dynamic>;
          final impact = newsMap['impact']?.toString().toUpperCase() ?? 'NEUTRAL';
          final title = newsMap['title']?.toString() ?? '';
          final explanation = newsMap['explanation']?.toString() ?? '';

          Color impactColor;
          String impactLabel;
          IconData impactIcon;

          if (impact == 'BULLISH') {
            impactColor = AppColors.up;
            impactLabel = AppLocalizations.bullishImpact;
            impactIcon = Icons.trending_up_rounded;
          } else if (impact == 'BEARISH') {
            impactColor = AppColors.down;
            impactLabel = AppLocalizations.bearishImpact;
            impactIcon = Icons.trending_down_rounded;
          } else {
            impactColor = AppColors.textTertiary;
            impactLabel = AppLocalizations.neutralImpact;
            impactIcon = Icons.trending_flat_rounded;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.elevated.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: impactColor.withOpacity(0.1),
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Impact indicator bar
                  Container(
                    width: 3,
                    height: 40,
                    decoration: BoxDecoration(
                      color: impactColor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: impactColor.withOpacity(0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(impactIcon, size: 12, color: impactColor),
                            const SizedBox(width: 4),
                            Text(
                              impactLabel,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: impactColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        if (explanation.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            explanation,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TechnicalBlock extends StatelessWidget {
  const _TechnicalBlock({required this.tech, required this.sentimentColor});
  final Map<String, dynamic> tech;
  final Color sentimentColor;

  @override
  Widget build(BuildContext context) {
    final support = tech['support']?.toString() ?? '';
    final resistance = tech['resistance']?.toString() ?? '';
    final actionZones = tech['action_zones']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevated.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.show_chart_rounded, color: AppColors.purple, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.technicalAnalysis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LevelCard(
                  label: AppLocalizations.supportWord.toUpperCase(),
                  value: support,
                  color: AppColors.up,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LevelCard(
                  label: AppLocalizations.resistanceWord.toUpperCase(),
                  value: resistance,
                  color: AppColors.down,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
          if (actionZones.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.strategyAndActionZones,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    actionZones,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RiskBlock extends StatelessWidget {
  const _RiskBlock({required this.risk});
  final String risk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withOpacity(0.05),
            AppColors.warning.withOpacity(0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.warning, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.riskControl,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            risk,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════

class _SentimentBadge extends StatelessWidget {
  const _SentimentBadge({required this.sentiment, required this.color});
  final MarketSentiment sentiment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: _PulsingDot(color: color),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _sentimentText(sentiment),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SentimentDot extends StatelessWidget {
  const _SentimentDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

class _IndicatorChip extends StatelessWidget {
  const _IndicatorChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.elevated.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withOpacity(0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            color: Colors.black.withOpacity(0.75),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.brand.withOpacity(0.15),
                        AppColors.brand.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brand.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brand.withOpacity(0.15),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.brand,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.premiumAiAnalytics,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.premiumDigestDisclaimer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: AuthButton(
                    text: AppLocalizations.unlockAccess,
                    isValid: true,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.pushRoute(const SubscriptionRoute());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.down.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.down.withOpacity(0.2)),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.down,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.errorLoadingAnalytics,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 160,
            child: AuthButton(
              text: AppLocalizations.retry,
              isValid: true,
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// PULSING DOT ANIMATION
// ═══════════════════════════════════════════════════════

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.5 + 0.5 * _controller.value;
        return Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(opacity),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3 * _controller.value),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════

Color _sentimentColor(MarketSentiment sentiment) {
  switch (sentiment) {
    case MarketSentiment.bullish:
      return const Color(0xFF00E676);
    case MarketSentiment.bearish:
      return const Color(0xFFFF2D55);
    case MarketSentiment.neutral:
      return const Color(0xFF90A4AE);
  }
}

String _sentimentText(MarketSentiment sentiment) {
  switch (sentiment) {
    case MarketSentiment.bullish:
      return AppLocalizations.bullishSentiment;
    case MarketSentiment.bearish:
      return AppLocalizations.bearishSentiment;
    case MarketSentiment.neutral:
      return AppLocalizations.neutralSentiment;
  }
}

MarkdownStyleSheet _markdownStyle() {
  return MarkdownStyleSheet(
    p: const TextStyle(
      fontSize: 13,
      color: AppColors.textSecondary,
      height: 1.55,
    ),
    strong: const TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
    ),
    h1: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppColors.brand,
      height: 1.5,
    ),
    h2: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: AppColors.brand,
      height: 1.5,
    ),
    h3: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    listBullet: const TextStyle(color: AppColors.brand),
    blockSpacing: 12,
  );
}
