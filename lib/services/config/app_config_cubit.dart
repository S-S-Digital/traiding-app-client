import 'dart:async';

import 'package:aspiro_trade/api/models/app_config/app_config_dto.dart';
import 'package:aspiro_trade/services/config/config_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the live app config and keeps it fresh.
///
/// State ALWAYS carries a usable config (never null): on construction it seeds
/// with the baked crypto-only default, so any widget reading config has a sane
/// value from frame one. `init()` then layers cache → network on top, and a
/// timer + `onResumed()` keep it refreshed per `meta.refreshSec`.
class AppConfigCubit extends Cubit<AppConfigState> with WidgetsBindingObserver {
  AppConfigCubit({required ConfigService service})
      : _service = service,
        super(AppConfigState(config: service.defaultConfig()));

  final ConfigService _service;
  Timer? _timer;

  /// Cold-start load: prefer last cache (instant, offline-safe), then refresh
  /// from the network in the background. Also registers a lifecycle observer so
  /// we re-fetch on app resume (robust regardless of widget-tree position).
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    final cached = await _service.loadCached();
    if (cached != null) {
      emit(state.copyWith(config: cached, source: ConfigSource.cache));
    }
    await refresh();
    _scheduleTimer();
  }

  /// Re-fetch from the server; on failure keep whatever we currently have.
  Future<void> refresh() async {
    try {
      final fresh = await _service.fetch();
      emit(state.copyWith(config: fresh, source: ConfigSource.network));
      _scheduleTimer();
    } catch (_) {
      // Keep current (cache or default). The app keeps working offline.
    }
  }

  /// Called from the app lifecycle observer on resume.
  void onResumed() => refresh();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResumed();
  }

  void _scheduleTimer() {
    _timer?.cancel();
    final secs = state.config.meta.refreshSec;
    if (secs <= 0) return;
    _timer = Timer(Duration(seconds: secs), refresh);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}

enum ConfigSource { defaults, cache, network }

class AppConfigState extends Equatable {
  const AppConfigState({
    required this.config,
    this.source = ConfigSource.defaults,
  });

  final AppConfigDto config;
  final ConfigSource source;

  AppConfigState copyWith({AppConfigDto? config, ConfigSource? source}) =>
      AppConfigState(
        config: config ?? this.config,
        source: source ?? this.source,
      );

  // Rebuild whenever the config version OR source changes. configVersion is
  // monotonic per admin save, so it's a cheap correct equality signal.
  @override
  List<Object?> get props => [config.meta.configVersion, source];
}
