import 'dart:io';
import 'package:archive/archive_io.dart';

class PackageInstaller {
  Future<void> install(String path) async {
    final bytes = File(path).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      final data = file.content as List<int>;
      File("/apps/$filename")
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    }
  }
}
