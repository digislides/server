part of 'api.dart';

@GenController(path: '/api/auth')
class AuthApi extends Controller {
  /// Signup route
  @Post(path: '/signup')
  Future<void> signup(Context ctx, Signup data, Db db) async {
    // TODO data.validate();

    // Hash password
    data.password = pwdHasher.hash(data.password);

    // Open Db connection
    final accessor = UserAccessor(db);

    // Create user
    await accessor.create(data);
  }

  /// Login route
  @Post(path: '/login')
  Future<void> login(Context ctx) async {
    await JsonAuth.authenticate(ctx, hasher: pwdHasher);
  }

  // TODO logout

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
  }
}

@GenController(path: '/api/user')
class UserApi extends Controller {
  /// Route to read current logged in user info
  @GetJson()
  Future<User> get(ServerUser user) async => user;

  /// Route to change password
  @Put(path: '/pwd')
  Future<void> changePassword(Context ctx, ServerUser user, Db db) async {
    String pwd = await ctx.bodyAsText();
    pwd = pwdHasher.hash(pwd);
    final accessor = UserAccessor(db);
    await accessor.changePwd(user.id, pwd);
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
    await Authorizer.authorize<ServerUser>(ctx);
  }
}
