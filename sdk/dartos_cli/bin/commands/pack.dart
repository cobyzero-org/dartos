import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import '../utils.dart';

class PackDartOs {
  static Future<void> packApp(String packageName) async {
    final archive = Archive();

    final platforms = <String, Directory>{};

    final linuxBundle = findLinuxBundle();
    if (linuxBundle != null) {
      platforms['linux'] = linuxBundle;
    }

    final macBundle = findMacBundle();
    if (macBundle != null) {
      platforms['macos'] = macBundle;
    }

    if (platforms.isEmpty) {
      print("❌ No se encontró ningún build (linux o macos).");
      return;
    }

    // 🔹 Crear manifest
    final manifest = jsonEncode({
      "package": packageName,
      "platforms": platforms.keys.toList(),
    });

    archive.addFile(
      ArchiveFile('manifest.json', manifest.length, utf8.encode(manifest)),
    );

    // 🔹 Agregar bundles por plataforma
    for (final entry in platforms.entries) {
      final platform = entry.key;
      final bundleDir = entry.value;

      await for (final entity in bundleDir.list(recursive: true)) {
        if (entity is File) {
          final relativePath = entity.path.substring(bundleDir.path.length + 1);

          final bytes = await entity.readAsBytes();

          archive.addFile(
            ArchiveFile('bundle/$platform/$relativePath', bytes.length, bytes),
          );
        }
      }
    }

    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);

    final outputFile = File('$packageName.dartapp');
    await outputFile.writeAsBytes(zipData);

    print("✅ Paquete generado correctamente: ${outputFile.path}");
    print("📦 Plataformas incluidas: ${platforms.keys.join(", ")}");
  }
}
