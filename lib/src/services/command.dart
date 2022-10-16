import "package:json_annotation/json_annotation.dart";

part "command.g.dart";

@JsonSerializable()
class ConfigCommand {
  const ConfigCommand({
    required this.name,
    required this.cmd,
    required this.description,
  });

  factory ConfigCommand.fromJson(Map<String, dynamic> json) =>
      _$ConfigCommandFromJson(json);

  final String name, cmd, description;

  Map<String, dynamic> toJson() => _$ConfigCommandToJson(this);
}
