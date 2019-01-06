import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_mongo/jaguar_mongo.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:common/common.dart';
import 'package:server/models/models.dart';

part 'player.dart';
part 'program_editor.dart';

final pool = MongoPool('mongodb://localhost:27017/digislides');

programByIdNotFound(String id) => new Exception();

doNotHaveReadAccess(String id) => new Exception();

doNotHaveWriteAccess(String id) => new Exception();

String getUserId(Context ctx) => '1' * 24;
