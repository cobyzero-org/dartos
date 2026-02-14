import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print("DartOS CLI");
    return;
  }

  switch (args[0]) {
    case 'create':
      createApp(args);
      break;
    case 'build':
      buildApp();
      break;
    case 'pack':
      packApp();
      break;
    case 'install':
      installApp(args);
      break;
    default:
      print("Comando no reconocido");
  }
}

void createApp(List<String> args) {
  if (args.length < 2) {
    print("Uso: dartos create <nombre>");
    return;
  }

  final name = args[1];

  Process.runSync('flutter', ['create', name], runInShell: true);

  print("App $name creada.");
}

void buildApp() {
  print("🔨 Compilando snapshot AOT...");

  final result = Process.runSync('dart', [
    'compile',
    'aot-snapshot',
    'lib/main.dart',
    '-o',
    'build/app.aot',
  ], runInShell: true);

  print(result.stdout);
  print(result.stderr);

  if (result.exitCode == 0) {
    print("✅ Snapshot generado");
  } else {
    print("❌ Error en compilación");
  }
}

void packApp() {
  final currentDir = Directory.current.path;
  final buildPath = '$currentDir/build';

  final buildDir = Directory(buildPath);

  if (!buildDir.existsSync()) {
    print("❌ No se encontró build ARM. Ejecuta: dartos build");
    return;
  }

  final appName = currentDir.split(Platform.pathSeparator).last;
  final outputFile = File('$currentDir/$appName.aot');

  final archive = Archive();

  // 1️⃣ Agregar binario principal
  final binary = File('$buildPath/$appName');
  if (!binary.existsSync()) {
    print("❌ No se encontró el binario principal.");
    return;
  }

  archive.addFile(
    ArchiveFile('bin/app', binary.lengthSync(), binary.readAsBytesSync()),
  );

  // 2️⃣ Crear manifest.json automático
  final manifest = {
    "name": appName,
    "package": "com.dartos.$appName",
    "version": "1.0.0",
    "entry": "bin/app.aot",
    "icon": "assets/icon.png",
    "runtime": "dartos_runtime",
    "permissions": [],
  };

  final manifestBytes = utf8.encode(jsonEncode(manifest));

  archive.addFile(
    ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
  );

  // 3️⃣ Comprimir
  final zipEncoder = ZipEncoder();
  final zipData = zipEncoder.encode(archive);

  outputFile.writeAsBytesSync(zipData);

  print("✅ App empaquetada como $appName.appdart");
}

void installApp(List<String> args) {
  if (args.length < 2) {
    print("Uso: dartos install <archivo.appdart>");
    return;
  }

  final filePath = args[1];
  final file = File(filePath);

  if (!file.existsSync()) {
    print("❌ Archivo no encontrado.");
    return;
  }

  final bytes = file.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  // 1️⃣ Leer manifest
  final manifestFile = archive.files.firstWhere(
    (f) => f.name == 'manifest.json',
  );

  final manifestContent = utf8.decode(manifestFile.content as List<int>);
  final manifest = jsonDecode(manifestContent);

  final packageName = manifest['package'];

  final installPath = '/apps/$packageName';
  final installDir = Directory(installPath);

  if (!installDir.existsSync()) {
    installDir.createSync(recursive: true);
  }

  // 2️⃣ Extraer archivos
  for (final file in archive.files) {
    final filename = file.name;
    final outPath = '$installPath/$filename';

    if (file.isFile) {
      final outFile = File(outPath);
      outFile.createSync(recursive: true);
      outFile.writeAsBytesSync(file.content as List<int>);
    }
  }

  // 3️⃣ Dar permiso ejecutable al binario
  Process.runSync('chmod', ['+x', '$installPath/bin/app']);

  print("✅ App instalada en $installPath");
}
