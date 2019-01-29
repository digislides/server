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

  Future<void> save(String id, Map data) {
    // TODO
    col.update(where.id(ObjectId.fromHexString(id)), data);
  }

  Future delete(String id) async {
    await col.remove(where.id(ObjectId.fromHexString(id)));
  }
}
