import 'package:mongo_dart/mongo_dart.dart';
import 'package:jaguar/jaguar.dart';

import 'package:server/models/models.dart';
import 'package:server/db/db.dart';

class AuthFetcher implements UserFetcher<ServerUser> {
  @override
  Future<ServerUser> byAuthenticationId(Context ctx, String authenticationId) async {
    final db = ctx.getVariable<Db>();
    final accessor = UserAccessor(db);
    ServerUser user = await accessor.getByEmail(authenticationId);
    if(user != null) {
      return user;
    }
    return accessor.getByName(authenticationId);
  }

  @override
  Future<ServerUser> byAuthorizationId(Context ctx, String authorizationId) {
    final db = ctx.getVariable<Db>();
    final accessor = UserAccessor(db);
    return accessor.get(authorizationId);
  }
}
