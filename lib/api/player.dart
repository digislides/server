part of 'api.dart';

@GenController(path: '/player')
class PlayerRoutes extends Controller {
  /// Route to create a new player
  @PostJson()
  Future<Map> create(Context ctx) async {
    User user = ctx.getVariable<User>();
    final db = await pool(ctx);
    final accessor = PlayerAccessor(db);
    Map data = await ctx.bodyAsJsonMap();
    ObjectId plId = ObjectId();
    ProgramCreator cre = ProgramCreator.fromMap(plId, userId, data);
    await accessor.create(cre.toMap);
    return accessor.get(plId.toHexString());
  }

  save(Context ctx) {
    // TODO
  }

  /// Route to delete a program by id
  @DeleteJson(path: '/:id')
  Future<List<Map>> delete(Context ctx) async {
    String userId = getUserId(ctx);
    String plId = ctx.pathParams['id'];
    final db = await pool(ctx);
    final accessor = PlayerAccessor(db);
    Map map = await accessor.get(plId);
    if (map == null) throw programByIdNotFound(plId);
    Player pg = Player.fromMap(map);
    if (!pg.hasWriteAccess(userId)) throw doNotHaveWriteAccess(plId);
    await accessor.delete(plId);
    return accessor.getByUser(userId);
  }

  get(Context ctx) {
    // TODO
  }

  getAll(Context ctx) {
    // TODO
  }

  duplicate(Context ctx) {
    // TODO
  }

  getRunning(Context ctx) {
    // TODO
  }

  @override
  Future<void> before(Context ctx) async {
    // TODO
  }
}
