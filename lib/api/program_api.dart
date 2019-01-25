part of 'api.dart';

/// Controller to interact with Programs
@GenController(path: '/program')
class ProgramRoutes extends Controller {
  /// Route to create a new program
  @PostJson()
  Future<Map> create(Context ctx) async {
    final data = await ctx.bodyAsJson(
        convert: ProgramCreatorSerializer.serializer.fromMap);
    final ServerUser user = ctx.getVariable<ServerUser>();

    // Establish database connection
    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);

    // Create the program
    final progId = await accessor.create(data, user.id);

    // Fetch the program
    return accessor.get(progId);
  }

  /// Route to save a program
  @PutJson(path: '/:id')
  Future<Map> save(Context ctx) async {
    String id = ctx.pathParams['id'];
    final ServerUser user = ctx.getVariable<ServerUser>();

    final data = await ctx.bodyAsJsonMap();

    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);

    // Check if the current user has write access
    ProgramInfo info = await accessor.getInfo(id);
    if (info == null) {
      ctx.response = Response(programNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasWriteAccess(user.id)) {
      ctx.response = Response(programNoWriteAccess, statusCode: 401);
      return null;
    }

    // Save
    await accessor.save(id, data);

    // Fetch the program
    return accessor.get(id);
  }

  /// Route to get a program by id
  @GetJson(path: '/:id')
  Future<Map> getById(Context ctx) async {
    String id = ctx.pathParams['id'];
    final ServerUser user = ctx.getVariable<ServerUser>();

    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);

    // Check if the user has read access
    ProgramInfo info = await accessor.getInfo(id);
    if (info == null) {
      ctx.response = Response(programNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasReadAccess(user.id)) {
      ctx.response = Response(programNoReadAccess, statusCode: 401);
      return null;
    }

    return accessor.get(id);
  }

  /// Route to delete a program by id
  @DeleteJson(path: '/:id')
  Future<void> delete(Context ctx) async {
    String id = ctx.pathParams['id'];
    final ServerUser user = ctx.getVariable<ServerUser>();

    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);

    // Check if the current user has write access
    ProgramInfo info = await accessor.getInfo(id);
    if (info == null) {
      ctx.response = Response(programNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasWriteAccess(user.id)) {
      ctx.response = Response(programNoWriteAccess, statusCode: 401);
      return null;
    }

    await accessor.delete(id);
  }

  /* TODO
  /// Route to edit a program
  @PutJson(path: '/edit/:id')
  Future<Map> edit(Context ctx) async {
    String id = ctx.pathParams['id'];
    final ServerUser user = ctx.getVariable<ServerUser>();

    // Establish connection to database
    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);

    // Check if the current user has write access
    ProgramInfo info = await accessor.getInfo(id);
    if (info == null) {
      ctx.response = Response(programNotFound, statusCode: 401);
      return null;
    }
    if(!info.hasWriteAccess(user.id)) {
      ctx.response = Response(programNoWriteAccess, statusCode: 401);
      return null;
    }

    /* TODO
    Map data = await ctx.req.bodyAsJsonMap();
    await accessor.edit(progId, data['name'], data['width'], data['height'],
        data['writers'], data['readers']);
    */

    return accessor.get(id);
  }
  */

  /// Transfer ownership
  @Post(path: '/ownership/:id/:newOwnerId')
  Future<void> transferOwnership(Context ctx) async {
    String id = ctx.pathParams['id'];
    String newOwnerId = ctx.pathParams['newOwnerId'];
    final ServerUser user = ctx.getVariable<ServerUser>();

    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);

    ProgramInfo info = await accessor.getInfo(id);
    if (info.owner != user.id) {
      ctx.response = Response(programNotOwner, statusCode: 401);
      return null;
    }

    // TODO check if the new user exists

    // Set new owner id
    await accessor.setOwner(id, newOwnerId);
  }

  @GetJson()
  Future<List<Map>> getAll(Context ctx) async {
    final ServerUser user = ctx.getVariable<ServerUser>();

    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);

    // TODO
  }

  /// Route to duplicate a program
  @PostJson(path: '/duplicate/:id')
  Future<Map> duplicate(Context ctx) async {
    String id = ctx.pathParams['id'];
    final ServerUser user = ctx.getVariable<ServerUser>();

    final db = await pool(ctx);
    final accessor = ProgramAccessor(db);

    // Check if the user has read access
    ProgramInfo info = await accessor.getInfo(id);
    if (info == null) {
      ctx.response = Response(programNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasReadAccess(user.id)) {
      ctx.response = Response(programNoReadAccess, statusCode: 401);
      return null;
    }

    Map map = await accessor.get(id);

    String newId = await accessor.duplicate(map);

    return accessor.get(newId);
  }

  /* TODO
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
