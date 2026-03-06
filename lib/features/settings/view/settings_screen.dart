import 'package:aspiro_trade/features/settings/bloc/settings_bloc.dart';
import 'package:aspiro_trade/features/settings/widgets/widgets.dart';
import 'package:aspiro_trade/features/settings/widgets/language_picker.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/app/aspiro_trade_app.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(Start());
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.card,
                  content: Text('Error: ${state.error}', style: const TextStyle(color: AppColors.down)),
                ),
              );
            }
            if (state is Close) {
              context.router.replaceAll([const LoginRoute()]);
            }
          },
          builder: (context, state) {
            String email = '';
            String name = 'User';
            bool isPremium = false;
            String premiumUntil = '';
            String appVersion = '1.0.0';

            if (state is SettingsLoaded) {
              email = state.users.email;
              name = state.users.email.split('@').first;
              isPremium = state.users.isPremium;
              premiumUntil = state.users.premiumUntilFormatted;
              appVersion = state.appVersion;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Profile Header ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.brand, Color(0xFF0D9B5A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(36),
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        if (isPremium) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('PRO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.warning)),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Plan Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A2A1F), Color(0xFF162016)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(isPremium ? AppLocalizations.proPlan : AppLocalizations.freePlan, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                              child: Text(isPremium ? AppLocalizations.active : AppLocalizations.upgrade, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brand)),
                            ),
                          ],
                        ),
                        if (premiumUntil.isNotEmpty && premiumUntil != '-') ...[
                          const SizedBox(height: 4),
                          Text('${AppLocalizations.renews} $premiumUntil', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Account Section ──
                  _SettingsGroup(
                    title: AppLocalizations.account,
                    children: [
                      _SettingsRow(
                        icon: Icons.person_outline, iconColor: AppColors.brand,
                        title: AppLocalizations.editProfile,
                        onTap: () => context.router.push(const ProfileRoute()),
                      ),
                      _SettingsRow(
                        icon: Icons.workspace_premium_outlined, iconColor: AppColors.warning,
                        title: AppLocalizations.subscription,
                        onTap: () => context.router.push(const SubscriptionRoute()),
                      ),
                      _SettingsRow(
                        icon: Icons.language_rounded, iconColor: AppColors.info,
                        title: AppLocalizations.language,
                        trailing: Text(
                          AppLocalizations.languageValue,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                        ),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          showLanguagePicker(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Get for Free ──
                  _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: Icons.card_giftcard_rounded, iconColor: AppColors.brand,
                        title: AppLocalizations.getFree,
                        onTap: () => launchUrl(
                          Uri.parse('https://docs.google.com/document/d/1-emJAJQjTSl8Y_crh6LuXqTqzw29J7v364BUC28hFkM/edit?usp=drivesdk'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Support Section ──
                  _SettingsGroup(
                    title: AppLocalizations.support,
                    children: [
                      _SettingsRow(
                        icon: Icons.description_outlined, iconColor: AppColors.info,
                        title: AppLocalizations.termsOfUse,
                        onTap: () => context.router.push(const TermsOfUseRoute()),
                      ),
                      _SettingsRow(
                        icon: Icons.shield_outlined, iconColor: AppColors.purple,
                        title: AppLocalizations.privacyPolicy,
                        onTap: () => context.router.push(const PrivacyPolicyRoute()),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Sign Out ──
                  _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: Icons.logout, iconColor: AppColors.down,
                        title: AppLocalizations.signOut,
                        titleColor: AppColors.down,
                        showArrow: false,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => ExitDialog(
                              confirm: () {
                                context.read<SettingsBloc>().add(Exit());
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text('Aspiro Trade v$appVersion', style: const TextStyle(fontSize: 12, color: AppColors.textQuaternary)),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({this.title, required this.children});
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ...children.asMap().entries.map((entry) {
                return Column(
                  children: [
                    entry.value,
                    if (entry.key < children.length - 1)
                      const Divider(height: 1, color: AppColors.border, indent: 52, endIndent: 16),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatefulWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.showArrow = true,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final bool showArrow;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  State<_SettingsRow> createState() => _SettingsRowState();
}

class _SettingsRowState extends State<_SettingsRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed ? AppColors.elevated : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: widget.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon, size: 18, color: widget.iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: widget.titleColor ?? AppColors.textPrimary),
              ),
            ),
            if (widget.trailing != null) ...[
              widget.trailing!,
              const SizedBox(width: 4),
            ],
            if (widget.showArrow)
              const Icon(Icons.chevron_right, size: 20, color: AppColors.textQuaternary),
          ],
        ),
      ),
    );
  }
}
