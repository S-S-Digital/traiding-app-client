import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'tickers_event.dart';
part 'tickers_state.dart';

class TickersBloc extends Bloc<TickersEvent, TickersState> {
  TickersBloc() : super(TickersInitial()) {
    on<TickersEvent>((event, emit) {
      
    });
  }

  
}
