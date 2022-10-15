import "dart:async";

import "package:mason/mason.dart";
import 'package:path/path.dart' as p;
import "package:selectcode/src/result_extension.dart";
import "package:universal_io/io.dart";

part 'git_cli.dart';
part "rebase_cli.dart";

abstract class _Cli {
  // static Future<ProcessResult> runInteractive() async {
  //   final progress = await Process.start(executable, arguments);
  //   return ProcessResult(
  //     pid,
  //     exitCode,
  //     stdout,
  //     stderr,
  //   );
  // }

  static Future<ProcessResult> run(
    String cmd,
    List<String> args, {
    String? workingDir,
    bool throwError = true,
    required Logger logger,
  }) async {
    const runProcess = Process.run;
    logger.info("Running: $cmd with $args");
    final result = await runProcess(
      cmd,
      args,
      runInShell: true,
      workingDirectory: workingDir,
    );

    logger
      ..info("stdout:\n${result.stdout}")
      ..info("stderr:\n${result.stderr}");
    if (!result.isSuccess || result.stderr.toString().isNotEmpty) {
      if (throwError) {
        throw ProcessException(
          cmd,
          args,
          result.stderr.toString(),
        );
      }
    }
    return result;
  }
}

Future<T> _runWithProgress<T>(
  FutureOr<T> Function(Progress progress) run, {
  required Logger logger,
  required String message,
}) async {
  final progress = logger.progress(message);
  try {
    final result = await run(progress);
    progress.complete();
    return result;
  } catch (_) {
    progress.fail();
    rethrow;
  }
}
