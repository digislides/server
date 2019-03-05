part of 'db.dart';

class ChannelAccessor {
  Db db;

  ChannelAccessor(this.db);

  DbCollection get col => db.collection('c');

  Future<String> create(ChannelCreator model, String owner) async {
    final id = idGenerator.generateReadable();
    final query = ChannelCreator.serializer.toMap(model)
      ..addAll({"id": id, "owner": owner});
    await col.insert(query);
    return id;
  }

  Future<String> duplicate(Channel channel) async {
    final id = idGenerator.generateReadable();
    await col.insert(Channel.serializer.toMap(channel)..['id'] = id);
    return id;
  }

  Future<Channel> get(String id) {
    return col.findOne(where.eq('id', id)).then(Channel.serializer.fromMap);
  }

  Future<List<Channel>> getByProgramsId(String programId) {
    return col
        .find(where.eq("program", programId))
        .map(Channel.serializer.fromMap)
        .toList();
  }

  Future<void> save(String id, ChannelCreator data) async {
    final m = modify;
    final v = data.toJson();
    for (String key in v.keys) {
      m.set(key, v[key]);
    }
    await col.update(where.eq('id', id), m);
  }

  Future<void> delete(String id) async {
    await col.remove(where.eq('id', id));
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

  Future<void> setRunning(String id, ChannelRunning running) async {
    await col.update(where.eq('id', id),
        modify.set("running", ChannelRunning.serializer.toMap(running)));
  }
}
