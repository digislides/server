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

  Future<List<Channel>> getByProgramsId(String programId) {
    return col
        .find(where.eq("program", programId))
        .map(Channel.serializer.fromMap).toList();
  }

  Future<void> save(String id, ChannelCreator data) async {
    await col.update(where.id(ObjectId.fromHexString(id)), data.toJson());
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
