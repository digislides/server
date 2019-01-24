part of 'api.dart';

@GenController(path: '/auth')
class AuthApi extends Controller {
  @Post(path: '/signup')
  Future<void> signup(Context ctx) async {
    Signup data = await ctx.bodyAsJson(convert: Signup.serializer.fromMap);
    data.validate(); // TODO
    data.password = pwdHasher.hash(data.password);
    final db = ctx.getVariable<Db>();
    final accessor = UserAccessor(db);
    await accessor.create(data);
  }

  @Post(path: '/login')
  Future<void> login(Context ctx) async {
    await JsonAuth.authenticate(ctx, hasher: pwdHasher);
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
  }

  // TODO logout
}

@GenController(path: '/user')
class UserApi extends Controller {
  @GetJson()
  Future<User> get(Context ctx) async {
    return ctx.getVariable<ServerUser>();
  }

  @Put(path: '/pwd')
  Future<void> changePassword(Context ctx) async {
    final user = ctx.getVariable<ServerUser>();
    String pwd = await ctx.bodyAsText();
    pwd = pwdHasher.hash(pwd);
    final db = ctx.getVariable<Db>();
    final accessor = UserAccessor(db);
    await accessor.changePwd(user.id, pwd);
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
    await Authorizer.authorize<ServerUser>(ctx);
  }
}
