import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';

class CombinedHistory {
  CombinedHistory({required this.assets, required this.history});

    CombinedHistory copyWith({
    Assets? assets,
    History? history,
  }) {
    return CombinedHistory(
      assets: assets ?? this.assets,
      history: history ?? this.history,
    );
  }

  final Assets assets;
  final History history;


  
  


}
