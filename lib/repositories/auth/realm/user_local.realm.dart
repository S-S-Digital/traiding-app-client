// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_local.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class UserLocal extends _UserLocal
    with RealmEntity, RealmObjectBase, RealmObject {
  UserLocal(
    String id,
    String email,
    String phone,
    String accessToken,
    String refreshToken,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'accessToken', accessToken);
    RealmObjectBase.set(this, 'refreshToken', refreshToken);
  }

  UserLocal._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get email => RealmObjectBase.get<String>(this, 'email') as String;
  @override
  set email(String value) => RealmObjectBase.set(this, 'email', value);

  @override
  String get phone => RealmObjectBase.get<String>(this, 'phone') as String;
  @override
  set phone(String value) => RealmObjectBase.set(this, 'phone', value);

  @override
  String get accessToken =>
      RealmObjectBase.get<String>(this, 'accessToken') as String;
  @override
  set accessToken(String value) =>
      RealmObjectBase.set(this, 'accessToken', value);

  @override
  String get refreshToken =>
      RealmObjectBase.get<String>(this, 'refreshToken') as String;
  @override
  set refreshToken(String value) =>
      RealmObjectBase.set(this, 'refreshToken', value);

  @override
  Stream<RealmObjectChanges<UserLocal>> get changes =>
      RealmObjectBase.getChanges<UserLocal>(this);

  @override
  Stream<RealmObjectChanges<UserLocal>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<UserLocal>(this, keyPaths);

  @override
  UserLocal freeze() => RealmObjectBase.freezeObject<UserLocal>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'email': email.toEJson(),
      'phone': phone.toEJson(),
      'accessToken': accessToken.toEJson(),
      'refreshToken': refreshToken.toEJson(),
    };
  }

  static EJsonValue _toEJson(UserLocal value) => value.toEJson();
  static UserLocal _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'email': EJsonValue email,
        'phone': EJsonValue phone,
        'accessToken': EJsonValue accessToken,
        'refreshToken': EJsonValue refreshToken,
      } =>
        UserLocal(
          fromEJson(id),
          fromEJson(email),
          fromEJson(phone),
          fromEJson(accessToken),
          fromEJson(refreshToken),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(UserLocal._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, UserLocal, 'UserLocal', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('email', RealmPropertyType.string),
      SchemaProperty('phone', RealmPropertyType.string),
      SchemaProperty('accessToken', RealmPropertyType.string),
      SchemaProperty('refreshToken', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
