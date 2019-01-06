import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';

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

class ProgramAccessor {
  Db db;

  ProgramAccessor(this.db);

  Future<void> create(Map data) => db.collection('p').insert(data);

  Future<Map> get(String id) =>
      db.collection('p').findOne(where.id(new ObjectId.fromHexString(id)));

  Future<List<Map>> getByUser(String user) {
    SelectorBuilder b = where
        .eq('owner', user)
        .or(where.oneFrom('writers', [user]))
        .or(where.oneFrom('readers', [user]));
    return db.collection('p').find(b).toList();
  }

  Future<Map> save(String id, Map data) =>
      db.collection('p').update(where.id(new ObjectId.fromHexString(id)), data);

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