import 'dart:html';

import 'package:mason/mason.dart';
import 'package:universal_io/io.dart';
part 'rebase_cli.dart';
abstract class _Cli {
  static Future<ProcessResult> run(
    String cmd,
    List<String> args, {
    String? workingDir,
    required Logger logger,
  }) async {
    const runProcess = Process.run;
    logger.detail('Running: $cmd with $args');
    final result = await runProcess(
      cmd,
      args,
      runInShell: true,
      workingDirectory: workingDir,
    );
    if (result.exitCode != 0) {
      throw ProcessException(cmd, args);
    }
    return result;
  }
}
