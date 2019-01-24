import 'package:jaguar_serializer/jaguar_serializer.dart';

import 'package:server/models/models.dart';

part 'serializer.jser.dart';

@GenSerializer()
class ServerUserSerializer extends Serializer<ServerUser>
    with _$ServerUserSerializer {}
