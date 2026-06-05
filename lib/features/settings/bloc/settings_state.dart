part of 'settings_bloc.dart';

enum StatsCategory { all, crypto, nonCrypto }

sealed class SettingsState extends Equatable {
  const SettingsState();
  bool get isBuildable => true;
  @override
  List<Object> get props => [];
}

final class SettingsInitial extends SettingsState {}

final class SettingsLoading extends SettingsState {
  @override
  bool get isBuildable => false;
}

class SettingsLoaded extends SettingsState {
  final Users users;
  final String appVersion;
  final String build;
  final SignalStats allStats;
  final SignalStats cryptoStats;
  final SignalStats nonCryptoStats;
  final StatsCategory currentCategory;

  const SettingsLoaded({
    required this.users,
    this.build = '1',
    this.appVersion = '1.0.0',
    this.allStats = SignalStats.empty,
    this.cryptoStats = SignalStats.empty,
    this.nonCryptoStats = SignalStats.empty,
    this.currentCategory = StatsCategory.all,
  });

  SignalStats get currentStats {
    switch (currentCategory) {
      case StatsCategory.all:
        return allStats;
      case StatsCategory.crypto:
        return cryptoStats;
      case StatsCategory.nonCrypto:
        return nonCryptoStats;
    }
  }

  SettingsLoaded copyWith({
    Users? users,
    String? appVersion,
    String? build,
    SignalStats? allStats,
    SignalStats? cryptoStats,
    SignalStats? nonCryptoStats,
    StatsCategory? currentCategory,
  }) {
    return SettingsLoaded(
      users: users ?? this.users,
      appVersion: appVersion ?? this.appVersion,
      build: build ?? this.build,
      allStats: allStats ?? this.allStats,
      cryptoStats: cryptoStats ?? this.cryptoStats,
      nonCryptoStats: nonCryptoStats ?? this.nonCryptoStats,
      currentCategory: currentCategory ?? this.currentCategory,
    );
  }

  @override
  List<Object> get props => [users, allStats, cryptoStats, nonCryptoStats, currentCategory];
}

class SettingsFailure extends SettingsState {
  final Object error;
  final DateTime timestamp;

  SettingsFailure({required this.error}) : timestamp = DateTime.now();

  @override
  List<Object> get props => super.props..add([error, timestamp]);
}

class Close extends SettingsState{}
