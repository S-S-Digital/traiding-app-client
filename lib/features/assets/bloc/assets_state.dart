// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'assets_bloc.dart';

class AssetsState extends Equatable {
  const AssetsState({
    this.status = Status.initial,
    this.assets = const [],
    this.error,
  });
  final Status status;
  final List<Assets> assets;
  final Object? error;

  
  AssetsState copyWith({Status? status, List<Assets>? assets, Object? error}) {
    return AssetsState(
      status: status ?? this.status,
      assets: assets ?? this.assets,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, assets, error];
}
