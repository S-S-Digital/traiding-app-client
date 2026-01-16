// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_plans_local.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class SubscriptionPlansLocal extends _SubscriptionPlansLocal
    with RealmEntity, RealmObjectBase, RealmObject {
  SubscriptionPlansLocal(
    String id,
    String name,
    String description,
    int duration,
    String price,
    String currency,
    String appleProductId,
    String googleProductId,
    int maxTickers,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt, {
    Iterable<String> features = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'duration', duration);
    RealmObjectBase.set(this, 'price', price);
    RealmObjectBase.set(this, 'currency', currency);
    RealmObjectBase.set(this, 'appleProductId', appleProductId);
    RealmObjectBase.set(this, 'googleProductId', googleProductId);
    RealmObjectBase.set(this, 'maxTickers', maxTickers);
    RealmObjectBase.set<RealmList<String>>(
      this,
      'features',
      RealmList<String>(features),
    );
    RealmObjectBase.set(this, 'isActive', isActive);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
  }

  SubscriptionPlansLocal._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get description =>
      RealmObjectBase.get<String>(this, 'description') as String;
  @override
  set description(String value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  int get duration => RealmObjectBase.get<int>(this, 'duration') as int;
  @override
  set duration(int value) => RealmObjectBase.set(this, 'duration', value);

  @override
  String get price => RealmObjectBase.get<String>(this, 'price') as String;
  @override
  set price(String value) => RealmObjectBase.set(this, 'price', value);

  @override
  String get currency =>
      RealmObjectBase.get<String>(this, 'currency') as String;
  @override
  set currency(String value) => RealmObjectBase.set(this, 'currency', value);

  @override
  String get appleProductId =>
      RealmObjectBase.get<String>(this, 'appleProductId') as String;
  @override
  set appleProductId(String value) =>
      RealmObjectBase.set(this, 'appleProductId', value);

  @override
  String get googleProductId =>
      RealmObjectBase.get<String>(this, 'googleProductId') as String;
  @override
  set googleProductId(String value) =>
      RealmObjectBase.set(this, 'googleProductId', value);

  @override
  int get maxTickers => RealmObjectBase.get<int>(this, 'maxTickers') as int;
  @override
  set maxTickers(int value) => RealmObjectBase.set(this, 'maxTickers', value);

  @override
  RealmList<String> get features =>
      RealmObjectBase.get<String>(this, 'features') as RealmList<String>;
  @override
  set features(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  bool get isActive => RealmObjectBase.get<bool>(this, 'isActive') as bool;
  @override
  set isActive(bool value) => RealmObjectBase.set(this, 'isActive', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime;
  @override
  set updatedAt(DateTime value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  Stream<RealmObjectChanges<SubscriptionPlansLocal>> get changes =>
      RealmObjectBase.getChanges<SubscriptionPlansLocal>(this);

  @override
  Stream<RealmObjectChanges<SubscriptionPlansLocal>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<SubscriptionPlansLocal>(this, keyPaths);

  @override
  SubscriptionPlansLocal freeze() =>
      RealmObjectBase.freezeObject<SubscriptionPlansLocal>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'description': description.toEJson(),
      'duration': duration.toEJson(),
      'price': price.toEJson(),
      'currency': currency.toEJson(),
      'appleProductId': appleProductId.toEJson(),
      'googleProductId': googleProductId.toEJson(),
      'maxTickers': maxTickers.toEJson(),
      'features': features.toEJson(),
      'isActive': isActive.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(SubscriptionPlansLocal value) => value.toEJson();
  static SubscriptionPlansLocal _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'description': EJsonValue description,
        'duration': EJsonValue duration,
        'price': EJsonValue price,
        'currency': EJsonValue currency,
        'appleProductId': EJsonValue appleProductId,
        'googleProductId': EJsonValue googleProductId,
        'maxTickers': EJsonValue maxTickers,
        'isActive': EJsonValue isActive,
        'createdAt': EJsonValue createdAt,
        'updatedAt': EJsonValue updatedAt,
      } =>
        SubscriptionPlansLocal(
          fromEJson(id),
          fromEJson(name),
          fromEJson(description),
          fromEJson(duration),
          fromEJson(price),
          fromEJson(currency),
          fromEJson(appleProductId),
          fromEJson(googleProductId),
          fromEJson(maxTickers),
          fromEJson(isActive),
          fromEJson(createdAt),
          fromEJson(updatedAt),
          features: fromEJson(ejson['features']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SubscriptionPlansLocal._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      SubscriptionPlansLocal,
      'SubscriptionPlansLocal',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('name', RealmPropertyType.string),
        SchemaProperty('description', RealmPropertyType.string),
        SchemaProperty('duration', RealmPropertyType.int),
        SchemaProperty('price', RealmPropertyType.string),
        SchemaProperty('currency', RealmPropertyType.string),
        SchemaProperty('appleProductId', RealmPropertyType.string),
        SchemaProperty('googleProductId', RealmPropertyType.string),
        SchemaProperty('maxTickers', RealmPropertyType.int),
        SchemaProperty(
          'features',
          RealmPropertyType.string,
          collectionType: RealmCollectionType.list,
        ),
        SchemaProperty('isActive', RealmPropertyType.bool),
        SchemaProperty('createdAt', RealmPropertyType.timestamp),
        SchemaProperty('updatedAt', RealmPropertyType.timestamp),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
