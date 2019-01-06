part of 'api.dart';

@GenController(path: '/program')
class ProgramEditorRoutes {
  /// Route to create a new program
  @PostJson()
  Future<Map> create(Context ctx) async {
    String userId = getUserId(ctx);
    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);
    Map data = await ctx.req.bodyAsJsonMap();
    ObjectId progId = ObjectId();
    var cre = ProgramCreator.fromMap(progId, userId, data);
    await accessor.create(cre.toMap);
    return accessor.get(progId.toHexString());
  }

  /// Route to save a program
  @PutJson(path: '/:id')
  Future<Map> save(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);
    Map map = await accessor.get(progId);
    if (map == null) throw programByIdNotFound(progId);
    var pg = Program.fromMap(map);
    if (!pg.hasWriteAccess(userId)) throw doNotHaveWriteAccess(progId);
    Map data = await ctx.req.bodyAsJsonMap();
    data['name'] = map['name'];
    data['owner'] = map['owner'];
    data['writers'] = map['writers'];
    data['readers'] = map['readers'];
    data['published'] = map['published'];
    data.remove('_id');
    await accessor.save(progId, data);
    return accessor.get(progId);
  }

  /// Route to get a program by id
  @GetJson(path: '/:id')
  Future<Map> getById(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    final db = await pool(ctx);
    Map map = await ProgramAccessor(db).get(progId);
    if (map == null) throw programByIdNotFound(progId);
    Program pg = Program.fromMap(map);
    if (!pg.hasReadAccess(userId)) throw doNotHaveReadAccess(progId);
    return map;
  }

  /// Route to delete a program by id
  @DeleteJson(path: '/:id')
  Future<List<Map>> delete(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);
    Map map = await accessor.get(progId);
    if (map == null) throw programByIdNotFound(progId);
    Program pg = Program.fromMap(map);
    if (!pg.hasWriteAccess(userId)) throw doNotHaveWriteAccess(progId);
    await accessor.delete(progId);
    return accessor.getByUser(userId);
  }

  @GetJson()
  Future<List<Map>> getAll(Context ctx) async {
    String userId = getUserId(ctx);
    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);
    return accessor.getByUser(userId);
  }

  /// Route to duplicate a program
  @PostJson(path: '/duplicate/:id')
  Future<Map> duplicate(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);
    Map map = await accessor.get(progId);
    if (map == null) throw programByIdNotFound(progId);
    Program pg = Program.fromMap(map);
    if (!pg.hasReadAccess(userId)) throw doNotHaveReadAccess(progId);

    map['name'] = map['name'] + '_Copy';
    map['owner'] = userId;
    map['writers'] = null;
    map['readers'] = null;
    map['published'] = null;
    ObjectId newProgId = ObjectId();
    map['_id'] = newProgId;
    await accessor.create(map);
    return accessor.get(newProgId.toHexString());
  }

  /// Route to edit a program
  @PutJson(path: '/edit/:id')
  Future<Map> edit(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);
    Map map = await accessor.get(progId);
    if (map == null) throw programByIdNotFound(progId);
    Program pg = Program.fromMap(map);
    if (!pg.hasWriteAccess(userId)) throw doNotHaveWriteAccess(progId);
    Map data = await ctx.req.bodyAsJsonMap();
    await accessor.edit(progId, data['name'], data['width'], data['height'],
        data['writers'], data['readers']);
    return accessor.get(progId);
  }

  @PostJson(path: '/publish/:id')
  Future<Map> publish(Context ctx) async {
    String userId = getUserId(ctx);
    String progId = ctx.pathParams['id'];
    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);
    Map map = await accessor.get(progId);
    if (map == null) throw programByIdNotFound(progId);
    Program pg = Program.fromMap(map);
    if (!pg.hasWriteAccess(userId)) throw doNotHaveWriteAccess(progId);
    map.remove('name');
    map.remove('owner');
    map.remove('writers');
    map.remove('readers');
    map.remove('published');
    map['on'] = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    await accessor.setPublish(progId, map);
    return accessor.get(progId);
  }
}