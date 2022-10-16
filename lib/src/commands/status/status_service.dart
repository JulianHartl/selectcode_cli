import 'package:http/http.dart' as http;
import 'package:selectcli/src/services/storage_service.dart';

import '../../services/status_url.dart';

abstract class StatusService {
  static Future<bool> check(String url) async {
    try {
      await http.get(Uri.parse(url));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<StatusUrl>> getUrls() async {
    return StorageService.readConfig().then((value) => value.urls);
  }
}
