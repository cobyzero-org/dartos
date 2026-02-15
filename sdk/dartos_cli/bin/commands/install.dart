import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import '../utils.dart';

class InstallDartOs {
  static Future<void> installApp(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // 🔹 Leer manifest
    String? packageName;
    List platforms = [];

    for (final file in archive) {
      if (file.name == 'manifest.json') {
        final content = utf8.decode(file.content as List<int>);
        final json = jsonDecode(content);
        packageName = json['package'];
        platforms = json['platforms'] ?? [];
        break;
      }
    }

    if (packageName == null) {
      print("❌ Manifest inválido");
      return;
    }

    final currentPlatform = detectPlatform();

    if (!platforms.contains(currentPlatform)) {
      print("❌ Esta app no soporta tu plataforma: $currentPlatform");
      return;
    }

    final rootDir = Directory('${getDartosRoot()}/apps');
    if (!rootDir.existsSync()) {
      rootDir.createSync(recursive: true);
    }

    final appDir = Directory('${rootDir.path}/$packageName');

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }

    // 🔹 Extraer solo la plataforma actual
    for (final file in archive) {
      if (!file.isFile) continue;

      final prefix = 'bundle/$currentPlatform/';

      if (file.name.startsWith(prefix)) {
        final relativePath = file.name.substring(prefix.length);
        final outFile = File('${appDir.path}/$relativePath');

        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(file.content as List<int>);

        // 🔹 Aplicar permisos ejecutables
        if (Platform.isLinux || Platform.isMacOS) {
          try {
            Process.runSync('chmod', ['+x', outFile.path]);
          } catch (_) {}
        }
      }

      // Guardar manifest también
      if (file.name == 'manifest.json') {
        final manifestOut = File('${appDir.path}/manifest.json');
        manifestOut.createSync(recursive: true);
        manifestOut.writeAsBytesSync(file.content as List<int>);
      }
    }

    print("✅ App instalada correctamente: $packageName");
    print("🖥 Plataforma instalada: $currentPlatform");
  }
}
