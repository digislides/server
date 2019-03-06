import 'package:jaguar_serializer/jaguar_serializer.dart';

import 'package:server/models/models.dart';

import 'package:common/serializer/serializer.dart';

part 'serializer.jser.dart';

@GenSerializer()
class ServerUserSerializer extends Serializer<ServerUser>
    with _$ServerUserSerializer {}

@GenSerializer(
  fields: {'publishedAt': Field(processor: Seconds2019Processor())},
)
class ProgramInfoSerializer extends Serializer<ProgramInfo>
    with _$ProgramInfoSerializer {}
