import "package:json_annotation/json_annotation.dart";

part "status_url.g.dart";

@JsonSerializable()
class StatusUrl {
  const StatusUrl({
    required this.name,
    required this.key,
    required this.url,
    this.project,
  });

  factory StatusUrl.fromJson(Map<String, dynamic> json) =>
      _$StatusUrlFromJson(json);

  final String url, name, key;
  final String? project;

  Map<String, dynamic> toJson() => _$StatusUrlToJson(this);
}
