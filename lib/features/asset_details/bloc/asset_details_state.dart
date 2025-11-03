part of 'asset_details_bloc.dart';

sealed class AssetDetailsState extends Equatable {
  const AssetDetailsState();
  
  bool get isBuildable => true;
  @override
  List<Object> get props => [];
}



final class AssetDetailsInitial extends AssetDetailsState {}



final class AssetDetailsLoading extends AssetDetailsState{}



class AssetDetailsLoaded extends AssetDetailsState{
  final List<Candles> candles;

  const AssetDetailsLoaded({required this.candles});

  @override
  List<Object> get props => super.props..add(candles);
}



class AssetDetailsFailure extends AssetDetailsState{
  final AppException error;
  final DateTime timestamp;

  AssetDetailsFailure({required this.error}) : timestamp = DateTime.now();

  @override
  bool get isBuildable => false;

  @override
  List<Object> get props => super.props..addAll([error, timestamp]);
}
