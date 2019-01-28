import 'package:jaguar/jaguar.dart';
import 'package:jaguar_reflect/jaguar_reflect.dart';
import 'package:jaguar_dev_proxy/jaguar_dev_proxy.dart';

import 'package:common/serializer/serializer.dart';

import 'package:server/api/api.dart';
import 'package:server/api/auth.dart';
import 'package:server/models/models.dart' show ServerUser;

void main(List<String> args) async {
  final server = Jaguar(port: 10000);
  server.serializers[MimeTypes.json] = repo;
  server.userFetchers[ServerUser] = AuthFetcher();
  server.log.onRecord.listen(print);

  server.add(reflect(AuthApi()));
  server.add(reflect(UserApi()));
  server.add(reflect(ProgramRoutes()));
  server.add(reflect(ChannelRoutes()));

  // server.addRoute(getOnlyProxy('', 'http://localhost:9000/'));

  await server.serve(logRequests: true);
}
