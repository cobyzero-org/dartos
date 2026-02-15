import 'dart:convert';
import 'dart:io';

import 'package:dartos_shell/utils/path.dart';
import 'package:dartos_shell/utils/utils.dart';

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
    final root = getDartosRoot();
    final appDir = Directory('$root/apps/$package');

    if (!appDir.existsSync()) {
      print("❌ App no encontrada: $package");
      return;
    }

    final platform = detectPlatform();

    if (platform == 'linux') {
      final files = appDir
          .listSync()
          .whereType<File>()
          .where((f) => !f.path.endsWith('.json'))
          .toList();

      if (files.isEmpty) {
        print("❌ Ejecutable no encontrado en Linux");
        return;
      }

      final executable = files.first;

      final process = await Process.start(
        executable.path,
        [],
        workingDirectory: appDir.path,
        environment: Platform.environment,
      );

      print("🚀 App Linux lanzada: $package (PID: ${process.pid})");

      process.stdout.transform(utf8.decoder).listen((data) {
        print("APP STDOUT: $data");
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        print("APP STDERR: $data");
      });

      return;
    } else if (platform == 'macos') {
      final appBundles = appDir
          .listSync()
          .whereType<Directory>()
          .where((dir) => dir.path.endsWith('.app'))
          .toList();

      if (appBundles.isEmpty) {
        print("❌ No se encontró ningún bundle .app");
        return;
      }

      final process = await Process.start('open', [appBundles.first.path]);

      print("🚀 App macOS lanzada: $package (PID: ${process.pid})");
      return;
    } else {
      print("❌ Plataforma no soportada");
      return;
    }
  }
}
