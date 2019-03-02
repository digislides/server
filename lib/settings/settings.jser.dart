// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$MyConfigSerializer implements Serializer<MyConfig> {
  @override
  Map<String, dynamic> toMap(MyConfig model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'port', model.port);
    setMapValue(ret, 'mongo', model.mongo);
    setMapValue(ret, 'pwdSalt', model.pwdSalt);
    return ret;
  }

  @override
  MyConfig fromMap(Map map) {
    if (map == null) return null;
    final obj = new MyConfig(
        port: map['port'] as int ?? getJserDefault('port'),
        mongo: map['mongo'] as String ?? getJserDefault('mongo'),
        pwdSalt: map['pwdSalt'] as String ?? getJserDefault('pwdSalt'));
    return obj;
  }
}
