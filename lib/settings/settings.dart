import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:jaguar_settings/myconf.dart';

part 'settings.jser.dart';

class MyConfig {
  final int port;

  final String mongo;

  final String pwdSalt;

  MyConfig(
      {this.port: 10000,
      this.mongo: "mongodb://localhost:27018/echannel",
      this.pwdSalt: "sdfsd324324324egdsgsdfgdfty245345dsdgfr456456546"});

  static Future<MyConfig> load(List<String> args) async {
    return parseConfigArgs(args, serializer, defaultConf: MyConfig());
  }

  static final serializer = MyConfigSerializer();
}

@GenSerializer()
class MyConfigSerializer extends Serializer<MyConfig>
    with _$MyConfigSerializer {}
