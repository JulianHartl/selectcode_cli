// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_url.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusUrl _$StatusUrlFromJson(Map<String, dynamic> json) => StatusUrl(
      name: json['name'] as String,
      key: json['key'] as String,
      url: json['url'] as String,
      project: json['project'] as String?,
    );

Map<String, dynamic> _$StatusUrlToJson(StatusUrl instance) => <String, dynamic>{
      'url': instance.url,
      'name': instance.name,
      'key': instance.key,
      'project': instance.project,
    };
