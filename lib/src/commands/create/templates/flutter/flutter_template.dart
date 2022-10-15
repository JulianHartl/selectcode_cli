import 'dart:io';

import 'package:mason/mason.dart';
import 'package:selectcode/src/commands/create/templates/flutter/flutter_brick_bundle.dart';

import '../template.dart';
class FlutterTemplate extends Template {
  FlutterTemplate(): super(
    name: "Flutter",
    bundle: flutterBrickBundle,
  );

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async{

  }

}