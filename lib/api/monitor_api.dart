part of 'api.dart';

@GenController(path: '/api/monitor')
class MonitorRoutes extends Controller {
  /// Route to create a new player
  @PostJson()
  Future<Monitor> create(Db db, MonitorCreator data, ServerUser user) async {
    final accessor = MonitorAccessor(db);

    // Create the channel
    String id = await accessor.create(data, user.id);

    // Fetch the channel
    return accessor.get(id);
  }

  @PostJson(path: '/:id/duplicate')
  Future<Monitor> duplicate(
      Context ctx, Db db, String id, ServerUser user) async {
    final accessor = MonitorAccessor(db);

    // Check if the user has read access
    Monitor info = await accessor.get(id);
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

  @PutJson(path: '/:id')
  Future<Monitor> save(Context ctx, String id, Db db, ServerUser user,
      MonitorCreator data) async {
    final accessor = MonitorAccessor(db);

    // Check if the user has read access
    Monitor info = await accessor.get(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasWriteAccess(user.id)) {
      ctx.response = Response(noReadAccess, statusCode: 401);
      return null;
    }

    await accessor.save(id, data);

    return accessor.get(id);
  }

  /// Route to delete a program by id
  @DeleteJson(path: '/:id')
  Future<void> delete(Context ctx, String id, Db db, ServerUser user) async {
    final accessor = MonitorAccessor(db);

    // Check if user has access to the channel
    Monitor ch = await accessor.get(id);
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

  @GetJson(path: '/:id')
  Future<Monitor> get(Context ctx, String id, Db db, ServerUser user) async {
    final accessor = MonitorAccessor(db);

    // Check if the user has read access
    Monitor info = await accessor.get(id);
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

  @GetJson()
  Future<List<Monitor>> getAll(Context ctx, Db db, ServerUser user) {
    final accessor = MonitorAccessor(db);

    // TODO implement pagination

    return accessor.getByUser(user.id, search: ctx.query['search']);
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
    await Authorizer.authorize<ServerUser>(ctx);
  }
}

@GenController(path: '/api/commander')
class CommanderRoutes extends Controller {
  @WsStream(path: '/:id')
  Future<dynamic> ws(Context ctx, WebSocket ws) async {
    String id = ctx.pathParams['id'];

    WebSocket ws = await ctx.req.upgradeToWebSocket;

    Db db = ctx.getVariable<Db>();
    ServerUser user = ctx.getVariable<ServerUser>();

    final accessor = MonitorAccessor(db);

    /*
    ws.asBroadcastStream();

    // Check if the user has read access
    Channel info = await accessor.get(id);
    if (info == null) {
      return Response(resourceNotFound, statusCode: 401);
    }
    if (!info.hasReadAccess(user.id)) {
      return Response(noReadAccess, statusCode: 401);
    }
    */

    /*
    final sub = playerRT.subscribe(id);

    return sub.stream.map((e) => json.encode({
          'event': e.event,
          'data': e.data,
        }));
        */
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
  }
}
