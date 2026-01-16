// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signals_local.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class SignalsLocal extends _SignalsLocal
    with RealmEntity, RealmObjectBase, RealmObject {
  SignalsLocal(
    String id,
    String symbol,
    String direction,
    String price,
    String takeProfit,
    String stopLoss,
    String currentPrice,
    String progressPct,
    String profitPct,
    String profitUsd,
    String status,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'symbol', symbol);
    RealmObjectBase.set(this, 'direction', direction);
    RealmObjectBase.set(this, 'price', price);
    RealmObjectBase.set(this, 'takeProfit', takeProfit);
    RealmObjectBase.set(this, 'stopLoss', stopLoss);
    RealmObjectBase.set(this, 'currentPrice', currentPrice);
    RealmObjectBase.set(this, 'progressPct', progressPct);
    RealmObjectBase.set(this, 'profitPct', profitPct);
    RealmObjectBase.set(this, 'profitUsd', profitUsd);
    RealmObjectBase.set(this, 'status', status);
  }

  SignalsLocal._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get symbol => RealmObjectBase.get<String>(this, 'symbol') as String;
  @override
  set symbol(String value) => RealmObjectBase.set(this, 'symbol', value);

  @override
  String get direction =>
      RealmObjectBase.get<String>(this, 'direction') as String;
  @override
  set direction(String value) => RealmObjectBase.set(this, 'direction', value);

  @override
  String get price => RealmObjectBase.get<String>(this, 'price') as String;
  @override
  set price(String value) => RealmObjectBase.set(this, 'price', value);

  @override
  String get takeProfit =>
      RealmObjectBase.get<String>(this, 'takeProfit') as String;
  @override
  set takeProfit(String value) =>
      RealmObjectBase.set(this, 'takeProfit', value);

  @override
  String get stopLoss =>
      RealmObjectBase.get<String>(this, 'stopLoss') as String;
  @override
  set stopLoss(String value) => RealmObjectBase.set(this, 'stopLoss', value);

  @override
  String get currentPrice =>
      RealmObjectBase.get<String>(this, 'currentPrice') as String;
  @override
  set currentPrice(String value) =>
      RealmObjectBase.set(this, 'currentPrice', value);

  @override
  String get progressPct =>
      RealmObjectBase.get<String>(this, 'progressPct') as String;
  @override
  set progressPct(String value) =>
      RealmObjectBase.set(this, 'progressPct', value);

  @override
  String get profitPct =>
      RealmObjectBase.get<String>(this, 'profitPct') as String;
  @override
  set profitPct(String value) => RealmObjectBase.set(this, 'profitPct', value);

  @override
  String get profitUsd =>
      RealmObjectBase.get<String>(this, 'profitUsd') as String;
  @override
  set profitUsd(String value) => RealmObjectBase.set(this, 'profitUsd', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  Stream<RealmObjectChanges<SignalsLocal>> get changes =>
      RealmObjectBase.getChanges<SignalsLocal>(this);

  @override
  Stream<RealmObjectChanges<SignalsLocal>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<SignalsLocal>(this, keyPaths);

  @override
  SignalsLocal freeze() => RealmObjectBase.freezeObject<SignalsLocal>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'symbol': symbol.toEJson(),
      'direction': direction.toEJson(),
      'price': price.toEJson(),
      'takeProfit': takeProfit.toEJson(),
      'stopLoss': stopLoss.toEJson(),
      'currentPrice': currentPrice.toEJson(),
      'progressPct': progressPct.toEJson(),
      'profitPct': profitPct.toEJson(),
      'profitUsd': profitUsd.toEJson(),
      'status': status.toEJson(),
    };
  }

  static EJsonValue _toEJson(SignalsLocal value) => value.toEJson();
  static SignalsLocal _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'symbol': EJsonValue symbol,
        'direction': EJsonValue direction,
        'price': EJsonValue price,
        'takeProfit': EJsonValue takeProfit,
        'stopLoss': EJsonValue stopLoss,
        'currentPrice': EJsonValue currentPrice,
        'progressPct': EJsonValue progressPct,
        'profitPct': EJsonValue profitPct,
        'profitUsd': EJsonValue profitUsd,
        'status': EJsonValue status,
      } =>
        SignalsLocal(
          fromEJson(id),
          fromEJson(symbol),
          fromEJson(direction),
          fromEJson(price),
          fromEJson(takeProfit),
          fromEJson(stopLoss),
          fromEJson(currentPrice),
          fromEJson(progressPct),
          fromEJson(profitPct),
          fromEJson(profitUsd),
          fromEJson(status),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SignalsLocal._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      SignalsLocal,
      'SignalsLocal',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('symbol', RealmPropertyType.string),
        SchemaProperty('direction', RealmPropertyType.string),
        SchemaProperty('price', RealmPropertyType.string),
        SchemaProperty('takeProfit', RealmPropertyType.string),
        SchemaProperty('stopLoss', RealmPropertyType.string),
        SchemaProperty('currentPrice', RealmPropertyType.string),
        SchemaProperty('progressPct', RealmPropertyType.string),
        SchemaProperty('profitPct', RealmPropertyType.string),
        SchemaProperty('profitUsd', RealmPropertyType.string),
        SchemaProperty('status', RealmPropertyType.string),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
