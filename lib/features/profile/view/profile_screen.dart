import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/features/profile/cubit/profile_cubit.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              AppLocalizations.editProfile,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: false,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                AutoRouter.of(context).back();
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),

          BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileFailure) {
                if (state.error is AppException) {
                  final error = state.error as AppException;
                  context.handleException(error, context);
                }
              }
              if (state is DeleteSuccess) {
                AutoRouter.of(context).pushAndPopUntil(
                  const LoginRoute(),
                  predicate: (value) => false,
                );
              }
            },
            buildWhen: (previous, current) => current.isBuildable,
            builder: (context, state) {
              if (state is ProfileLoaded) {
                final user = state.users;
                final limits = state.limits;
                final initial = user.email.isNotEmpty
                    ? user.email[0].toUpperCase()
                    : '?';
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // ── Avatar ──
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.brand, AppColors.brandLight],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brand.withValues(alpha: 0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.background,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Name ──
                        Text(
                          user.email.split('@').first,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),

                        // ── Pro badge ──
                        if (user.isPremium) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF20B26C),
                                  Color(0xFF2DC77A),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brand.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              '✦ PRO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // ── Info card ──
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _InfoRow(
                                icon: Icons.email_outlined,
                                label: AppLocalizations.email,
                                value: user.email,
                              ),
                              const _Divider(),
                              _InfoRow(
                                icon: Icons.workspace_premium_outlined,
                                label: AppLocalizations.plan,
                                value: user.isPremium ? 'Pro' : AppLocalizations.free,
                                valueColor: user.isPremium
                                    ? AppColors.brand
                                    : AppColors.textSecondary,
                              ),
                              const _Divider(),
                              _InfoRow(
                                icon: Icons.show_chart_rounded,
                                label: AppLocalizations.tickers,
                                value: limits.maxTickers.type ==
                                        MaxTickersType.unlimited
                                    ? AppLocalizations.unlimited
                                    : '${limits.currentTickers}/${limits.maxTickers.value}',
                              ),
                              if (user.isPremium) ...[
                                const _Divider(),
                                _InfoRow(
                                  icon: Icons.event_outlined,
                                  label: AppLocalizations.premiumUntil,
                                  value: user.premiumUntilFormatted,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Delete account ──
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () async {
                              HapticFeedback.heavyImpact();
                              final isConfirmed =
                                  await context.showDeleteAccountDialog(
                                context,
                              );
                              if (!mounted) return;
                              if (isConfirmed == true) {
                                context.read<ProfileCubit>().deleteAccount();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.down.withValues(alpha: 0.25),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.deleteAccount,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.down,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              }
              if (state is ProfileLoading || state is ProfileInitial) {
                return const SliverFillRemaining(
                  child: Center(child: PlatformProgressIndicator()),
                );
              }
              return const SliverToBoxAdapter();
            },
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.only(left: 48),
      color: AppColors.border,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
