import 'package:mongo_dart/mongo_dart.dart';
import 'package:jaguar/jaguar.dart';

import 'package:server/models/models.dart';
import 'package:server/db/db.dart';

class AuthFetcher implements UserFetcher<ServerUser> {
  @override
  Future<ServerUser> byAuthenticationId(Context ctx, String authenticationId) {
    final db = ctx.getVariable<Db>();
    final accessor = UserAccessor(db);
    return accessor.getByEmail(authenticationId);
  }

  @override
  Future<ServerUser> byAuthorizationId(Context ctx, String authorizationId) {
    final db = ctx.getVariable<Db>();
    final accessor = UserAccessor(db);
    return accessor.get(authorizationId);
  }
}
