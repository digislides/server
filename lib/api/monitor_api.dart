part of 'api.dart';

@GenController(path: '/api/monitor')
class MonitorRoutes extends Controller {
  @WsStream(path: '/:id/rt')
  Future<dynamic> ws(Context ctx, WebSocket ws) async {
    String id = ctx.pathParams['id'];
    Db db = ctx.getVariable<Db>();
    ServerUser user = ctx.getVariable<ServerUser>();

    final accessor = ChannelAccessor(db);

    // Check if the user has read access
    Channel info = await accessor.get(id);
    if (info == null) {
      return Response(resourceNotFound, statusCode: 401);
    }
    if (!info.hasReadAccess(user.id)) {
      return Response(noReadAccess, statusCode: 401);
    }

    final sub = playerRT.subscribe(id);

    return sub.stream.map((e) => json.encode({
          'event': e.event,
          'data': e.data,
        }));
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
    await Authorizer.authorize<ServerUser>(ctx);
  }
}
