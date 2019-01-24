import 'package:jaguar/jaguar.dart';
import 'package:jaguar_reflect/jaguar_reflect.dart';
import 'package:jaguar_dev_proxy/jaguar_dev_proxy.dart';

import 'package:server/api/api.dart';

void main(List<String> args) async {
  final server = Jaguar(port: 10000);
  server.log.onRecord.listen(print);

  server.add(reflect(AuthApi()));
  server.add(reflect(UserApi()));

  // server.addRoute(getOnlyProxy('', 'http://localhost:9000/'));

  await server.serve(logRequests: true);
}
