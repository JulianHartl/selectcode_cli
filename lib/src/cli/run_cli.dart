part of "cli.dart";

abstract class RunCli {
  static Future<ProcessResult> run(
    String command, {
    required Logger logger,
  }) async {
    final args = command.split(" ");
    return _Cli.runStream(
      args[0],
      args..removeRange(0, 1),
      logger: logger,
      onSysOut: (content) {
        logger.info(content);
      },
      onErr: (error) => logger.err(error),
    );
  }
}
