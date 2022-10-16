import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:selectcli/src/commands/run/run_sub_command.dart';
import 'package:selectcli/src/services/storage_service.dart';

class UnknownCommandException implements Exception {
  UnknownCommandException(this.command);

  final String command;

  String get message =>
      "$command is not registered inside ${StorageService.configFileName}";
}

class RunCommand extends Command<int> {
  RunCommand({required Logger logger}) : _logger = logger;

  Future<void> init() async {
    final config = await StorageService.readConfig();
    for (final configCommand in config.commands) {
      addSubcommand(
        RunSubCommand(
          configCommand,
          logger: _logger,
        ),
      );
    }
  }

  @override
  String get description => "Runs a command specified in the config.yaml file.";

  @override
  String get name => "run";

  final Logger _logger;

  @override
  FutureOr<int> run() {
    if (argResults!.arguments.isEmpty) {
      usageException("Missing command");
    }

    usageException(
        "${argResults!.arguments[0]} is not registered in ${StorageService.configFileName}.");
  }
}
