import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar/bind.dart';
import 'package:jaguar_mongo/jaguar_mongo.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:jaguar_auth/jaguar_auth.dart';

import 'package:common/common.dart';
import 'package:common/error_codes.dart';
import 'package:common/serializer/serializer.dart';
import 'package:server/models/models.dart';

import 'package:server/db/db.dart';

part 'channel_api.dart';
part 'program_api.dart';
part 'user_api.dart';

final pwdHasher =
    Sha256Hasher("sdfsd324324324egdsgsdfgdfty245345dsdgfr456456546");

final mgoPool = MongoPool("mongodb://localhost:27018/echannel");

doNotHaveReadAccess(String id) => Exception();

doNotHaveWriteAccess(String id) => Exception();
