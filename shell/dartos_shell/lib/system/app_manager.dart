import 'dart:io';

import 'package:dartos_shell/utils/path.dart';

class AppManager {
  List<String> getInstalledApps() {
    final appsDir = Directory('${getDartosRoot()}/apps');

    if (!appsDir.existsSync()) {
      print("❌ No se pudo encontrar el directorio de apps");
      return [];
    }

    return appsDir
        .listSync()
        .whereType<Directory>()
        .map((dir) => dir.path.split('/').last)
        .toList();
  }

  Future<void> launchApp(String package) async {
    final home = Platform.environment['HOME'];
    final appDir = Directory('$home/.dartos/apps/$package/bundle');

    if (!appDir.existsSync()) {
      print("❌ App no encontrada");
      return;
    }

    final executable = File('${appDir.path}/$package');

    if (!executable.existsSync()) {
      print("❌ Ejecutable no encontrado");
      return;
    }

    final process = await Process.start(
      executable.path,
      [],
      workingDirectory: appDir.path,
    );

    print("🚀 App lanzada: $package (PID: ${process.pid})");
  }
}
