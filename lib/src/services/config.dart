import "package:json_annotation/json_annotation.dart";
import "package:selectcli/src/services/command.dart";
import "package:selectcli/src/services/status_url.dart";
import "package:yaml/yaml.dart";

part "config.g.dart";

@JsonSerializable()
class Config {
  const Config({
    List<ConfigCommand>? commands,
    List<StatusUrl>? urls,
  })  : _commands = commands ?? const [],
        _urls = urls ?? const [];

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
        urls: (json["urls"] as List?)
            ?.cast<YamlMap>()
            .map((e) {
              final json = Map<String, dynamic>.from(e.value);
              return json;
            })
            .map<StatusUrl>(
              StatusUrl.fromJson,
            )
            .toList(),
      );

  factory Config.initial() => const Config(commands: []);

  final List<ConfigCommand> _commands;
  final List<StatusUrl> _urls;

  List<StatusUrl> get urls => _urls;

  List<ConfigCommand> get commands => _commands;

  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}
