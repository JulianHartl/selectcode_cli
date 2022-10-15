part of "cli.dart";

class CommitChangesException implements GitException {
  const CommitChangesException(this.files);

  final List<String> files;

  @override
  String get message =>
      "You need to commit changes in the following files:\n${files.join("\n")}";
}

class CurrentBranchEqualToBaseException implements GitException {
  @override
  String get message => "Current branch is equal to the base branch.";
}

class BranchAlreadyRebasedException implements GitException {
  @override
  String get message => "Current branch is already rebased.";
}

class NoUniqueCommitsException implements GitException {
  @override
  String get message =>
      "Current branch has no any unique commits. You can do fast-forward merge.";
}

abstract class RebaseCli {
  static const _rebaseScriptName = "git-rebase-via-merge.sh";

  // Run `curl -L https://git.io/rebase-via-merge -o ./git-rebase-via-merge.sh`.
  static Future<void> _fetchRebaseScript({required Logger logger}) async {
    await _runWithProgress(
      (progress) => _Cli.run(
        "curl",
        ["-L", "https://git.io/rebase-via-merge", "-o", "./$_rebaseScriptName"],
        logger: logger,
      ),
      logger: logger,
      message: "Fetching rebase script",
    );
  }

  static Future<void> _deleteRebaseScript({required Logger logger}) async {
    await _runWithProgress(
      (progress) => _Cli.run(
        "rm",
        [
          "./$_rebaseScriptName",
        ],
        logger: logger,
      ),
      logger: logger,
      message: "Removing rebase script",
    );
  }

  static Future<void> _executeRebaseScript({
    required Logger logger,
    required String branch,
  }) async {
    await _runWithProgress(
      (progress) => _Cli.run(
        "/bin/bash",
        ["./$_rebaseScriptName", branch],
        logger: logger,
      ),
      logger: logger,
      message: "Rebasing",
    );
  }

  static Future<void> runRebaseScript({
    required String baseBranch,
    required Logger logger,
  }) async {
    logger.info("This script will perform rebase via merge.");
    String? currentBranch;
    bool needsAbort = false;
    try {
      currentBranch = await GitCli.getCurrentBranch(logger: logger);
      final baseBranchHash = await GitCli.getHash(baseBranch, logger: logger);
      final currentBranchHash = await GitCli.getHash(
        currentBranch,
        logger: logger,
      );
      final changedFiles = await GitCli.getChangedFiles(logger: logger);
      if (changedFiles.isNotEmpty) {
        throw CommitChangesException(changedFiles);
      }
      if (baseBranchHash == currentBranchHash) {
        throw CurrentBranchEqualToBaseException();
      }
      final notReachableCommits = await GitCli.getNotReachableCommits(
        baseBranch: baseBranch,
        branch: currentBranch,
        logger: logger,
      );
      if (notReachableCommits.isEmpty) {
        throw BranchAlreadyRebasedException();
      }
      final uniqueCommits = await GitCli.getNotReachableCommits(
        baseBranch: currentBranch,
        branch: baseBranch,
        logger: logger,
      );
      if (uniqueCommits.isEmpty) {
        throw NoUniqueCommitsException();
      }
      await GitCli.checkout(
        branch: currentBranchHash,
        logger: logger,
        quiet: true,
      );
      needsAbort = true;
      await GitCli.merge(
        branch: baseBranch,
        message: "Hidden orphaned commit to save merge result.",
        logger: logger,
      );
      if (await GitCli.hasMergeConflicts(logger: logger)) {
        final success = await _resolveConflicts(
          logger: logger,
          name: "merge",
          currentBranch: currentBranch,
          abort: () async {
            await GitCli.abortMerge(logger: logger);
          },
          onContinue: () async {
            await GitCli.commit(
              message: "Hidden orphaned commit to save merge result.",
              logger: logger,
            );
          },
        );
        if (!success) {
          logger.info("Exited rebase via merge");
          return;
        }
      }

      final hiddenResultHash = await GitCli.getHash("HEAD", logger: logger);
      logger.info("Merge succeeded at hidden commit: $hiddenResultHash");
      await GitCli.checkout(
        branch: currentBranch,
        logger: logger,
        quiet: true,
      );
      await GitCli.rebase(
        branch: baseBranch,
        logger: logger,
      );
      if (await GitCli.areRebaseConflictsPresent(logger: logger)) {
        final success = await _resolveConflicts(
          logger: logger,
          name: "rebase",
          abort: () async {
            await GitCli.abortRebase(logger: logger);
          },
          onContinue: () => GitCli.continueRebase(
            logger: logger,
          ),
          currentBranch: currentBranch,
        );
        if (!success) {
          logger.info("Exited rebase via merge");
          return;
        }
      }
      final currentTree = await GitCli.getTree(parent: "HEAD", logger: logger);
      final resultTree =
          await GitCli.getTree(parent: hiddenResultHash, logger: logger);
      if (currentTree != resultTree) {
        logger.info(
          "Restoring project state from the hidden merge with single additional commit.",
        );
        final additionalCommitMessage =
            "Rebase via merge. '$currentBranch' rebased on '$baseBranch'.";
        final additionalCommitHash = await GitCli.getCommitTree(
          branch: hiddenResultHash,
          logger: logger,
          parent: "HEAD",
          message: additionalCommitMessage,
        );
        await GitCli.merge(
          branch: additionalCommitHash,
          fastForward: true,
          logger: logger,
        );
      } else {
        logger.info(
          "You don't need an additional commit. Project state is correct.",
        );
      }
      logger.success("Finished rebase.");
      const doItAutomatically = "Do it automatically";
      const doItManually = "I'll do it manually";

      final choice = logger.chooseOne(
        "The rebase changed the historical start point of the current branch. To prevent errors you should do a git push --force.",
        choices: [
          doItAutomatically,
          doItManually,
        ],
        defaultValue: doItAutomatically,
      );
      if (choice == doItAutomatically) {
        await GitCli.push(force: true, logger: logger);
        logger.success("Updated origin/$currentBranch");
      }
    } catch (e) {
      if (currentBranch != null && needsAbort) {
        try {
          await GitCli.abortMerge(logger: logger);
        } finally {
          await GitCli.checkout(
            branch: currentBranch,
            logger: logger,
          );
        }
      }
      if (e is GitException) {
        logger.info("Can't rebase. ${e.message}");
      } else {
        rethrow;
      }
    }

    // try {
    //   await _fetchRebaseScript(logger: logger);
    //   await _executeRebaseScript(
    //     logger: logger,
    //     branch: branch,
    //   );
    // } finally {
    //   await _deleteRebaseScript(logger: logger);
    // }
  }

  static Future<bool> _resolveConflicts({
    required Logger logger,
    required String name,
    required Future<void> Function() onContinue,
    required Future<void> Function() abort,
    required String currentBranch,
  }) async {
    var unstagedFiles = await GitCli.getUnstagedFiles(
      logger: logger,
    );
    final filesWithConflictMarkers =
        await GitCli.getFilesWithConflictMarkers(logger: logger);
    logger
      ..info("You have at least one $name conflict.")
      ..info(
        "Fix all conflicts in the following files and stage the changes.",
      )
      ..info(unstagedFiles.join("\n"))
      ..info("List of conflict markers:")
      ..info(
        filesWithConflictMarkers.join("\n"),
      );
    while (unstagedFiles.isNotEmpty) {
      const wantToContinue = "Continue";
      const abortChoice = "Abort";

      final choice = logger.chooseOne(
        "Do you want to continue or abort?",
        choices: [
          wantToContinue,
          abortChoice,
        ],
        defaultValue: wantToContinue,
      );
      if (choice == wantToContinue) {
        unstagedFiles = await GitCli.getUnstagedFiles(logger: logger);
        if (unstagedFiles.isNotEmpty) {
          logger.info(
              "There are still unstaged files:\n${unstagedFiles.join("\n")}");
        } else {
          await onContinue();
        }
      } else {
        await abort();
        await GitCli.checkout(branch: currentBranch, logger: logger);
        return false;
      }
    }
    return true;
  }
}
