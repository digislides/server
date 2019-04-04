part of 'api.dart';

@GenController(path: '/api/media/video')
class MediaVideoRoutes extends Controller {
  /// Route to create a new program
  @PostJson()
  Future<MediaVideo> create(Context ctx, Db db, ServerUser user) async {
    // TODO validate

    final data = await ctx.bodyAsMap().then((m) {
      m = m.map<String, dynamic>((k, v) => MapEntry(k, v));
      print(m);
      String tags = m["tags"];
      if (tags != null && tags.length > 2) {
        m["tags"] = tags.substring(1, tags.length - 1).split(",").toList();
      } else {
        m["tags"] = null;
      }
      return MediaCreator.serializer.fromMap(m);
    });

    final fileField = await ctx.getBinaryFile("file");

    final id = idGenerator.generate();
    final extension = path.extension(data.name);
    final p = path.join(config.mediaDir, "$id$extension");
    final file = await fileField.writeTo(p); // TODO catch failures
    final length = await file.length();

    // Establish database connection
    final accessor = MediaVideoAccessor(db);

    final model = MediaVideo(
        id: id,
        name: path.basenameWithoutExtension(data.name),
        owner: user.id,
        tags: data.tags ?? [],
        extension: extension,
        storage: length);

    // Create the program
    await accessor.create(model);

    // Fetch the program
    return accessor.get(id);
  }

  /// Route to save a program
  @PutJson(path: '/:id')
  Future<MediaVideo> save(
      Context ctx, Db db, String id, ServerUser user, MediaCreator data) async {
    final accessor = MediaVideoAccessor(db);

    // Check if the current user has write access
    MediaVideo info = await accessor.get(id);
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
  Future<MediaVideo> getById(
      Context ctx, Db db, String id, ServerUser user) async {
    final accessor = MediaVideoAccessor(db);

    // Check if the user has read access
    MediaVideo info = await accessor.get(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasReadAccess(user.id)) {
      ctx.response = Response(noWriteAccess, statusCode: 401);
      return null;
    }

    return accessor.get(id);
  }

  /// Route to delete a program by id
  @DeleteJson(path: '/:id')
  Future<void> delete(Context ctx, Db db, String id, ServerUser user) async {
    final accessor = MediaVideoAccessor(db);

    // Check if the current user has write access
    MediaVideo info = await accessor.get(id);
    if (info == null) {
      ctx.response = Response(resourceNotFound, statusCode: 401);
      return null;
    }
    if (!info.hasWriteAccess(user.id)) {
      ctx.response = Response(noWriteAccess, statusCode: 401);
      return null;
    }

    await accessor.delete(id);

    // Delete file
    Future.microtask(() async {
      try {
        final f = File(path.join(config.mediaDir, id + info.extension));
        await f.delete();
      } catch (e) {}
    });
  }

  /*
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
  */

  @GetJson()
  Future<List<MediaVideo>> getAll(Context ctx, Db db, ServerUser user) async {
    final accessor = MediaVideoAccessor(db);

    // TODO implement pagination

    return accessor.getByUser(user.id, search: ctx.query['search']);
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool.call(ctx);
    await Authorizer.authorize<ServerUser>(ctx);
  }
}
