import 'dart:convert';
import 'dart:io';
import '../utils.dart';

class ListDartOs {
  static void listApps() {
    final appsDir = Directory('${getDartosRoot()}/apps');

    if (!appsDir.existsSync()) {
      print("📦 No hay apps instaladas.");
      return;
    }

    final apps = appsDir.listSync().whereType<Directory>();

    if (apps.isEmpty) {
      print("📦 No hay apps instaladas.");
      return;
    }

    print("📱 Apps instaladas:\n");

    for (var appDir in apps) {
      final manifestFile = File('${appDir.path}/manifest.json');

      if (!manifestFile.existsSync()) {
        continue;
      }

      final manifest = jsonDecode(manifestFile.readAsStringSync());

      final name = manifest['name'] ?? 'Sin nombre';
      final package = manifest['package'] ?? 'Desconocido';
      final version = manifest['version'] ?? '0.0.0';

      print("• $name");
      print("   Package: $package");
      print("   Version: $version\n");
    }
  }
}
