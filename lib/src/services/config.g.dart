// GENERATED CODE - DO NOT MODIFY BY HAND

part of "config.dart";

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
      commands: (json["commands"] as List<dynamic>?)
          ?.map((e) => ConfigCommand.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      "commands": instance.commands,
    };
