part of 'db.dart';

class ChannelAccessor {
  Db db;

  ChannelAccessor(this.db);

  DbCollection get col => db.collection('c');

  Future<String> create(ChannelCreator model, String owner) async {
    final id = ObjectId();
    final idStr = id.toHexString();
    final query = ChannelCreator.serializer.toMap(model)
      ..addAll({"_id": id, "id": idStr, "owner": owner});
    await col.insert(query);
    return idStr;
  }

  Future<String> duplicate(Channel channel) async {
    final id = ObjectId();
    final idStr = id.toString();
    await col.insert(Channel.serializer.toMap(channel)
      ..['id'] = idStr
      ..['_id'] = id);
    return idStr;
  }

  Future<Channel> get(String id) {
    return col
        .findOne(where.id(ObjectId.fromHexString(id)))
        .then(Channel.serializer.fromMap);
  }

  Future<void> save(String id, ChannelCreator data) async {
    final m = modify;
    final v = data.toJson();
    for (String key in v.keys) {
      m.set(key, v[key]);
    }
    await col.update(where.id(ObjectId.fromHexString(id)), m);
  }

  Future<void> delete(String id) async {
    await col.remove(where.id(ObjectId.fromHexString(id)));
  }

  Future<List<Channel>> getByUser(String user, {String search: ''}) {
    final b = where.eq('owner', user);
    // TODO also fetch records with write and read access
    // Name search
    if (search != null && search.isNotEmpty) {
      if (!search.contains("^\$")) {
        search = ".*$search.*";
      }
      b.eq("name", {"\$regex": search});
    }
    return col.find(b).map(removeId).map(Channel.serializer.fromMap).toList();
  }
}
