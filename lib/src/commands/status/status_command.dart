import "package:ansicolor/ansicolor.dart";
import "package:args/command_runner.dart";
import "package:mason/mason.dart";
import "package:selectcli/src/commands/status/status_service.dart";

class StatusCommand extends Command<int> {
  StatusCommand({
    required Logger logger,
  }) : _logger = logger;

  final Logger _logger;

  @override
  String get description =>
      "Checks the status of all services hosted by SelectCode";

  @override
  String get name => "status";

  @override
  Future<int> run() async {
    final pen = AnsiPen();
    final urls = await StatusService.getUrls();
    urls.sort(
      (a, b) => (a.project ?? a.name).compareTo(b.project ?? b.name),
    );
    for (final statusUrl in urls) {
      final url = statusUrl.url;
      final prefix =
          "${statusUrl.project != null ? "[${statusUrl.project}] " : ""}${statusUrl.name}";
      final progress = _logger.progress("Checking status of $url...");
      final success = await StatusService.check(url);
      if (success) {
        pen.green();
        progress.complete("$prefix ${pen("online")}");
      } else {
        pen.red();
        progress.fail("$prefix ${pen("not available")}");
      }
    }
    return ExitCode.success.code;
  }
}
