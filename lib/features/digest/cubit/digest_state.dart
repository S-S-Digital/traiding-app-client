part of 'digest_cubit.dart';

sealed class DigestState extends Equatable {
  const DigestState();
  bool get isBuildable => true;
  @override
  List<Object> get props => [];
}

final class DigestInitial extends DigestState {}

final class DigestLoading extends DigestState {}

final class DigestLoaded extends DigestState {
  final List<MarketDigest> digests;

  const DigestLoaded({required this.digests});

  @override
  List<Object> get props => super.props..addAll([digests]);
}

final class DigestFailure extends DigestState {
  final Object error;
  final DateTime timestamp;

  DigestFailure({required this.error}) : timestamp = DateTime.now();

  @override
  bool get isBuildable => false;

  @override
  List<Object> get props => super.props..addAll([error, timestamp]);
}
