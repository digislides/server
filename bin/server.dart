import 'package:jaguar/jaguar.dart';
import 'package:jaguar_reflect/jaguar_reflect.dart';
import 'package:jaguar_dev_proxy/jaguar_dev_proxy.dart';

import 'package:server/api/program_editor.dart';

void main(List<String> args) async {
  final server = new Jaguar(port: 10000);
  server.log.onRecord.listen((rec) {
    print(rec);
  });
  server.addApi(reflect(new ProgramEditorRoutes()));
  server.addApi(new PrefixedProxyServer('', 'http://localhost:9000/'));
  await server.serve(logRequests: true);
}
