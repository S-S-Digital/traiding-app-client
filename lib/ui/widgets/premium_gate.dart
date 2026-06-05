import 'package:aspiro_trade/features/profile/cubit/profile_cubit.dart';
import 'package:aspiro_trade/ui/widgets/premium_required_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Reactive premium gate backed by the SINGLE SOURCE OF TRUTH: [ProfileCubit].
///
/// Wrap any premium-only screen body with this widget. It reacts instantly to
/// premium changes (purchase / cancel / expiry) without any manual refresh:
///   * premium == true   → renders [child]
///   * premium == false  → renders the [PremiumRequiredView] paywall
///   * premium == unknown → renders [child] and lets the screen's own
///     server-side 403 handling decide (no regression while profile loads,
///     and a transient profile-fetch failure never locks out a paying user).
///
/// When premium transitions from known-not-premium → premium, [onUnlocked]
/// fires so the wrapped feature can (re)fetch its premium-only data. This is
/// the invalidation hook other layers (e.g. cache clearing) can also hang off
/// of by listening to [ProfileCubit] the same way.
class PremiumGate extends StatelessWidget {
  const PremiumGate({
    super.key,
    required this.child,
    this.onUnlocked,
  });

  final Widget child;

  /// Called once each time premium flips from false → true.
  final VoidCallback? onUnlocked;

  /// Returns the premium status for a given [ProfileState]:
  /// `true`/`false` when known, `null` while it is still unknown.
  static bool? isPremium(ProfileState state) {
    if (state is ProfileLoaded) return state.limits.isSubscriptionActive;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) =>
          isPremium(prev) == false && isPremium(curr) == true,
      listener: (context, state) => onUnlocked?.call(),
      buildWhen: (prev, curr) => isPremium(prev) != isPremium(curr),
      builder: (context, state) {
        // Only block when we KNOW the user is not premium. Unknown → defer to
        // child (which keeps its server-authoritative 403 gating as fallback).
        if (isPremium(state) == false) {
          return const SafeArea(child: PremiumRequiredView());
        }
        return child;
      },
    );
  }
}
