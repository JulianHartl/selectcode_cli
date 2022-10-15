part of 'cli.dart';

abstract class RebaseCli {
  static const _rebaseScriptName = "git-rebase-via-merge.sh";

  // Run `curl -L https://git.io/rebase-via-merge -o ./git-rebase-via-merge.sh`.
  static Future<void> _fetchRebaseScript({required Logger logger}) async {
    await _Cli.run(
      "curl",
      ["-L", "https://git.io/rebase-via-merge", "-o", "./$_rebaseScriptName"],
      logger: logger,
    );
  }

  static Future<void> _deleteRebaseScript({required Logger logger}) async {
    await _Cli.run(
      "rm",
      [
        "./$_rebaseScriptName",
        "||",
        "true",
      ],
      logger: logger,
    );
  }

  static Future<void> runRebaseScript({
    required String branch,
    required Logger logger,
  }) async {
    try {
      await _fetchRebaseScript(logger: logger);
      final result = await _Cli.run(
        "/bin/bash",
        ["./$_rebaseScriptName", branch],
        logger: logger,
      );
    } finally {
      await _deleteRebaseScript(logger: logger);
    }
  }
}
