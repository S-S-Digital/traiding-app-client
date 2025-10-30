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
