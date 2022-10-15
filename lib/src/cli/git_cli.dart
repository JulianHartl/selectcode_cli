part of "cli.dart";

abstract class GitException implements Exception {
  String get message;
}

class NoCurrentBranchException implements GitException {
  @override
  String get message => "There is no current branch: you are in detached head.";
}

class CouldNotGetFilesWithConflictMarkers implements GitException {
  const CouldNotGetFilesWithConflictMarkers();

  @override
  String get message => "Could not get files with conflict markers.";
}

class CouldNotGetHashException implements GitException {
  const CouldNotGetHashException(this.branch);

  final String branch;

  @override
  String get message => "Could not get hash for branch $branch";
}

class CouldNotGetChangedFilesException implements GitException {
  const CouldNotGetChangedFilesException();

  @override
  String get message => "Could not get changed files.";
}

class CouldNotGetTreeException implements GitException {
  const CouldNotGetTreeException(this.parent);

  final String parent;

  @override
  String get message => "Could not get tree for parent $parent";
}

class CouldNotGetCommitTreeException implements GitException {
  const CouldNotGetCommitTreeException(this.branch, this.parent);

  final String parent;
  final String branch;

  @override
  String get message =>
      "Could not get commit tree for branch $branch with parent $parent";
}

class CouldNotGetUnstagedFilesException implements GitException {
  const CouldNotGetUnstagedFilesException();

  @override
  String get message => "Could not get unstaged files.";
}

abstract class GitCli {
  static Future<ProcessResult> _runCommand(
    List<String> args, {
    required Logger logger,
    bool throwOnError = true,
  }) async {
    final result = await _Cli.run(
      "git",
      args,
      workingDir: Directory.current.path,
      logger: logger,
      throwError: throwOnError,
    );
    return result;
  }

  static Future<String> getWorkingDirectory({
    required Logger logger,
  }) async {
    final result = await _runCommand(
      ["rev-parse", "--show-toplevel"],
      logger: logger,
    );
    return result.stdout.toString().trim();
  }

  static Future<void> checkout({
    required String branch,
    required Logger logger,
    bool quiet = false,
  }) async {
    return _runWithProgress(
      (progress) async {
        await _runCommand(
          [
            "checkout",
            if (quiet) "--quiet",
            branch,
          ],
          logger: logger,
          throwOnError: false,
        );
      },
      logger: logger,
      message: "Getting current branch",
    );
  }

  static Future<void> push({
    required Logger logger,
    bool force = false,
  }) async {
    return _runWithProgress(
      (progress) async {
        await _runCommand(
          [
            "push",
            if (force) "--force",
          ],
          logger: logger,
          throwOnError: false,
        );
      },
      logger: logger,
      message: "Pushing changes",
    );
  }

  static Future<void> continueRebase({
    required Logger logger,
  }) async {
    return _runWithProgress(
      (progress) async {
        await _runCommand(
          [
            "rebase",
            "--continue",
          ],
          logger: logger,
        );
      },
      logger: logger,
      message: "Continuing rebase",
    );
  }

  static Future<void> abortRebase({
    required Logger logger,
  }) async {
    return _runWithProgress(
      (progress) async {
        await _runCommand(
          [
            "rebase",
            "--abort",
          ],
          logger: logger,
        );
        progress.complete("Aborted.");
      },
      logger: logger,
      message: "Aborting rebase",
    );
  }

  static Future<bool> areRebaseConflictsPresent({
    required Logger logger,
  }) async {
    return _runWithProgress(
      (progress) async {
        final result = await _runCommand(
          [
            "diff",
            "--name-only",
            "--diff-filter=U",
            "--relative",
          ],
          logger: logger,
        );
        final out = result.stdout?.toString();
        return out != null && out.isNotEmpty;
      },
      logger: logger,
      message: "Checking for rebase conflicts",
    );
  }

  static Future<void> commit({
    required Logger logger,
    required String message,
  }) async {
    return _runWithProgress(
      (progress) async {
        await _runCommand(
          [
            "commit",
            "-m",
            message,
          ],
          logger: logger,
        );
      },
      logger: logger,
      message: "Committing changes ($message).",
    );
  }

  static Future<void> rebase({
    required String branch,
    required Logger logger,
  }) async {
    return _runWithProgress(
      (progress) async {
        try {
          await _runCommand(
            [
              "rebase",
              branch,
              "-X",
              "theirs",
            ],
            logger: logger,
          );
        } on ProcessException catch (e) {
          if (!e.message.toLowerCase().contains("success")) {
            rethrow;
          }
        }
      },
      logger: logger,
      message: "Rebasing any conflicts automatically.",
    );
  }

  static Future<bool> hasMergeConflicts({
    required Logger logger,
  }) async {
    return _runWithProgress(
      (progress) async {
        final wdPath = await getWorkingDirectory(logger: logger);
        final mergeHeadPath = "$wdPath/.git/MERGE_HEAD";
        final mergeHead = File.fromUri(Uri.parse(mergeHeadPath));
        final exists = await mergeHead.exists();
        progress.update(
            "Checking for merge conflicts (${exists ? "At least one" : "None found"})");

        return exists;
      },
      logger: logger,
      message: "Checking for merge conflicts",
    );
  }

  static Future<void> merge({
    required String branch,
    String? message,
    bool fastForward = false,
    required Logger logger,
  }) async {
    return _runWithProgress(
      (progress) => _runCommand(
        [
          "merge",
          branch,
          if (fastForward) "--ff",
          if (message != null) ...[
            "-m",
            message,
          ],
        ],
        throwOnError: false,
        logger: logger,
      ),
      logger: logger,
      message: "Merging $branch",
    );
  }

  static Future<String> getCurrentBranch({required Logger logger}) async {
    return _runWithProgress(
      (progress) async {
        final result = await _runCommand(
          ["symbolic-ref", "--short", "HEAD"],
          logger: logger,
        );
        final currentBranch = result.stdout?.toString();
        if (currentBranch == null || currentBranch.isEmpty) {
          throw NoCurrentBranchException();
        }
        return currentBranch.trim();
      },
      logger: logger,
      message: "Getting current branch",
    );
  }

  static Future<String> getTree({
    required Logger logger,
    required String parent,
  }) async {
    return _runWithProgress(
      (progress) async {
        final result = await _runCommand(
          [
            "cat-file",
            "-p",
            parent,
          ],
          logger: logger,
        );
        final tree = result.stdout?.toString().split("\n").firstWhere(
              (element) => element.contains("tree"),
              orElse: () => "",
            );
        if (tree == null || tree.isEmpty) {
          throw CouldNotGetTreeException(parent);
        }
        return tree.trim();
      },
      logger: logger,
      message: "Getting tree for parent $parent",
    );
  }

  static Future<String> getCommitTree({
    required Logger logger,
    required String parent,
    required String message,
    required String branch,
  }) async {
    return _runWithProgress(
      (progress) async {
        final result = await _runCommand(
          [
            "commit-tree",
            "$branch^{tree}",
            "-p",
            parent,
            "-m",
            message,
          ],
          logger: logger,
        );
        final tree = result.stdout?.toString();
        if (tree == null || tree.isEmpty) {
          throw CouldNotGetCommitTreeException(branch, parent);
        }
        return tree;
      },
      logger: logger,
      message: "Getting tree for parent $parent",
    );
  }

  static Future<void> printCommits({
    required String hash,
    required String branch,
    required Logger logger,
  }) async {
    return _runWithProgress(
      (progress) async {
        final result = await _runCommand(
          [
            "log",
            "-n",
            "1",
            '--pretty=format:"%<(20)%an | %<(14)%ar | %s"',
            hash,
          ],
          logger: logger,
        );
        progress.complete();
        logger.info(result.stdout?.toString());
      },
      logger: logger,
      message: "Getting commits for $branch",
    );
  }

  static Future<List<String>> getNotReachableCommits({
    required String baseBranch,
    required String branch,
    required Logger logger,
  }) async {
    return _runWithProgress(
      (progress) async {
        final result = await _runCommand(
          [
            "rev-list",
            baseBranch,
            "^$branch",
          ],
          logger: logger,
        );
        final out = result.stdout?.toString();
        if (out == null || out.isEmpty) {
          return [];
        }
        return out.split("\n");
      },
      logger: logger,
      message: "Getting not reachable commits",
    );
  }

  static Future<List<String>> getUnstagedFiles({
    required Logger logger,
  }) async {
    return _runWithProgress(
      (progress) async {
        final result = await _runCommand(
          [
            "status",
            "--porcelain",
            "--ignore-submodules=dirty",
          ],
          logger: logger,
        );
        final out = result.stdout?.toString();
        if (out == null) {
          throw const CouldNotGetUnstagedFilesException();
        }
        if (out.isEmpty) return [];
        return out
            .split("\n")
            .where((element) => element.isNotEmpty)
            .where((element) => element[1] != " ")
            .map((e) => e.split(" ").last)
            .toList();
      },
      logger: logger,
      message: "Getting unstaged files",
    );
  }

  static Future<List<String>> getFilesWithConflictMarkers({
    required Logger logger,
  }) async {
    return _runWithProgress(
      (progress) async {
        final result = await _runCommand(
          ["diff", "--check"],
          logger: logger,
        );
        final out = result.stdout?.toString();
        if (out == null) {
          throw const CouldNotGetFilesWithConflictMarkers();
        }
        if (out.isEmpty) {
          return [];
        }
        return out.split("\n");
      },
      logger: logger,
      message: "Getting files with conflict markers",
    );
  }

  static Future<List<String>> getChangedFiles({required Logger logger}) async {
    return _runWithProgress(
      (progress) async {
        final result = await _runCommand(
          [
            "status",
            "--porcelain",
            "--ignore-submodules=dirty",
          ],
          logger: logger,
        );
        final out = result.stdout?.toString();
        if (out == null) {
          throw const CouldNotGetChangedFilesException();
        }
        if (out.isEmpty) return [];

        return out.split("\n").map((e) => e.split(" ").last).toList();
      },
      logger: logger,
      message: "Getting changed files",
    );
  }

  static Future<void> abortMerge({required Logger logger}) async {
    return _runWithProgress(
      (progress) async {
        await _runCommand(
          [
            "merge",
            "--abort",
          ],
          logger: logger,
          throwOnError: false,
        );
        progress.complete("Aborted.");
      },
      logger: logger,
      message: "Aborting merge",
    );
  }

  static Future<String> getHash(String branch, {required Logger logger}) async {
    return _runWithProgress(
      (progress) async {
        final result = await _runCommand(
          ["rev-parse", "--short", branch],
          logger: logger,
        );
        final hash = result.stdout?.toString();
        if (hash == null || hash.isEmpty) {
          throw CouldNotGetHashException(branch);
        }
        return hash.trim();
      },
      logger: logger,
      message: "Getting hash for $branch",
    );
  }
}
