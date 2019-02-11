part of 'api.dart';

@GenController(path: '/api/channel')
class ChannelRoutes extends Controller {
  /// Route to create a new player
  @PostJson()
  Future<Channel> create(Db db, ChannelCreator data, ServerUser user) async {
    final accessor = ChannelAccessor(db);

    // Create the channel
    String id = await accessor.create(data, user.id);

    // Fetch the channel
    return accessor.get(id);
  }

  @PostJson(path: '/duplicate/:id')
  Future<Channel> duplicate(
      Context ctx, Db db, String id, ServerUser user) async {
    final accessor = ChannelAccessor(db);

    // Check if the user has read access
    Channel info = await accessor.get(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasReadAccess(user.id)) {
      ctx.response = Response(noReadAccess, statusCode: 401);
      return null;
    }

    String newId = await accessor.duplicate(info);

    return accessor.get(newId);
  }

  @PutJson()
  Future save(Context ctx) {
    // TODO
  }

  /// Route to delete a program by id
  @DeleteJson(path: '/:id')
  Future<void> delete(Context ctx, String id, Db db, ServerUser user) async {
    final accessor = ChannelAccessor(db);

    // Check if user has access to the channel
    Channel ch = await accessor.get(id);
    if (ch == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!ch.hasWriteAccess(user.id)) {
      ctx.response = Response(noWriteAccess, statusCode: 401);
      return null;
    }

    // Delete the channel
    await accessor.delete(id);
  }

  @Get(path: '/:id')
  Future<Channel> get(Context ctx, String id, Db db, ServerUser user) async {
    final accessor = ChannelAccessor(db);

    // Check if the user has read access
    Channel info = await accessor.get(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasReadAccess(user.id)) {
      ctx.response = Response(noReadAccess, statusCode: 401);
      return null;
    }

    return info;
  }

  getAll(Context ctx) {
    // TODO
  }

  getRunning(Context ctx) {
    // TODO
  }

  @Get(path: '/version/:id')
  Future<Map> getVersion(Context ctx, String id, Db db, ServerUser user) async {
    final accessor = ChannelAccessor(db);
    final programAccessor = ProgramAccessor(db);

    Channel info = await accessor.get(id);
    if(info == null) {
      // TODO
      return null;
    }

    final prog = programAccessor.get(info.program);
    // TODO
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
    await Authorizer.authorize<ServerUser>(ctx);
  }
}
