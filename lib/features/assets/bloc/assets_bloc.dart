import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'assets_event.dart';
part 'assets_state.dart';

class AssetsBloc extends Bloc<AssetsEvent, AssetsState> {
  AssetsBloc({required AssetsRepositoryI assetsRepository})
    : _assetsRepository = assetsRepository,
      super(AssetsInitial()) {
        on<Start>(_start);
        on<SearchAsset>(_search);
      }
  final AssetsRepositoryI _assetsRepository;


  Future<void> _start(Start event, Emitter<AssetsState> emit)async{
    try{
      emit(AssetsLoading());
      final popularAssets = await _assetsRepository.fetchPopularAssets();

      emit(AssetsLoaded(assets: popularAssets));
    }
    on AppException catch(error){
      emit(AssetsFailure(error: error));
    }
    
  }


  Future<void> _search(SearchAsset event, Emitter<AssetsState> emit)async{
    try{
      emit(AssetsLoading());

      final assets = await _assetsRepository.searchAssets(event.symbol);

      emit(AssetsLoaded(assets: assets));

    }
    on AppException catch(error){
      emit(AssetsFailure(error: error));
    }
  }
}
