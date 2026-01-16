import 'package:aspiro_trade/repositories/signals/domain/history.dart';
import 'package:aspiro_trade/repositories/signals/domain/stats.dart';

class HistoryList {
  HistoryList({required this.histories, required this.stats});

  
  final List<History> histories;
  final Stats stats;

  
}
