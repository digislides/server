import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:jaguar_settings/myconf.dart';

part 'settings.jser.dart';

class MyConfig {
  final int port;

  final String mongo;

  final String pwdSalt;

  final String mediaDir;

  MyConfig(
      {this.port: 10000,
      this.mongo: "mongodb://localhost:27017/echannel",
      this.pwdSalt: "sdfsd324324324egdsgsdfgdfty245345dsdgfr456456546",
      this.mediaDir: "../media/"});

  static Future<MyConfig> load(List<String> args) async {
    return parseConfigArgs(args, serializer, defaultConf: MyConfig());
  }

  String toString() => toJson().toString();

  Map toJson() => serializer.toMap(this);

  static final serializer = MyConfigSerializer();
}

@GenSerializer()
class MyConfigSerializer extends Serializer<MyConfig>
    with _$MyConfigSerializer {}
