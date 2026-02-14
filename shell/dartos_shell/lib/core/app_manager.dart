import 'dart:io';
import 'dart:convert';

import 'package:dartos_shell/core/app.dart';

class AppManager {
  final String appsPath = "/apps";

  Future<List<App>> loadApps() async {
    final dir = Directory(appsPath);
    if (!await dir.exists()) return [];

    final apps = <App>[];

    for (var entity in dir.listSync()) {
      final manifest = File("${entity.path}/manifest.json");
      if (manifest.existsSync()) {
        final data = jsonDecode(manifest.readAsStringSync());
        apps.add(App.fromManifest(entity.path, data));
      }
    }

    return apps;
  }
}
