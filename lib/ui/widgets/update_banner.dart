import 'package:aspiro_trade/services/config/app_config_cubit.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Soft, non-blocking "update available" banner.
///
/// Driven by `meta.minAppVersion` from the server config: if the installed
/// version is strictly below it, a thin dismissible bar appears. It never
/// blocks usage. With the baked default (`minAppVersion: 0.0.0`) or when the
/// installed version meets the requirement, this renders nothing — so the
/// crypto UI is unchanged until the server actually raises the floor.
class UpdateBanner extends StatefulWidget {
  const UpdateBanner({super.key});

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  String? _currentVersion;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _currentVersion = info.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed || _currentVersion == null) {
      return const SizedBox.shrink();
    }
    final minVersion =
        context.watch<AppConfigCubit>().state.config.meta.minAppVersion;
    if (!_isBelow(_currentVersion!, minVersion)) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      bottom: false,
      child: Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.brand.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.brand.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.system_update_alt_rounded,
                size: 18, color: AppColors.brand),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.updateAvailable,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.3,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _dismissed = true),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.close_rounded,
                    size: 16, color: AppColors.textTertiary),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// True if [current] is strictly below [minimum] (semver-ish, build metadata
  /// after `+` ignored). Defensive: unparsable parts compare as 0.
  static bool _isBelow(String current, String minimum) {
    final c = _parse(current);
    final m = _parse(minimum);
    final len = c.length > m.length ? c.length : m.length;
    for (var i = 0; i < len; i++) {
      final cv = i < c.length ? c[i] : 0;
      final mv = i < m.length ? m[i] : 0;
      if (cv != mv) return cv < mv;
    }
    return false;
  }

  static List<int> _parse(String v) => v
      .split('+')
      .first
      .split('.')
      .map((p) => int.tryParse(p.trim()) ?? 0)
      .toList();
}
