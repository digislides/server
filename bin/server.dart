import 'package:jaguar/jaguar.dart';
import 'package:jaguar_reflect/jaguar_reflect.dart';
import 'package:jaguar_dev_proxy/jaguar_dev_proxy.dart';

import 'package:common/serializer/serializer.dart';

import 'package:server/api/api.dart';
import 'package:server/api/auth.dart';
import 'package:server/models/models.dart' show ServerUser;

void logError(Context ctx, Object e, StackTrace t) {
  final sb = StringBuffer();
  sb.writeln();
  sb.writeln("---------------Exception in Route---------------------");
  sb.writeln("Method: ${ctx.method} Path: ${ctx.path}");
  sb.writeln(e);
  sb.writeln(t);
  sb.writeln("******************************************************");
  ctx.log.warning(sb.toString());
}

void main(List<String> args) async {
  final server = Jaguar(port: 10000);
  server.serializers[MimeTypes.json] = repo;
  server.userFetchers[ServerUser] = AuthFetcher();
  server.onException.add(logError);
  // server.log.onRecord.listen(print);

  server.add(reflect(AuthApi()));
  server.add(reflect(UserApi()));
  server.add(reflect(ProgramRoutes()));
  server.add(reflect(ChannelRoutes()));

  // server.addRoute(getOnlyProxy('/player/*', 'http://localhost:9005/'));
  server.addRoute(getOnlyProxy('/*', 'http://localhost:9000/'));

  await server.serve(logRequests: true);
}
