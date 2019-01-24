part of 'api.dart';

@GenController(path: '/program')
class ProgramEditorRoutes {
  /// Route to create a new program
  @PostJson()
  Future<Map> create(Context ctx) async {
    final data = await ctx.bodyAsJson(
        convert: ProgramCreatorSerializer.serializer.fromMap);

    // Establish database connection
    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);

    // Create the program
    final progId = await accessor.create(data);

    // Fetch the program
    return accessor.get(progId);
  }

  /* TODO
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
  */

  /// Route to get a program by id
  @GetJson(path: '/:id')
  Future<Map> getById(Context ctx) async {
    String progId = ctx.pathParams['id'];
    final db = await pool(ctx);
    Map map = await ProgramAccessor(db).get(progId);
    if (map == null) throw programByIdNotFound(progId);
    // TODO check if the current user has read access to the program
    return map;
  }

  /// Route to delete a program by id
  @DeleteJson(path: '/:id')
  Future<void> delete(Context ctx) async {
    String progId = ctx.pathParams['id'];
    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);
    Map map = await accessor.get(progId);
    if (map == null) throw programByIdNotFound(progId);
    // TODO check if current user has write access to the program
    await accessor.delete(progId);
  }

  /* TODO
  @GetJson()
  Future<List<Map>> getAll(Context ctx) async {
    String userId = getUserId(ctx);
    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);
    return accessor.getByUser(userId);
  }
  */

  /* TODO
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
  */

  /* TODO
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
  */

  /*
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
  */
}
