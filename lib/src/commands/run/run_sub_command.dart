import "package:args/command_runner.dart";
import "package:mason/mason.dart";
import "package:selectcli/src/cli/cli.dart";
import "package:selectcli/src/services/command.dart";

class RunSubCommand extends Command<int> {
  RunSubCommand(
    this.configCommand, {
    required Logger logger,
  }) : _logger = logger {
    _addOptions();
  }

  void _addOptions() {
    final regex = RegExp("{(.[^}])+}");
    final matches = regex.allMatches(configCommand.cmd);
    for (final match in matches) {
      argParser.addOption(
        configCommand.cmd.substring(match.start + 1, match.end - 1),
        mandatory: true,
      );
    }
  }

  final ConfigCommand configCommand;
  final Logger _logger;

  @override
  String get description => configCommand.description;

  @override
  String get name => configCommand.name;

  @override
  Future<int> run() async {
    var argIndex = 0;
    await RunCli.run(
      configCommand.cmd.replaceAllMapped(RegExp("{(.[^}])*}"), (match) {
        final pattern = match.input.substring(match.start, match.end);
        try {
          final name = pattern == "{}"
              ? null
              : pattern.substring(
                  1,
                  pattern.length - 1,
                );
          final isPositionalArg = name == null;
          final replaceWith = isPositionalArg
              ? argResults!.arguments[argIndex]
              : argResults![name].toString();
          if (replaceWith.startsWith("-")) {
            throw Exception();
          }
          if (isPositionalArg) argIndex++;
          return replaceWith;
        } catch (_) {
          throw Exception("Missing one or more named parameters");
        }
      }),
      logger: _logger,
    );
    return ExitCode.success.code;
  }
}
