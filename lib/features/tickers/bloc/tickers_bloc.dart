import 'dart:async';
import 'package:aspiro_trade/features/tickers/models/models.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'tickers_event.dart';
part 'tickers_state.dart';

class TickersBloc extends Bloc<TickersEvent, TickersState> {
  TickersBloc({
    required TickersRepositoryI tickersRepository,
    required AssetsRepositoryI assetsRepository,
    required SignalsRepositoryI signalsRepository,
  }) : _tickersRepository = tickersRepository,
       _assetsRepository = assetsRepository,
       _signalsRepository = signalsRepository,
       super(const TickersState()) {
    on<Start>(_onStart);
    on<Refresh>(_onRefresh);
    on<DeleteTicker>(_onDeleteTicker);
    on<UpdateAsset>(_onUpdateAsset);
    on<StopTimer>(_onStopPolling);
  }

  final TickersRepositoryI _tickersRepository;
  final AssetsRepositoryI _assetsRepository;
  final SignalsRepositoryI _signalsRepository;

  // Заменяем Timer на подписку
  StreamSubscription<List<Assets>>? _assetsSubscription;

  Future<void> _onStart(Start event, Emitter<TickersState> emit) async {
    try {
      // Показываем кэш из Realm мгновенно, пока грузится сеть
      if (state.tickers.isEmpty) {
        final localTickers = await _tickersRepository.fetchAllLocalTickers();
        if (localTickers.isNotEmpty) {
          final cachedCombined = localTickers
              .map((t) => CombinedTicker(
                    assets: Assets.empty(t.symbol),
                    tickers: t,
                  ))
              .toList();
          emit(state.copyWith(tickers: cachedCombined, status: Status.loading));
        } else {
          emit(state.copyWith(status: Status.loading));
        }
      } else {
        // Уже есть данные — не показываем спиннер, обновляем в фоне
        emit(state.copyWith(status: Status.loading));
      }

      final tickers = await _tickersRepository.fetchAllTickers();

      // Параллельно загружаем assets + signals для всех тикеров
      final combinedTickers = await Future.wait(
        tickers.map((i) async {
          final results = await Future.wait([
            _assetsRepository.fetchAssetsBySymbol(i.symbol),
            _signalsRepository.fetchSignalsByTickerId(
              i.id, 1, 20, i.symbol, i.timeframe, '', '',
            ),
          ]);
          final asset = results[0] as Assets;
          final signals = results[1] as List<Signals>;
          return CombinedTicker(
            assets: asset,
            tickers: i,
            signals: signals.isEmpty ? null : signals.first,
          );
        }),
      );

      emit(state.copyWith(tickers: combinedTickers, status: Status.loaded));

      // После успешной загрузки запускаем стрим-опрос
      _startPolling(combinedTickers.map((e) => e.tickers.symbol).toList());
    } on AppException catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    } catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  /// Метод для инициализации стрима
  void _startPolling(List<String> symbols) {
    if (symbols.isEmpty) return;

    _assetsSubscription?.cancel();
    _assetsSubscription = _assetsRepository
        .watchAssets(symbols, const Duration(seconds: 20))
        .listen(
          (newAssets) => add(UpdateAsset(newAssets: newAssets)),
          onError: (error) => talker.error("Polling stream error: $error"),
        );
  }

  /// Обработка новых данных из стрима
  Future<void> _onUpdateAsset(
    UpdateAsset event,
    Emitter<TickersState> emit,
  ) async {
    final currentTickers = state.tickers;

    final updatedList = currentTickers.map((ticker) {
      // Ищем обновленный актив в списке пришедшем из события
      final matchingAsset = event.newAssets.firstWhere(
        (a) => a.symbol == ticker.tickers.symbol,
        orElse: () => ticker.assets,
      );

      return ticker.copyWith(assets: matchingAsset);
    }).toList();

    // Эмиттим состояние только если данные реально изменились
    // (благодаря Equatable в CombinedTicker)
    if (updatedList != state.tickers) {
      emit(state.copyWith(tickers: updatedList));
    }
  }

  Future<void> _onDeleteTicker(
    DeleteTicker event,
    Emitter<TickersState> emit,
  ) async {
    try {
      await _tickersRepository.deleteTicker(event.id);

      final updatedTickers = state.tickers
          .where((t) => t.tickers.id != event.id)
          .toList();

      emit(state.copyWith(tickers: updatedTickers));

      // Перезапускаем опрос с новым списком символов
      _startPolling(updatedTickers.map((e) => e.tickers.symbol).toList());
    } on AppException catch (error) {
      emit(state.copyWith(status: Status.failure, error: error));
    }
  }

  Future<void> _onRefresh(Refresh event, Emitter<TickersState> emit) async {
    _assetsSubscription?.cancel();
    await _onStart(Start(), emit);
  }

  void _onStopPolling(StopTimer event, Emitter<TickersState> emit) {
    _assetsSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _assetsSubscription?.cancel();
    return super.close();
  }
}
