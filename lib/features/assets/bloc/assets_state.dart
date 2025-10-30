// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'assets_bloc.dart';

sealed class AssetsState extends Equatable {
  const AssetsState();
  bool get isBuildable => true;
  @override
  List<Object> get props => [];
}

final class AssetsInitial extends AssetsState {}

final class AssetsLoading extends AssetsState {}

class AssetsLoaded extends AssetsState {
  final List<Assets> assets;

  const AssetsLoaded({required this.assets});

  AssetsLoaded copyWith({List<Assets>? assets}) {
    return AssetsLoaded(assets: assets ?? this.assets);
  }

  @override
  List<Object> get props => super.props..add(assets);
}

class AssetsFailure extends AssetsState {
  final AppException error;
  final DateTime timestamp;

  AssetsFailure({required this.error}) : timestamp = DateTime.now();


  @override
  bool get isBuildable => false;

  @override
  List<Object> get props => super.props..addAll([error, timestamp]);
}
