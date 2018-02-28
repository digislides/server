import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_mongo/jaguar_mongo.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Program {
  String id;

  String name;

  String owner;

  List<String> writers;

  List<String> readers;

  Program.fromMap(Map map) {
    id = map['id'];
    name = map['name'];
    owner = map['owner'];
    writers = map['writers'] ?? <String>[];
    readers = map['readers'] ?? <String>[];
  }

  bool hasReadAccess(String accessorId) =>
      accessorId != null &&
      (owner == accessorId ||
          readers.contains(accessorId) ||
          writers.contains(accessorId));

  bool hasWriteAccess(String accessorId) =>
      accessorId != null &&
      (owner == accessorId || writers.contains(accessorId));
}

class ProgramCreator {
  ObjectId id;

  String owner;

  String name;

  int width;

  int height;

  ProgramCreator.fromMap(this.id, this.owner, Map map) {
    name = map['name'];
    width = map['width'];
    height = map['height'];
  }

  Map get toMap => {
        '_id': id,
        'name': name,
        'width': width,
        'height': height,
        'owner': owner,
      };
}

class ProgramAccessor {
  Db db;

  ProgramAccessor(this.db);

  Future create(Map data) => db.collection('p').insert(data);

  Future<Map> get(String id) =>
      db.collection('p').findOne(where.id(new ObjectId.fromHexString(id)));

  Future<Map> update(String id, Map data) =>
      db.collection('p').update(where.id(new ObjectId.fromHexString(id)), data);

  Future delete(String id) async {
    await db.collection('p').remove(where.id(new ObjectId.fromHexString(id)));
  }
}

MongoDb mongo(Context ctx) => new MongoDb('mongodb://localhost:27017/digislides');

@Api(path: '/api/program')
@Wrap(const [mongo])
class ProgramEditorRoutes {
  String getUserId(Context ctx) => '1' * 24;

  @PostJson()
  Future<Map> create(Context ctx) async {
    String userId = getUserId(ctx);
    Db db = ctx.getInterceptorResult<Db>(MongoDb);
    final accessor = new ProgramAccessor(db);
    Map data = await ctx.req.bodyAsJsonMap();
    ObjectId progId = new ObjectId();
    ProgramCreator cre = new ProgramCreator.fromMap(progId, userId, data);
    await accessor.create(cre.toMap);
    return accessor.get(progId.toHexString());
  }

  @PutJson(path: '/:id')
  Future<Map> update(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    Db db = ctx.getInterceptorResult<Db>(MongoDb);
    final accessor = new ProgramAccessor(db);
    Map map = await accessor.get(progId);
    if (map == null) {
      throw new Exception(); // TODO
    }
    Program pg = new Program.fromMap(map);
    if (!pg.hasWriteAccess(userId)) {
      throw new Exception(
          'Does not have write access'); // TODO throw appropriate error
    }
    Map data = await ctx.req.bodyAsJsonMap();
    data.remove('owner');
    data.remove('writers');
    data.remove('readers');
    await accessor.update(progId, data);
    return accessor.get(progId);
  }

  @GetJson(path: '/:id')
  Future<Map> getById(Context ctx) async {
    String userId = getUserId(ctx);
    Db db = ctx.getInterceptorResult<Db>(MongoDb);
    Map map = await new ProgramAccessor(db).get(ctx.pathParams['id']);
    if (map == null) {
      throw new Exception(); // TODO
    }
    Program pg = new Program.fromMap(map);
    if (!pg.hasReadAccess(userId)) {
      throw new Exception(
          'Does not have read access'); // TODO throw appropriate error
    }
    return map;
  }

  @DeleteJson(path: '/:id')
  delete(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    Db db = ctx.getInterceptorResult<Db>(MongoDb);
    final accessor = new ProgramAccessor(db);
    Map map = await accessor.get(progId);
    if (map == null) {
      throw new Exception(); // TODO
    }
    Program pg = new Program.fromMap(map);
    if (!pg.hasWriteAccess(userId)) {
      throw new Exception(
          'Does not have write access'); // TODO throw appropriate error
    }
    await accessor.delete(progId);
  }
}
