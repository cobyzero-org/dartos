import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';

class InstallDartOs {
  static Future<void> installApp(String filePath) async {
    final home = Platform.environment['HOME'];
    final rootDir = Directory('$home/.dartos/apps');

    if (!rootDir.existsSync()) {
      rootDir.createSync(recursive: true);
    }

    final bytes = File(filePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    String? packageName;

    for (final file in archive) {
      if (file.name.endsWith('manifest.json')) {
        final content = utf8.decode(file.content as List<int>);
        final json = jsonDecode(content);
        packageName = json['package'];
        break;
      }
    }

    if (packageName == null) {
      print("❌ Manifest inválido");
      return;
    }

    final appDir = Directory('${rootDir.path}/$packageName');

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }

    for (final file in archive) {
      final filename = file.name;

      if (file.isFile) {
        final outFile = File('${appDir.path}/$filename');
        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(file.content as List<int>);
      }
    }

    print("✅ App instalada: $packageName");
  }
}
