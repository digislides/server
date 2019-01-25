part of 'db.dart';

class UserAccessor {
  final Db db;

  UserAccessor(this.db);

  DbCollection get col => db.collection('u');

  Future<String> create(Signup model) async {
    final id = ObjectId();
    final idStr = id.toString();
    final map = model.toJson();
    map;
    map.addAll({
      '_id': id,
      'id': idStr,
    });
    await col.insert(map);
    return idStr;
  }

  Future<void> changePwd(String id, String pwd) async {
    await col.update(
        where.id(ObjectId.fromHexString(id)), modify.set("password", pwd));
  }

  Future<ServerUser> get(String id) {
    return col
        .findOne(where.id(ObjectId.fromHexString(id)))
        .then(ServerUser.serializer.fromMap);
  }
}
