import "package:json2yaml/json2yaml.dart";
import "package:selectcli/src/services/config.dart";
import "package:universal_io/io.dart";
import "package:yaml/yaml.dart";

class IllegalConfigFormatException implements Exception {
  String get message => "Config file has illegal format.";
}

class StorageService {
  static const storageFolderName = ".select-cli";
  static const configFileName = "config.yaml";

  static Config? _cached;

  static Future<File> _getConfigFile() async {
    final file = File(
        "${Platform.environment["HOME"]}/$storageFolderName/$configFileName",);
    if (!(await file.exists())) {
      await file.create(recursive: true);
      await writeConfig(Config.initial());
    }
    return file;
  }

  static Future<Config> writeConfig(Config config) async {
    final file = await _getConfigFile();
    await file.writeAsString(json2yaml(config.toJson()));
    _cached = config;
    return config;
  }

  static Future<Config> readConfig() async {
    if (_cached != null) return _cached!;
    final content = await (await _getConfigFile()).readAsString();
    final yaml = loadYaml(content);
    try {
      if (yaml is YamlMap) {
        final config = Config.fromJson(
          Map<String, dynamic>.from(
            yaml.value,
          ),
        );
        return config;
      }
    } catch (_) {}
    throw IllegalConfigFormatException();
  }

  static Map<dynamic, dynamic> _convertToList(YamlMap yaml, String key) {
    final map = {...yaml.value};
    if (map[key] is List) return map;
    map.addAll({
      key: (map[key] as YamlMap).entries.map((e) => {e.key: e.value}).toList(),
    });
    return map;
  }
}
