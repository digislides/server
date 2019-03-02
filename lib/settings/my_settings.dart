import 'settings.dart';
import 'package:jaguar_mongo/jaguar_mongo.dart';
import 'package:jaguar_auth/jaguar_auth.dart';

MyConfig _config;

MyConfig get config => _config;

Sha256Hasher _pwdHasher;

Sha256Hasher get pwdHasher => _pwdHasher;

MongoPool _mgoPool;

MongoPool get mgoPool => _mgoPool;

Future<void> init(List<String> args) async {
  _config = await MyConfig.load(args);

  _mgoPool = MongoPool(_config.mongo);
  _pwdHasher = Sha256Hasher(_config.pwdSalt);
}
