part of 'api.dart';

@GenController(path: '/api/media/image')
class MediaImageRoutes extends Controller {
  /// Route to create a new program
  @PostJson()
  Future<MediaImage> create(Context ctx, Db db, ServerUser user) async {
    // TODO validate

    final fileField = await ctx.getBinaryFile("file");

    final id = idGenerator.generate();
    final extension = path.extension(fileField.name);
    final p = path.join(config.mediaDir, "$id.$extension");
    final file = await fileField.writeTo(p); // TODO catch failures
    final length = await file.length();

    final data = await ctx.bodyAsMap().then(MediaCreator.serializer.fromMap);

    // Establish database connection
    final accessor = MediaImageAccessor(db);

    final model = MediaImage(
        name: data.name,
        owner: user.id,
        tags: data.tags ?? [],
        storage: length);

    // Create the program
    await accessor.create(model);

    // Fetch the program
    return accessor.get(id);
  }

  /// Route to save a program
  @PutJson(path: '/:id')
  Future<MediaImage> save(
      Context ctx, Db db, String id, ServerUser user, MediaCreator data) async {
    final accessor = MediaImageAccessor(db);

    // Check if the current user has write access
    MediaImage info = await accessor.get(id);
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
  Future<MediaImage> getById(
      Context ctx, Db db, String id, ServerUser user) async {
    final accessor = MediaImageAccessor(db);

    // Check if the user has read access
    MediaImage info = await accessor.get(id);
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
    final accessor = MediaImageAccessor(db);

    // Check if the current user has write access
    MediaImage info = await accessor.get(id);
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
  Future<List<MediaImage>> getAll(Context ctx, Db db, ServerUser user) async {
    final accessor = MediaImageAccessor(db);

    // TODO implement pagination

    return accessor.getByUser(user.id, search: ctx.query['search']);
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool.call(ctx);
    await Authorizer.authorize<ServerUser>(ctx);
  }
}