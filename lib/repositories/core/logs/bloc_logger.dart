
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';


class BlocInitializer {
  static void init() {
    Bloc.observer = TalkerBlocObserver(
      talker: talker,
      settings: const TalkerBlocLoggerSettings(
        printEventFullData: false,
        printStateFullData: false,
      ),
    );
  }
}
