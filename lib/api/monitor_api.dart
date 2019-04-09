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

  @Get(path: '/:id/rt')
  Future<void> ws(Context ctx) async {
    String id = ctx.pathParams['id'];

    Db db = ctx.getVariable<Db>();
    ServerUser user = ctx.getVariable<ServerUser>();

    final accessor = MonitorAccessor(db);

    // Check if the user has read access
    Monitor info = await accessor.get(id);
    if (info == null) {
      return Response(resourceNotFound, statusCode: 401);
    }
    if (!info.hasReadAccess(user.id)) {
      return Response(noReadAccess, statusCode: 401);
    }

    WebSocket ws = await ctx.req.upgradeToWebSocket;

    ws.listen((data) async {
      if(data is! String) return;

      final conn = monitors[id];
      if(conn == null) {
        // TODO
        return;
      }

      final stream = await conn.send(json.decode(data));
      stream.listen((rep) {
        ws.add(rep..[id] = data["id"]);
      });
    });

    ctx.response = SkipResponse();
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
    await Authorizer.authorize<ServerUser>(ctx);
  }
}

@GenController(path: '/api/commander')
class CommanderRoutes extends Controller {
  @Get(path: '/:id')
  Future<void> ws(Context ctx) async {
    String id = ctx.pathParams['id'];

    if (monitors.containsKey(id)) {
      ctx.response = Response("A connection already present!", statusCode: 401);
      return;
    }

    WebSocket ws = await ctx.req.upgradeToWebSocket;

    Db db = ctx.getVariable<Db>();

    final accessor = MonitorAccessor(db);

    final closeDown = () async {
      await ws.close();
    };

    Connection conn;
    Timer handshakeTimer = Timer(Duration(minutes: 2), () async {
      await closeDown();
    });

    ws.listen((data) async {
      if (data is! String) return;

      Map dataMap = jsonDecode(data);

      if (handshakeTimer != null) {
        handshakeTimer.cancel();

        if (monitors.containsKey(id)) {
          await closeDown();
          return;
        }

        // Authenticate
        if (dataMap["repcmd"] == "auth" && dataMap["pwd"] == "1234as") {
          monitors[id] = conn = Connection(ws);
          return;
        }

        await closeDown();
        return;
      }

      await conn.processMessage(dataMap);
    });

    /*
    // Check if the user has read access
    Channel info = await accessor.get(id);
    if (info == null) {
      return Response(resourceNotFound, statusCode: 401);
    }
    if (!info.hasReadAccess(user.id)) {
      return Response(noReadAccess, statusCode: 401);
    }
    */

    ctx.response = SkipResponse();
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
  }
}

final monitors = <String, Connection>{};

class Connection {
  final StreamSink<dynamic /*String|List<int>*/ > ws;

  Connection(this.ws);

  int _i = 0;

  final _links = <int, StreamController<Map>>{};

  void processMessage(Map data) async {
    final int id = data["id"];
    if (id is! int) return;
    final controller = _links[id];
    if (controller == null) return;

    controller.add(data);
    if (data["continue"] != null) {
      _links.remove(id);
      await controller.close();
    }
  }

  Future<Stream<Map>> send(Map data) async {
    final controller = StreamController<Map>();
    int id = _i++;
    _links[id] = controller;
    data["id"] = id;
    ws.add(json.encode(data));
    return controller.stream;
  }
}
