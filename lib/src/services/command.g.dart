// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigCommand _$ConfigCommandFromJson(Map<String, dynamic> json) =>
    ConfigCommand(
      name: json['name'] as String,
      cmd: json['cmd'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$ConfigCommandToJson(ConfigCommand instance) =>
    <String, dynamic>{
      'name': instance.name,
      'cmd': instance.cmd,
      'description': instance.description,
    };
