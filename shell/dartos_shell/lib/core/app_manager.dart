import 'dart:io';
import 'dart:convert';

class AppManager {
  final String appsPath = "/apps";

  Future<List<Map<String, dynamic>>> loadApps() async {
    final dir = Directory(appsPath);
    if (!await dir.exists()) return [];

    final apps = <Map<String, dynamic>>[];

    for (var entity in dir.listSync()) {
      final manifest = File("${entity.path}/manifest.json");
      if (manifest.existsSync()) {
        final data = jsonDecode(manifest.readAsStringSync());
        apps.add(data);
      }
    }

    return apps;
  }
}
