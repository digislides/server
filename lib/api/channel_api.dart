part of 'api.dart';

@GenController(path: '/channel')
class ChannelRoutes extends Controller {
  /// Route to create a new player
  @PostJson()
  Future<Channel> create(Context ctx) async {
    ChannelCreator data =
        await ctx.bodyAsJson(convert: ChannelCreator.serializer.fromMap);
    final ServerUser user = ctx.getVariable<ServerUser>();

    // Establish database connection
    final db = await pool(ctx);
    final accessor = ChannelAccessor(db);

    // Create the channel
    String id = await accessor.create(data, user.id);

    // Fetch the channel
    return accessor.get(id);
  }

  @PutJson()
  Future save(Context ctx) {
    // TODO
  }

  /// Route to delete a program by id
  @DeleteJson(path: '/:id')
  Future<void> delete(Context ctx) async {
    String id = ctx.pathParams['id'];
    final ServerUser user = ctx.getVariable<ServerUser>();

    final db = await pool(ctx);
    final accessor = ChannelAccessor(db);

    Channel ch = await accessor.get(id);
    if (ch == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!ch.hasWriteAccess(user.id)) {
      ctx.response = Response(noWriteAccess, statusCode: 401);
      return null;
    }

    await accessor.delete(id);
  }

  @Get(path: '/:id')
  Future<Channel> get(Context ctx) async {
    String id = ctx.pathParams['id'];
    final ServerUser user = ctx.getVariable<ServerUser>();

    final db = await pool(ctx);
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

  @PostJson(path: '/duplicate/:id')
  Future<Channel> duplicate(Context ctx) async {
    String id = ctx.pathParams['id'];
    final ServerUser user = ctx.getVariable<ServerUser>();

    final db = await pool(ctx);
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

  getRunning(Context ctx) {
    // TODO
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
    await Authorizer.authorize<ServerUser>(ctx);
  }
}
