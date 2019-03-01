part of 'db.dart';

Map removeId(Map map) {
  if (map == null) return null;
  map.remove("_id");
  return map;
}

class ProgramAccessor {
  Db db;

  ProgramAccessor(this.db);

  DbCollection get col => db.collection('p');

  Future<String> create(Program model) async {
    final id = ObjectId();
    final idStr = id.toHexString();
    final query = Program.serializer.toMap(model)
      ..addAll({
        "_id": id,
        "id": idStr,
        "savedAt": DateTime.now().toUtc().millisecondsSinceEpoch,
      });
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
    return col.findOne(where.id(ObjectId.fromHexString(id))).then(removeId);
  }

  Future<ProgramInfo> getInfo(String id) {
    return col
        .findOne(where
            .id(ObjectId.fromHexString(id))
            .excludeFields(['design', 'published']))
        .then(ProgramInfo.serializer.fromMap);
  }

  Future<List<Map>> getByUser(String user, {String search: ''}) {
    final b = where.eq('owner', user);
    // TODO also fetch records with write and read access
    // Name search
    if (search != null && search.isNotEmpty) {
      if (!search.contains("^\$")) {
        search = ".*$search.*";
      }
      b.eq("name", {"\$regex": search});
    }
    return col.find(b).map(removeId).toList();
  }

  Future<List<Map>> getRecent(String user) {
    // TODO also fetch records with write and read access
    final b =
        where.eq('owner', user).sortBy("savedAt", descending: true).limit(5);
    return col.find(b).map(removeId).toList();
  }

  Future<void> save(String id, Map data) async {
    await col.update(
        where.id(ObjectId.fromHexString(id)),
        modify
            .set("design", data)
            .set("savedAt", DateTime.now().toUtc().millisecondsSinceEpoch));
  }

  Future<void> setName(String id, String name) async {
    await col.update(
        where.id(ObjectId.fromHexString(id)), modify.set('name', name));
  }

  Future<void> setOwner(String id, String owner) async {
    await col.update(
        where.id(ObjectId.fromHexString(id)), modify.set('owner', owner));
    // TODO
  }

  Future<void> setPublish(String id, Map data, int at) => col.update(
      where.id(ObjectId.fromHexString(id)),
      modify.set('published', data).set('publishedAt', at));

  Future<Map> getPublished(String id) => col.findOne(where
      .id(ObjectId.fromHexString(id))
      .fields(['id', 'published', 'publishedAt']));

  Future<void> delete(String id) async {
    await col.remove(where.id(ObjectId.fromHexString(id)));
  }
}
