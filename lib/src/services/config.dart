import "package:json_annotation/json_annotation.dart";
import "package:selectcli/src/services/command.dart";
import "package:yaml/yaml.dart";

part "config.g.dart";

@JsonSerializable()
class Config {
  const Config({
    List<ConfigCommand>? commands,
  }) : _commands = commands ?? const [];

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        commands: (json["commands"] as List?)
            ?.cast<YamlMap>()
            .map((e) {
              final json = Map<String, dynamic>.from(e.value);
              return json;
            })
            .map<ConfigCommand>(
              ConfigCommand.fromJson,
            )
            .toList(),
      );

  factory Config.initial() => const Config(commands: []);

  final List<ConfigCommand> _commands;

  List<ConfigCommand> get commands => _commands;

  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}
