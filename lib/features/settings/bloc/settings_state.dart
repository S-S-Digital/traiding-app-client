part of 'settings_bloc.dart';

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

  const SettingsLoaded({required this.users, this.build = '1', this.appVersion = '1.0.0'});

  @override
  List<Object> get props => super.props..add(users);
}

class SettingsFailure extends SettingsState {
  final Object error;
  final DateTime timestamp;

  SettingsFailure({required this.error}) : timestamp = DateTime.now();

  @override
  List<Object> get props => super.props..add([error, timestamp]);
}

class Close extends SettingsState{}


