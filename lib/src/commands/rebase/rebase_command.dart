import "package:args/command_runner.dart";
import "package:mason/mason.dart";
import "package:selectcli/src/cli/cli.dart";

class RebaseCommand extends Command<int> {
  RebaseCommand({required Logger logger}) : _logger = logger {
    argParser.addCommand("branch");
  }

  final Logger _logger;

  @override
  String get description =>
      "Automatically rebases your current working branch on the specified branch.";

  @override
  String get name => "rebase";

  @override
  Future<int> run() async {
    String? branch;
    try {
      branch = argResults!.arguments[0];
    } catch (e) {
      usageException("Missing branch.");
    }
    await RebaseCli.runRebaseScript(
      baseBranch: branch,
      logger: _logger,
    );
    return ExitCode.success.code;
  }
}
