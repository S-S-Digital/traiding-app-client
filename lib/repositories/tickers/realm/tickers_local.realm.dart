// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tickers_local.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class TickersLocal extends _TickersLocal
    with RealmEntity, RealmObjectBase, RealmObject {
  TickersLocal(
    String id,
    String userId,
    String symbol,
    String timeframe,
    bool notifyBuy,
    bool notifySell,
    bool isActive,
    DateTime addedAt,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'symbol', symbol);
    RealmObjectBase.set(this, 'timeframe', timeframe);
    RealmObjectBase.set(this, 'notifyBuy', notifyBuy);
    RealmObjectBase.set(this, 'notifySell', notifySell);
    RealmObjectBase.set(this, 'isActive', isActive);
    RealmObjectBase.set(this, 'addedAt', addedAt);
  }

  TickersLocal._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get userId => RealmObjectBase.get<String>(this, 'userId') as String;
  @override
  set userId(String value) => RealmObjectBase.set(this, 'userId', value);

  @override
  String get symbol => RealmObjectBase.get<String>(this, 'symbol') as String;
  @override
  set symbol(String value) => RealmObjectBase.set(this, 'symbol', value);

  @override
  String get timeframe =>
      RealmObjectBase.get<String>(this, 'timeframe') as String;
  @override
  set timeframe(String value) => RealmObjectBase.set(this, 'timeframe', value);

  @override
  bool get notifyBuy => RealmObjectBase.get<bool>(this, 'notifyBuy') as bool;
  @override
  set notifyBuy(bool value) => RealmObjectBase.set(this, 'notifyBuy', value);

  @override
  bool get notifySell => RealmObjectBase.get<bool>(this, 'notifySell') as bool;
  @override
  set notifySell(bool value) => RealmObjectBase.set(this, 'notifySell', value);

  @override
  bool get isActive => RealmObjectBase.get<bool>(this, 'isActive') as bool;
  @override
  set isActive(bool value) => RealmObjectBase.set(this, 'isActive', value);

  @override
  DateTime get addedAt =>
      RealmObjectBase.get<DateTime>(this, 'addedAt') as DateTime;
  @override
  set addedAt(DateTime value) => RealmObjectBase.set(this, 'addedAt', value);

  @override
  Stream<RealmObjectChanges<TickersLocal>> get changes =>
      RealmObjectBase.getChanges<TickersLocal>(this);

  @override
  Stream<RealmObjectChanges<TickersLocal>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<TickersLocal>(this, keyPaths);

  @override
  TickersLocal freeze() => RealmObjectBase.freezeObject<TickersLocal>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'userId': userId.toEJson(),
      'symbol': symbol.toEJson(),
      'timeframe': timeframe.toEJson(),
      'notifyBuy': notifyBuy.toEJson(),
      'notifySell': notifySell.toEJson(),
      'isActive': isActive.toEJson(),
      'addedAt': addedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(TickersLocal value) => value.toEJson();
  static TickersLocal _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'userId': EJsonValue userId,
        'symbol': EJsonValue symbol,
        'timeframe': EJsonValue timeframe,
        'notifyBuy': EJsonValue notifyBuy,
        'notifySell': EJsonValue notifySell,
        'isActive': EJsonValue isActive,
        'addedAt': EJsonValue addedAt,
      } =>
        TickersLocal(
          fromEJson(id),
          fromEJson(userId),
          fromEJson(symbol),
          fromEJson(timeframe),
          fromEJson(notifyBuy),
          fromEJson(notifySell),
          fromEJson(isActive),
          fromEJson(addedAt),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TickersLocal._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      TickersLocal,
      'TickersLocal',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('userId', RealmPropertyType.string),
        SchemaProperty('symbol', RealmPropertyType.string),
        SchemaProperty('timeframe', RealmPropertyType.string),
        SchemaProperty('notifyBuy', RealmPropertyType.bool),
        SchemaProperty('notifySell', RealmPropertyType.bool),
        SchemaProperty('isActive', RealmPropertyType.bool),
        SchemaProperty('addedAt', RealmPropertyType.timestamp),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
