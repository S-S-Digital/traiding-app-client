// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';

class CombinedSignal {
  CombinedSignal({required this.signal, required this.assets});
  final Signals signal;
  final Assets assets;

  

  CombinedSignal copyWith({
    Signals? signal,
    Assets? assets,
  }) {
    return CombinedSignal(
      signal: signal ?? this.signal,
      assets: assets ?? this.assets,
    );
  }
}
