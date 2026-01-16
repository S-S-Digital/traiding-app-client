// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'asset_details_bloc.dart';

sealed class AssetDetailsState extends Equatable {
  const AssetDetailsState();

  bool get isBuildable => true;
  @override
  List<Object> get props => [];
}

final class AssetDetailsInitial extends AssetDetailsState {}

final class AssetDetailsLoading extends AssetDetailsState {}

class AssetDetailsLoaded extends AssetDetailsState {
  const AssetDetailsLoaded({required this.candles, this.selectedTimeframe, required this.assets});

  AssetDetailsLoaded copyWith({
    List<Candles>? candles,
    Timeframes? selectedTimeframe,
    Assets? assets
  }) {
    return AssetDetailsLoaded(
      candles: candles ?? this.candles,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      assets: assets ?? this.assets
    );
  }

  final List<Candles> candles;
  final Timeframes? selectedTimeframe;
  final Assets assets;

  @override
  List<Object> get props => super.props..add([candles, selectedTimeframe, assets]);
}

class AssetDetailsFailure extends AssetDetailsState {
  final Object error;
  final DateTime timestamp;

  AssetDetailsFailure({required this.error}) : timestamp = DateTime.now();

  @override
  bool get isBuildable => false;

  @override
  List<Object> get props => super.props..addAll([error, timestamp]);
}
