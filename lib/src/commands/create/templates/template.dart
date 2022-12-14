import "package:mason/mason.dart";
import "package:universal_io/io.dart";

/// {@template template}
/// Dart class that represents a VeryGoodCLI supported template.
/// Each template consists of a [MasonBundle], name,
/// and help text describing the template.
/// {@endtemplate}
abstract class Template {
  /// {@macro template}
  const Template({
    required this.name,
    required this.bundle,
  });

  /// The name associated with this template.
  final String name;

  /// The [MasonBundle] used to generate this template.
  final MasonBundle bundle;

  /// Callback invoked after template generation has completed.
  Future<void> onGenerateComplete(Logger logger, Directory outputDir);
}
