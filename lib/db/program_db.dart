part of 'db.dart';

class ProgramAccessor {
  Db db;

  ProgramAccessor(this.db);

  DbCollection get col => db.collection('p');

  Future<String> create(ProgramCreator model, String owner) async {
    final id = ObjectId();
    final idStr = id.toString();
    // TODO owner
    final query = ProgramCreator.serializer.toMap(model)
      ..addAll({"_id": id, "id": idStr, "owner": owner});
    await col.insert(query);
    return idStr;
  }

  Future<String> duplicate(Map map) async {
    final id = ObjectId();
    final idStr = id.toString();
    await col.insert(map
      ..['id'] = idStr
      ..['_id'] = id);
    return idStr;
  }

  Future<Map> get(String id) {
    return col.findOne(where.id(ObjectId.fromHexString(id)));
  }

  Future<ProgramInfo> getInfo(String id) {
    return col
        .findOne(where
            .id(ObjectId.fromHexString(id))
            .fields(["id"]).excludeFields(['design']))
        .then(ProgramInfo.serializer.fromMap);
  }

  Future<List<Map>> getByUser(String user) {
    SelectorBuilder b = where
        .eq('owner', user)
        .or(where.oneFrom('writers', [user]))
        .or(where.oneFrom('readers', [user]));
    return col.find(b).toList();
  }

  Future<void> save(String id, Map data) async {
    await col.update(
        where.id(ObjectId.fromHexString(id)), modify.set("design", data));
  }

  Future<void> setOwner(String id, String owner) async {
    await col.update(
        where.id(ObjectId.fromHexString(id)), modify.set('owner', owner));
    // TODO
  }

  Future<Map> setPublish(String id, Map data) => col.update(
      where.id(ObjectId.fromHexString(id)), modify.set('published', data));

  Future delete(String id) async {
    await col.remove(where.id(ObjectId.fromHexString(id)));
  }
}
