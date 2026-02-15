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

    String executablePath;

    if (platform == 'linux') {
      executablePath = '${appDir.path}/$package';
    } else if (platform == 'macos') {
      // Buscar automáticamente el .app dentro del directorio
      final appBundles = appDir
          .listSync()
          .whereType<Directory>()
          .where((dir) => dir.path.endsWith('.app'))
          .toList();

      if (appBundles.isEmpty) {
        print("❌ No se encontró ningún bundle .app");
        return;
      }

      final macExecutableDir = Directory(
        '${appBundles.first.path}/Contents/MacOS',
      );

      if (!macExecutableDir.existsSync()) {
        print("❌ Carpeta Contents/MacOS no encontrada");
        return;
      }

      final executables = macExecutableDir
          .listSync()
          .whereType<File>()
          .toList();

      if (executables.isEmpty) {
        print("❌ Ejecutable dentro del .app no encontrado");
        return;
      }

      executablePath = executables.first.path;
    } else {
      print("❌ Plataforma no soportada");
      return;
    }

    final executable = File(executablePath);

    if (!executable.existsSync()) {
      print("❌ Ejecutable no encontrado");
      return;
    }

    final process = await Process.start(
      executable.path,
      [],
      workingDirectory: appDir.path,
      mode: ProcessStartMode.detachedWithStdio,
    );

    print("🚀 App lanzada: $package (PID: ${process.pid})");

    process.stdout.transform(utf8.decoder).listen((data) {
      print("APP STDOUT: $data");
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      print("APP STDERR: $data");
    });
  }
}
