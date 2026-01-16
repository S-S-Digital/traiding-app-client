
import 'package:realm/realm.dart';

part 'signals_local.realm.dart';

@RealmModel()
class _SignalsLocal {
  @PrimaryKey()
  late String id;
  late String symbol;
  late String direction; 
  late String price; 
  late String takeProfit; 
  late String stopLoss; 
  late String currentPrice; 
  late String progressPct; 
  late String profitPct; 
  late String profitUsd; 
  late String status;  
}