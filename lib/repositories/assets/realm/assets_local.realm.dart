// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets_local.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class AssetsLocal extends _AssetsLocal
    with RealmEntity, RealmObjectBase, RealmObject {
  AssetsLocal(
    String id,
    String symbol,
    String name,
    String baseAsset,
    String quoteAsset,
    String price,
    String change24h,
    String logoUrl,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'symbol', symbol);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'baseAsset', baseAsset);
    RealmObjectBase.set(this, 'quoteAsset', quoteAsset);
    RealmObjectBase.set(this, 'price', price);
    RealmObjectBase.set(this, 'change24h', change24h);
    RealmObjectBase.set(this, 'logoUrl', logoUrl);
  }

  AssetsLocal._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get symbol => RealmObjectBase.get<String>(this, 'symbol') as String;
  @override
  set symbol(String value) => RealmObjectBase.set(this, 'symbol', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get baseAsset =>
      RealmObjectBase.get<String>(this, 'baseAsset') as String;
  @override
  set baseAsset(String value) => RealmObjectBase.set(this, 'baseAsset', value);

  @override
  String get quoteAsset =>
      RealmObjectBase.get<String>(this, 'quoteAsset') as String;
  @override
  set quoteAsset(String value) =>
      RealmObjectBase.set(this, 'quoteAsset', value);

  @override
  String get price => RealmObjectBase.get<String>(this, 'price') as String;
  @override
  set price(String value) => RealmObjectBase.set(this, 'price', value);

  @override
  String get change24h =>
      RealmObjectBase.get<String>(this, 'change24h') as String;
  @override
  set change24h(String value) => RealmObjectBase.set(this, 'change24h', value);

  @override
  String get logoUrl => RealmObjectBase.get<String>(this, 'logoUrl') as String;
  @override
  set logoUrl(String value) => RealmObjectBase.set(this, 'logoUrl', value);

  @override
  Stream<RealmObjectChanges<AssetsLocal>> get changes =>
      RealmObjectBase.getChanges<AssetsLocal>(this);

  @override
  Stream<RealmObjectChanges<AssetsLocal>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<AssetsLocal>(this, keyPaths);

  @override
  AssetsLocal freeze() => RealmObjectBase.freezeObject<AssetsLocal>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'symbol': symbol.toEJson(),
      'name': name.toEJson(),
      'baseAsset': baseAsset.toEJson(),
      'quoteAsset': quoteAsset.toEJson(),
      'price': price.toEJson(),
      'change24h': change24h.toEJson(),
      'logoUrl': logoUrl.toEJson(),
    };
  }

  static EJsonValue _toEJson(AssetsLocal value) => value.toEJson();
  static AssetsLocal _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'symbol': EJsonValue symbol,
        'name': EJsonValue name,
        'baseAsset': EJsonValue baseAsset,
        'quoteAsset': EJsonValue quoteAsset,
        'price': EJsonValue price,
        'change24h': EJsonValue change24h,
        'logoUrl': EJsonValue logoUrl,
      } =>
        AssetsLocal(
          fromEJson(id),
          fromEJson(symbol),
          fromEJson(name),
          fromEJson(baseAsset),
          fromEJson(quoteAsset),
          fromEJson(price),
          fromEJson(change24h),
          fromEJson(logoUrl),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AssetsLocal._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      AssetsLocal,
      'AssetsLocal',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('symbol', RealmPropertyType.string),
        SchemaProperty('name', RealmPropertyType.string),
        SchemaProperty('baseAsset', RealmPropertyType.string),
        SchemaProperty('quoteAsset', RealmPropertyType.string),
        SchemaProperty('price', RealmPropertyType.string),
        SchemaProperty('change24h', RealmPropertyType.string),
        SchemaProperty('logoUrl', RealmPropertyType.string),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
