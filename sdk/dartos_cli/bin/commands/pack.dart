import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

class PackDartOs {
  static Future<void> packApp(String packageName) async {
    final bundleDir = _findLinuxBundle();

    if (bundleDir == null) {
      print("❌ No se encontró bundle Linux.");
      return;
    }

    final archive = Archive();

    // 🔹 Agregar manifest como manifest.json
    final manifest = jsonEncode({
      "package": packageName,
      "arch": Platform.version.contains("arm64") ? "arm64" : "x64",
    });

    archive.addFile(
      ArchiveFile('manifest.json', manifest.length, utf8.encode(manifest)),
    );

    // 🔹 Agregar bundle completo manualmente
    await for (final entity in bundleDir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = entity.path.substring(bundleDir.path.length + 1);

        final bytes = await entity.readAsBytes();

        archive.addFile(
          ArchiveFile('bundle/$relativePath', bytes.length, bytes),
        );
      }
    }

    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);

    final outputFile = File('$packageName.dartapp');
    await outputFile.writeAsBytes(zipData);

    print("✅ Paquete generado correctamente: ${outputFile.path}");
  }

  static Directory? _findLinuxBundle() {
    final linuxDir = Directory('build/linux');

    if (!linuxDir.existsSync()) return null;

    for (final arch in linuxDir.listSync()) {
      if (arch is Directory) {
        final bundle = Directory('${arch.path}/release/bundle');

        if (bundle.existsSync()) {
          return bundle;
        }
      }
    }

    return null;
  }
}
