import "package:args/command_runner.dart";
import "package:mason/mason.dart";
import "package:selectcode/src/commands/create/application.dart";
import "package:universal_io/io.dart";

class CreateCommand extends Command<int> {
  CreateCommand({required Logger logger}) : _logger = logger;

  @override
  String get description =>
      "Create a new flutter application in selectcode style.";

  @override
  String get name => "create";

  final Logger _logger;

  @override
  Future<int> run() async {
    final application = _logger.chooseOne<Application>(
      "What type of application would you like to create?",
      choices: [
        FlutterApp(),
      ],
      display: (choice) => choice.name,
    );
    final name = _logger.prompt("What's the name of the project?");
    final generator =
        await MasonGenerator.fromBundle(application.template.bundle);
    final outputDir = Directory(".");
    await generator.generate(DirectoryGeneratorTarget(outputDir),
        vars: {
          "project_name": name,
        },
        logger: _logger,);
    await Process.run(
      "flutter",
      ["pub", "get"],
      workingDirectory: outputDir.absolute.path,
      runInShell: true,
    );
    return ExitCode.success.code;
  }
}
