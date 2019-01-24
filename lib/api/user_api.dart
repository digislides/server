part of 'api.dart';

@GenController(path: '/auth')
class AuthApi extends Controller {
  /// Signup route
  @Post(path: '/signup')
  Future<void> signup(Context ctx) async {
    // Read body from request
    Signup data = await ctx.bodyAsJson(convert: Signup.serializer.fromMap);
    data.validate(); // TODO

    // Hash password
    data.password = pwdHasher.hash(data.password);

    // Open Db connection
    final db = ctx.getVariable<Db>();
    final accessor = UserAccessor(db);

    // Create user
    await accessor.create(data);
  }

  /// Login route
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
  /// Route to read current logged in user info
  @GetJson()
  Future<User> get(Context ctx) async {
    return ctx.getVariable<ServerUser>();
  }

  /// Route to change password
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
