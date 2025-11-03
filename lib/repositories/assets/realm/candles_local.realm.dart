// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candles_local.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class CandlesLocal extends _CandlesLocal
    with RealmEntity, RealmObjectBase, RealmObject {
  CandlesLocal(
    String id,
    int openTime,
    String open,
    String high,
    String low,
    String close,
    String volume,
    int closeTime,
    String quoteAssetVolume,
    int numberOfTrades,
    String takerBuyBaseAssetVolume,
    String takerBuyQuoteAssetVolume,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'openTime', openTime);
    RealmObjectBase.set(this, 'open', open);
    RealmObjectBase.set(this, 'high', high);
    RealmObjectBase.set(this, 'low', low);
    RealmObjectBase.set(this, 'close', close);
    RealmObjectBase.set(this, 'volume', volume);
    RealmObjectBase.set(this, 'closeTime', closeTime);
    RealmObjectBase.set(this, 'quoteAssetVolume', quoteAssetVolume);
    RealmObjectBase.set(this, 'numberOfTrades', numberOfTrades);
    RealmObjectBase.set(
      this,
      'takerBuyBaseAssetVolume',
      takerBuyBaseAssetVolume,
    );
    RealmObjectBase.set(
      this,
      'takerBuyQuoteAssetVolume',
      takerBuyQuoteAssetVolume,
    );
  }

  CandlesLocal._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  int get openTime => RealmObjectBase.get<int>(this, 'openTime') as int;
  @override
  set openTime(int value) => RealmObjectBase.set(this, 'openTime', value);

  @override
  String get open => RealmObjectBase.get<String>(this, 'open') as String;
  @override
  set open(String value) => RealmObjectBase.set(this, 'open', value);

  @override
  String get high => RealmObjectBase.get<String>(this, 'high') as String;
  @override
  set high(String value) => RealmObjectBase.set(this, 'high', value);

  @override
  String get low => RealmObjectBase.get<String>(this, 'low') as String;
  @override
  set low(String value) => RealmObjectBase.set(this, 'low', value);

  @override
  String get close => RealmObjectBase.get<String>(this, 'close') as String;
  @override
  set close(String value) => RealmObjectBase.set(this, 'close', value);

  @override
  String get volume => RealmObjectBase.get<String>(this, 'volume') as String;
  @override
  set volume(String value) => RealmObjectBase.set(this, 'volume', value);

  @override
  int get closeTime => RealmObjectBase.get<int>(this, 'closeTime') as int;
  @override
  set closeTime(int value) => RealmObjectBase.set(this, 'closeTime', value);

  @override
  String get quoteAssetVolume =>
      RealmObjectBase.get<String>(this, 'quoteAssetVolume') as String;
  @override
  set quoteAssetVolume(String value) =>
      RealmObjectBase.set(this, 'quoteAssetVolume', value);

  @override
  int get numberOfTrades =>
      RealmObjectBase.get<int>(this, 'numberOfTrades') as int;
  @override
  set numberOfTrades(int value) =>
      RealmObjectBase.set(this, 'numberOfTrades', value);

  @override
  String get takerBuyBaseAssetVolume =>
      RealmObjectBase.get<String>(this, 'takerBuyBaseAssetVolume') as String;
  @override
  set takerBuyBaseAssetVolume(String value) =>
      RealmObjectBase.set(this, 'takerBuyBaseAssetVolume', value);

  @override
  String get takerBuyQuoteAssetVolume =>
      RealmObjectBase.get<String>(this, 'takerBuyQuoteAssetVolume') as String;
  @override
  set takerBuyQuoteAssetVolume(String value) =>
      RealmObjectBase.set(this, 'takerBuyQuoteAssetVolume', value);

  @override
  Stream<RealmObjectChanges<CandlesLocal>> get changes =>
      RealmObjectBase.getChanges<CandlesLocal>(this);

  @override
  Stream<RealmObjectChanges<CandlesLocal>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<CandlesLocal>(this, keyPaths);

  @override
  CandlesLocal freeze() => RealmObjectBase.freezeObject<CandlesLocal>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'openTime': openTime.toEJson(),
      'open': open.toEJson(),
      'high': high.toEJson(),
      'low': low.toEJson(),
      'close': close.toEJson(),
      'volume': volume.toEJson(),
      'closeTime': closeTime.toEJson(),
      'quoteAssetVolume': quoteAssetVolume.toEJson(),
      'numberOfTrades': numberOfTrades.toEJson(),
      'takerBuyBaseAssetVolume': takerBuyBaseAssetVolume.toEJson(),
      'takerBuyQuoteAssetVolume': takerBuyQuoteAssetVolume.toEJson(),
    };
  }

  static EJsonValue _toEJson(CandlesLocal value) => value.toEJson();
  static CandlesLocal _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'openTime': EJsonValue openTime,
        'open': EJsonValue open,
        'high': EJsonValue high,
        'low': EJsonValue low,
        'close': EJsonValue close,
        'volume': EJsonValue volume,
        'closeTime': EJsonValue closeTime,
        'quoteAssetVolume': EJsonValue quoteAssetVolume,
        'numberOfTrades': EJsonValue numberOfTrades,
        'takerBuyBaseAssetVolume': EJsonValue takerBuyBaseAssetVolume,
        'takerBuyQuoteAssetVolume': EJsonValue takerBuyQuoteAssetVolume,
      } =>
        CandlesLocal(
          fromEJson(id),
          fromEJson(openTime),
          fromEJson(open),
          fromEJson(high),
          fromEJson(low),
          fromEJson(close),
          fromEJson(volume),
          fromEJson(closeTime),
          fromEJson(quoteAssetVolume),
          fromEJson(numberOfTrades),
          fromEJson(takerBuyBaseAssetVolume),
          fromEJson(takerBuyQuoteAssetVolume),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CandlesLocal._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      CandlesLocal,
      'CandlesLocal',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('openTime', RealmPropertyType.int),
        SchemaProperty('open', RealmPropertyType.string),
        SchemaProperty('high', RealmPropertyType.string),
        SchemaProperty('low', RealmPropertyType.string),
        SchemaProperty('close', RealmPropertyType.string),
        SchemaProperty('volume', RealmPropertyType.string),
        SchemaProperty('closeTime', RealmPropertyType.int),
        SchemaProperty('quoteAssetVolume', RealmPropertyType.string),
        SchemaProperty('numberOfTrades', RealmPropertyType.int),
        SchemaProperty('takerBuyBaseAssetVolume', RealmPropertyType.string),
        SchemaProperty('takerBuyQuoteAssetVolume', RealmPropertyType.string),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
