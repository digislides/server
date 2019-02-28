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

  @PostJson(path: '/:id/duplicate')
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

  @PutJson(path: '/:id')
  Future<Channel> save(Context ctx, String id, Db db, ServerUser user,
      ChannelCreator data) async {
    final accessor = ChannelAccessor(db);

    // Check if the user has read access
    Channel info = await accessor.get(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasWriteAccess(user.id)) {
      ctx.response = Response(noReadAccess, statusCode: 401);
      return null;
    }

    await accessor.save(id, data);

    // TODO publish

    return accessor.get(id);
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

  @GetJson(path: '/:id')
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

  @GetJson()
  Future<List<Channel>> getAll(Context ctx, Db db, ServerUser user) {
    final accessor = ChannelAccessor(db);

    // TODO implement pagination

    return accessor.getByUser(user.id, search: ctx.query['search']);
  }

  // TODO transfer ownership

  @GetJson(path: '/:id/version')
  Future<String> getVersion(
      Context ctx, String id, Db db, ServerUser user) async {
    final accessor = ChannelAccessor(db);
    final programAccessor = ProgramAccessor(db);

    Channel info = await accessor.get(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasReadAccess(user.id)) {
      ctx.response = Response(noReadAccess, statusCode: 401);
      return null;
    }

    if (info.program == null) {
      return "none";
    }

    final prog = await programAccessor.getInfo(info.program);
    if (prog == null) {
      ctx.response = Response(programNotFound, statusCode: 401);
      return null;
    }

    if (prog.publishedAt == null) {
      return "none";
    }

    final at = prog.publishedAt.toUtc().millisecondsSinceEpoch;

    return "${prog.id}:$at";
  }

  @GetJson(path: '/:id/content')
  Future<Map> getContent(Context ctx, String id, Db db, ServerUser user) async {
    final accessor = ChannelAccessor(db);
    final programAccessor = ProgramAccessor(db);

    Channel info = await accessor.get(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasReadAccess(user.id)) {
      ctx.response = Response(noReadAccess, statusCode: 401);
      return null;
    }

    if (info.program == null) {
      return null;
    }

    final map = await programAccessor.getPublished(info.program);

    if (map == null) {
      ctx.response = Response(programNotFound, statusCode: 401);
      return null;
    }

    if (map['publishedAt'] == null) {
      return null;
    }

    return <String, dynamic>{
      'id': '${info.program}:${map['publishedAt']}',
      'design': map['published'],
    };
  }

  @Get(path: '/:id/rt')
  Future<void> rt(Context ctx, String id, Db db, ServerUser user) async {
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

    final sub = playerRT.subscribe(id);

    await eventsourceEventStreamer(ctx, sub.stream, onDone: () {
      print("Unsubscribed for $id!");
      sub.unsubscribe();
    });
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
    await Authorizer.authorize<ServerUser>(ctx);
  }
}
