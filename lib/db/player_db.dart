part of 'db.dart';

class PlayerAccessor {
  Db db;

  PlayerAccessor(this.db);

  DbCollection get pl => db.collection('pl');

  Future<void> create(Map data) => pl.insert(data);

  Future<Map> get(String id) =>
      pl.findOne(where.id(new ObjectId.fromHexString(id)));

  Future<List<Map>> getByUser(String user) {
    SelectorBuilder b = where
        .eq('owner', user)
        .or(where.oneFrom('writers', [user]))
        .or(where.oneFrom('readers', [user]));
    return pl.find(b).toList();
  }

  Future<Map> save(String id, Map data) =>
      pl.update(where.id(new ObjectId.fromHexString(id)), data);

  Future delete(String id) async {
    await pl.remove(where.id(new ObjectId.fromHexString(id)));
  }
}