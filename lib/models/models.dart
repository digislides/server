import 'package:jaguar_common/jaguar_common.dart';
import 'package:common/models.dart';

import 'package:server/serializer/serializer.dart';

class ServerUser extends User implements AuthorizationUser, PasswordUser {
  String password;

  String get authorizationId => id;

  static final serializer = ServerUserSerializer();
}

class ProgramInfo extends HasAccess {
  String id;

  String name;

  String owner;

  Map<String, int> members;

  DateTime publishedAt;

  static final serializer = ProgramInfoSerializer();
}
