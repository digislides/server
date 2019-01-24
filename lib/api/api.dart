import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_mongo/jaguar_mongo.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:jaguar_auth/jaguar_auth.dart';

import 'package:common/common.dart';
import 'package:common/serializer/serializer.dart';
import 'package:server/models/models.dart';

import 'package:server/db/db.dart';

part 'player_api.dart';
part 'program_api.dart';
part 'user_api.dart';

final pool = MongoPool('mongodb://localhost:27017/digislides');

final pwdHasher =
    Sha256Hasher("sdfsd324324324egdsgsdfgdfty245345dsdgfr456456546");

final mgoPool = MongoPool("mongodb://localhost:27018/echannel");

programByIdNotFound(String id) => Exception();

doNotHaveReadAccess(String id) => Exception();

doNotHaveWriteAccess(String id) => Exception();
