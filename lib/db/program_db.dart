part of 'db.dart';

class ProgramAccessor {
  Db db;

  ProgramAccessor(this.db);

  Future<String> create(ProgramCreator model) async {
    final progId = ObjectId();
    final progIdStr = progId.toString();
    // TODO owner
    final query = ProgramCreator.serializer.toMap(model)
      ..addAll({"_id": progId, "id": progIdStr});
    await db.collection('p').insert(query);
    return progIdStr;
  }

  Future<Map> get(String id) {
    return db.collection('p').findOne(where.id(ObjectId.fromHexString(id)));
  }

  Future<Map> getInfo(String id) {
    return db
        .collection('p')
        .findOne(where.id(ObjectId.fromHexString(id)).fields(["id"]));
  }

  Future<List<Map>> getByUser(String user) {
    SelectorBuilder b = where
        .eq('owner', user)
        .or(where.oneFrom('writers', [user]))
        .or(where.oneFrom('readers', [user]));
    return db.collection('p').find(b).toList();
  }

  Future<void> save(String id, Map data) async {
    await db.collection('p').update(
        where.id(ObjectId.fromHexString(id)), modify.set("design", data));
  }

  Future<Map> setPublish(String id, Map data) => db.collection('p').update(
      where.id(new ObjectId.fromHexString(id)), modify.set('published', data));

  Future<Map> edit(String id, String name, int width, int height,
          List<String> writers, List<String> readers) =>
      db.collection('p').update(
          where.id(new ObjectId.fromHexString(id)),
          modify
            ..set('name', name)
            ..set('width', width)
            ..set('height', height)
            ..set('writers', writers)
            ..set('readers', readers));

  Future delete(String id) async {
    await db.collection('p').remove(where.id(new ObjectId.fromHexString(id)));
  }
}
