import "dart:async";
import 'dart:convert' show utf8;
import 'dart:math';

import 'package:args/args.dart';
import "package:mason/mason.dart";
import 'package:path/path.dart' as p;
import "package:selectcli/src/result_extension.dart";
import "package:universal_io/io.dart";

part 'git_cli.dart';

part "rebase_cli.dart";

part 'run_cli.dart';

abstract class _Cli {
  static Future<ProcessResult> runStream(
    String cmd,
    List<String> args, {
    required Logger logger,
    required void Function(String error) onErr,
    required void Function(String content) onSysOut,
  }) async {
    final progress = await Process.start(
      cmd,
      args,
      runInShell: true,
    );

    progress.stderr.transform(utf8.decoder).listen((event) {
      onErr(event);
    });

    progress.stdout.transform(utf8.decoder).listen((event) {
      onSysOut(event);
    });

    final exitCode = await progress.exitCode;

    return ProcessResult(
      pid,
      exitCode,
      stdout,
      stderr,
    );
  }

  static Future<ProcessResult> run(
    String cmd,
    List<String> args, {
    String? workingDir,
    bool throwError = true,
    required Logger logger,
  }) async {
    const runProcess = Process.run;
    logger.detail("Running: $cmd with $args");
    final result = await runProcess(
      cmd,
      args,
      runInShell: true,
      workingDirectory: workingDir,
    );

    logger
      ..detail("stdout:\n${result.stdout}")
      ..info("stderr:\n${result.stderr}");
    if (!result.isSuccess) {
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
