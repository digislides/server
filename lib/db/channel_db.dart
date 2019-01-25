part of 'db.dart';

class ChannelAccessor {
  Db db;

  ChannelAccessor(this.db);

  DbCollection get col => db.collection('c');

  Future<void> create(Map data) {
    // TODO
  }

  Future<Map> get(String id) =>
      col.findOne(where.id(ObjectId.fromHexString(id)));

  Future<List<Map>> getByUser(String user) {
    SelectorBuilder b = where
        .eq('owner', user)
        .or(where.oneFrom('writers', [user]))
        .or(where.oneFrom('readers', [user]));
    return col.find(b).toList();
  }

  Future<Map> save(String id, Map data) =>
      col.update(where.id(ObjectId.fromHexString(id)), data);

  Future delete(String id) async {
    await col.remove(where.id(ObjectId.fromHexString(id)));
  }
}
