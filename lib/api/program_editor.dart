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

  Future<List<Map>> getByUser(String user) => db
      .collection('p')
      .find(where
        ..or(where.eq('owner', user))
        ..or(where.oneFrom('writers', [user]))
        ..or(where.oneFrom('readers', [user])))
      .toList();

  Future<Map> save(String id, Map data) =>
      db.collection('p').update(where.id(new ObjectId.fromHexString(id)), data);

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

MongoDb mongo(Context ctx) =>
    new MongoDb('mongodb://localhost:27017/digislides');

@Api(path: '/api/program')
@Wrap(const [mongo])
class ProgramEditorRoutes {
  String getUserId(Context ctx) => '1' * 24;

  programByIdNotFound(String id) => new Exception();

  doNotHaveReadAccess(String id) => new Exception();

  doNotHaveWriteAccess(String id) => new Exception();

  /// Route to create a new program
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

  /// Route to save a program
  @PutJson(path: '/:id')
  Future<Map> save(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    Db db = ctx.getInterceptorResult<Db>(MongoDb);
    final accessor = new ProgramAccessor(db);
    Map map = await accessor.get(progId);
    if (map == null) throw programByIdNotFound(progId);
    Program pg = new Program.fromMap(map);
    if (!pg.hasWriteAccess(userId)) throw doNotHaveWriteAccess(progId);
    Map data = await ctx.req.bodyAsJsonMap();
    data['name'] = map['name'];
    data['owner'] = map['owner'];
    data['writers'] = map['writers'];
    data['readers'] = map['readers'];
    data.remove('_id');
    await accessor.save(progId, data);
    return accessor.get(progId);
  }

  /// Route to get a program by id
  @GetJson(path: '/:id')
  Future<Map> getById(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    Db db = ctx.getInterceptorResult<Db>(MongoDb);
    Map map = await new ProgramAccessor(db).get(progId);
    if (map == null) throw programByIdNotFound(progId);
    Program pg = new Program.fromMap(map);
    if (!pg.hasReadAccess(userId))  throw doNotHaveReadAccess(progId);
    return map;
  }

  /// Route to delete a program by id
  @DeleteJson(path: '/:id')
  Future<List<Map>> delete(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    Db db = ctx.getInterceptorResult<Db>(MongoDb);
    final accessor = new ProgramAccessor(db);
    Map map = await accessor.get(progId);
    if (map == null) throw programByIdNotFound(progId);
    Program pg = new Program.fromMap(map);
    if (!pg.hasWriteAccess(userId))  throw doNotHaveWriteAccess(progId);
    await accessor.delete(progId);
    return accessor.getByUser(userId);
  }

  @GetJson()
  Future<List<Map>> getAll(Context ctx) async {
    String userId = getUserId(ctx);
    Db db = ctx.getInterceptorResult<Db>(MongoDb);
    final accessor = new ProgramAccessor(db);
    return accessor.getByUser(userId);
  }

  /// Route to duplicate a program
  Future<Map> duplicate(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    Db db = ctx.getInterceptorResult<Db>(MongoDb);
    final accessor = new ProgramAccessor(db);
    Map map = await accessor.get(progId);
    if (map == null) throw programByIdNotFound(progId);
    Program pg = new Program.fromMap(map);
    if (!pg.hasReadAccess(userId))  throw doNotHaveReadAccess(progId);

    map['name'] = map['name'] + '_Copy';
    map['owner'] = userId;
    data['writers'] = map['writers'];
    data['readers'] = map['readers'];
    data.remove('_id');

    // TODO

    await accessor.create(map);
    return accessor.get(newprogId.toHexString());
  }

  /// Route to edit a program
  @PutJson(path: '/edit/:id')
  Future<Map> edit(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    Db db = ctx.getInterceptorResult<Db>(MongoDb);
    final accessor = new ProgramAccessor(db);
    Map map = await accessor.get(progId);
    if (map == null) throw programByIdNotFound(progId);
    Program pg = new Program.fromMap(map);
    if (!pg.hasWriteAccess(userId))  throw doNotHaveWriteAccess(progId);
    Map data = await ctx.req.bodyAsJsonMap();
    await accessor.edit(progId, data['name'], data['width'], data['height'],
        data['writers'], data['readers']);
    return accessor.get(progId);
  }
}

class Published {
  String id;

  String name;

  String programId;

  String version;

  dynamic data;
}

class PublishedRoutes {
  publish(Context ctx) {
    // TODO
  }

  listPublished(Context ctx) {
    // TODO
  }
}

class Frame {
  String id;

  int width;

  int height;

  String programId;

  String programVersion;
}

class Player {
  String id;

  String owner;

  int width;

  int height;

  List<Frame> frames;
}

class PlayerRoutes {
  create(Context ctx) {
    // TODO
  }

  save(Context ctx) {
    // TODO
  }

  delete(Context ctx) {
    // TODO
  }

  get(Context ctx) {
    // TODO
  }

  getAll(Context ctx) {
    // TODO
  }

  duplicate(Context ctx) {
    // TODO
  }

  getRunning(Context ctx) {
    // TODO
  }
}
