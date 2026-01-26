part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
  bool get isBuildable => true;
  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Users users;
  final Limits limits;

  const ProfileLoaded({required this.users, required this.limits});

  @override
  List<Object> get props => super.props..addAll([users, limits]);
}

class ProfileFailure extends ProfileState {
  final Object error;
  final DateTime timestamp;

  ProfileFailure({required this.error}) : timestamp = DateTime.now();

  @override
  bool get isBuildable => false;

  @override
  List<Object> get props => super.props..addAll([error, timestamp]);
}


final class DeleteSuccess extends ProfileState{}