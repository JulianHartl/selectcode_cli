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