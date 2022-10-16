import "package:selectcli/src/commands/create/templates/flutter/flutter_template.dart";
import "package:selectcli/src/commands/create/templates/template.dart";

abstract class Application {
  const Application({
    required this.name,
    required this.template,
  });

  factory Application.flutter() => FlutterApp();

  final String name;
  final Template template;
// factory Application.react() => ReactApp();
}

class FlutterApp extends Application {
  FlutterApp() : super(name: "Flutter", template: FlutterTemplate());
}

// class ReactApp extends Application {
//   ReactApp() : super(name: "React");
// }
