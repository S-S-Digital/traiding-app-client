part of 'asset_details_bloc.dart';

class AssetDetailsState extends Equatable {
  const AssetDetailsState({
    this.status = Status.initial,
    this.candles = const [],
    this.selectedTimeframe,
    required this.assets,
    this.error,
  });

  final Status status;
  final List<Candles> candles;
  final Timeframes? selectedTimeframe;
  final Assets assets;
  final Object? error;

  AssetDetailsState copyWith({
    Status? status,
    List<Candles>? candles,
    Timeframes? selectedTimeframe,
    Assets? assets,
    Object? error,
  }) {
    return AssetDetailsState(
      status: status ?? this.status,
      candles: candles ?? this.candles,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      assets: assets ?? this.assets,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    candles,
    selectedTimeframe,
    assets,
    error,
  ];
}
