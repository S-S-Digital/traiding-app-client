part of 'assets_bloc.dart';

sealed class AssetsEvent extends Equatable {
  const AssetsEvent();

  @override
  List<Object> get props => [];
}

class Start extends AssetsEvent {}

class SearchAsset extends AssetsEvent {
  const SearchAsset({required this.symbol});
  final String symbol;
}


final class UpdateAsset extends AssetsEvent {}

final class StopTimer extends AssetsEvent{}

final class UpdatePrice extends AssetsEvent {
  const UpdatePrice({required this.symbol, required this.price});
  final String symbol;
  final String price;

  @override
  List<Object> get props => [symbol, price];
}