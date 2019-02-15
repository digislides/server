part of 'api.dart';

/// Controller to interact with Programs
@GenController(path: '/api/program')
class ProgramRoutes extends Controller {
  /// Route to create a new program
  @PostJson()
  Future<Map> create(
      Context ctx, Db db, ProgramCreator data, ServerUser user) async {
    // TODO validate

    // Establish database connection
    final accessor = ProgramAccessor(db);

    final program = Program(
        name: data.name,
        owner: user.id,
        members: {},
        design: ProgramDesign(width: data.width, height: data.height, frames: [
          Frame(
              id: newId,
              name: 'Main frame',
              fullview: true,
              left: 0,
              top: 0,
              pages: [],
              width: data.width,
              height: data.height),
        ]));

    // Create the program
    final progId = await accessor.create(program);

    // Fetch the program
    return accessor.get(progId);
  }

  /// Route to save a program
  @PutJson(path: '/:id')
  Future<Map> save(
      Context ctx, Db db, String id, ServerUser user, Map data) async {
    final accessor = ProgramAccessor(db);

    // Check if the current user has write access
    ProgramInfo info = await accessor.getInfo(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasWriteAccess(user.id)) {
      ctx.response = Response(noWriteAccess, statusCode: 401);
      return null;
    }

    // Save
    await accessor.save(id, data);

    // Fetch the program
    return accessor.get(id);
  }

  /// Route to get a program by id
  @GetJson(path: '/:id')
  Future<Map> getById(Context ctx, Db db, String id, ServerUser user) async {
    final accessor = ProgramAccessor(db);

    // Check if the user has read access
    ProgramInfo info = await accessor.getInfo(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasReadAccess(user.id)) {
      ctx.response = Response(noReadAccess, statusCode: 401);
      return null;
    }

    return accessor.get(id);
  }

  /// Route to delete a program by id
  @DeleteJson(path: '/:id')
  Future<void> delete(Context ctx, Db db, String id, ServerUser user) async {
    final accessor = ProgramAccessor(db);

    // Check if the current user has write access
    ProgramInfo info = await accessor.getInfo(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasWriteAccess(user.id)) {
      ctx.response = Response(noWriteAccess, statusCode: 401);
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
  Future<void> transferOwnership(
      Context ctx, Db db, String id, String newOwnerId, ServerUser user) async {
    final accessor = ProgramAccessor(db);

    ProgramInfo info = await accessor.getInfo(id);
    if (info.owner != user.id) {
      ctx.response = Response(notOwner, statusCode: 401);
      return null;
    }

    // TODO check if the new user exists

    // Set new owner id
    await accessor.setOwner(id, newOwnerId);
  }

  @GetJson()
  Future<List<Map>> getRecent(Context ctx, Db db, ServerUser user) async {
    final accessor = ProgramAccessor(db);

    // TODO
  }

  @GetJson()
  Future<List<Map>> getAll(Context ctx, Db db, ServerUser user) async {
    final accessor = ProgramAccessor(db);

    // TODO implement pagination

    return accessor.getByUser(user.id, search: ctx.query['search']);
  }

  /// Route to duplicate a program
  @PostJson(path: '/duplicate/:id')
  Future<Map> duplicate(Context ctx, Db db, String id, ServerUser user) async {
    final accessor = ProgramAccessor(db);

    // Check if the user has read access
    ProgramInfo info = await accessor.getInfo(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasReadAccess(user.id)) {
      ctx.response = Response(noReadAccess, statusCode: 401);
      return null;
    }

    Map map = await accessor.get(id);

    String newId = await accessor.duplicate(map);

    return accessor.get(newId);
  }

  @PostJson(path: '/publish/:id')
  Future<Map> publish(
      Context ctx, Db db, String id, ServerUser user, Map data) async {
    final accessor = ProgramAccessor(db);

    // Check if the current user has write access
    ProgramInfo info = await accessor.getInfo(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasWriteAccess(user.id)) {
      ctx.response = Response(noWriteAccess, statusCode: 401);
      return null;
    }

    // Save
    if (data != null) {
      await accessor.save(id, data);
    }

    final saved = await accessor.get(id);

    await accessor.setPublish(id, saved["design"]);

    // Fetch the program
    return accessor.get(id);
  }

  /// API to return channels this the requested program is running on
  @GetJson(path: '/:id/runningon')
  Future<List<ChannelPublic>> getRunningOn(Context ctx, Db db, String id, ServerUser user, Map data) async {
    final accessor = ProgramAccessor(db);

    // Check if the user has read access
    ProgramInfo info = await accessor.getInfo(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasReadAccess(user.id)) {
      ctx.response = Response(noReadAccess, statusCode: 401);
      return null;
    }

    final channelAccessor = ChannelAccessor(db);
    final channels = await channelAccessor.getByProgramsId(id);

    return channels.map((c) => ChannelPublic.from(c));
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool.call(ctx);
    await Authorizer.authorize<ServerUser>(ctx);
  }
}
