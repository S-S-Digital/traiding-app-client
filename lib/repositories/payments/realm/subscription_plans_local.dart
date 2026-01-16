import 'package:realm/realm.dart';

part 'subscription_plans_local.realm.dart';

@RealmModel()
class _SubscriptionPlansLocal {
  @PrimaryKey()
  late String id;

  late String name;
  late String description;
  late int duration;
  late String price;
  late String currency;
  late String appleProductId;
  late String googleProductId;
  late int maxTickers;
  late List<String> features;
  late bool isActive;
  late DateTime createdAt;
  late DateTime updatedAt;
}