// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializer.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$ServerUserSerializer implements Serializer<ServerUser> {
  @override
  Map<String, dynamic> toMap(ServerUser model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'pwdHash', model.pwdHash);
    setMapValue(ret, 'authorizationId', model.authorizationId);
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'email', model.email);
    setMapValue(ret, 'name', model.name);
    return ret;
  }

  @override
  ServerUser fromMap(Map map) {
    if (map == null) return null;
    final obj = new ServerUser();
    obj.pwdHash = map['pwdHash'] as String;
    obj.id = map['id'] as String;
    obj.email = map['email'] as String;
    obj.name = map['name'] as String;
    return obj;
  }
}

abstract class _$ProgramInfoSerializer implements Serializer<ProgramInfo> {
  @override
  Map<String, dynamic> toMap(ProgramInfo model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'name', model.name);
    setMapValue(ret, 'owner', model.owner);
    setMapValue(ret, 'members', codeMap(model.members, (val) => val as int));
    return ret;
  }

  @override
  ProgramInfo fromMap(Map map) {
    if (map == null) return null;
    final obj = new ProgramInfo();
    obj.id = map['id'] as String;
    obj.name = map['name'] as String;
    obj.owner = map['owner'] as String;
    obj.members = codeMap<int>(map['members'] as Map, (val) => val as int);
    return obj;
  }
}