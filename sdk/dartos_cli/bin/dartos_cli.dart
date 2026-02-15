import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

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
      if (args.length < 2) {
        print("Uso: dartos install archivo.appdart");
        return;
      }
      installApp(args[1]);
      break;
    case 'list':
      listApps();
      break;
    case 'run':
      if (args.length < 2) {
        print("Uso: dartos run package.name");
        return;
      }
      runApp(args[1]);
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
  print("🔨 Compilando kernel portable...");

  final buildDir = Directory('build');
  if (!buildDir.existsSync()) {
    buildDir.createSync(recursive: true);
  }

  final result = Process.runSync('dart', [
    'compile',
    'kernel',
    'lib/main.dart',
    '-o',
    'build/app.dill',
  ], runInShell: true);

  print(result.stdout);
  print(result.stderr);

  if (result.exitCode == 0) {
    print("✅ Kernel generado (portable)");
  } else {
    print("❌ Error en compilación");
  }
}

void packApp() {
  final buildFile = File('build/app.dill');
  final manifestFile = File('manifest.json');

  if (!buildFile.existsSync()) {
    print("❌ No existe build/app.dill. Ejecuta: dartos build");
    return;
  }

  if (!manifestFile.existsSync()) {
    print("❌ No existe manifest.json");
    return;
  }

  final appName = Directory.current.path.split(Platform.pathSeparator).last;

  final archive = Archive();

  // Agregar app.dill
  archive.addFile(
    ArchiveFile(
      'app.dill',
      buildFile.lengthSync(),
      buildFile.readAsBytesSync(),
    ),
  );

  // Agregar manifest.json
  archive.addFile(
    ArchiveFile(
      'manifest.json',
      manifestFile.lengthSync(),
      manifestFile.readAsBytesSync(),
    ),
  );

  // Agregar assets si existen
  final assetsDir = Directory('assets');
  if (assetsDir.existsSync()) {
    for (var file in assetsDir.listSync(recursive: true)) {
      if (file is File) {
        final relativePath = file.path.replaceFirst('${assetsDir.path}/', '');
        archive.addFile(
          ArchiveFile(
            'assets/$relativePath',
            file.lengthSync(),
            file.readAsBytesSync(),
          ),
        );
      }
    }
  }

  final zipEncoder = ZipEncoder();
  final zipData = zipEncoder.encode(archive);

  final outputFile = File('$appName.appdart');
  outputFile.writeAsBytesSync(zipData);

  print("✅ Paquete generado correctamente: $appName.appdart");
}

void installApp(String filePath) {
  final appFile = File(filePath);

  if (!appFile.existsSync()) {
    print("❌ Archivo no encontrado");
    return;
  }

  final bytes = appFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  // Leer manifest primero
  ArchiveFile? manifestArchive;
  for (var file in archive.files) {
    if (file.name == 'manifest.json') {
      manifestArchive = file;
      break;
    }
  }

  if (manifestArchive == null) {
    print("❌ manifest.json no encontrado");
    return;
  }

  final manifestContent = utf8.decode(manifestArchive.content as List<int>);
  final manifest = jsonDecode(manifestContent);

  final packageName = manifest['package'];

  final installDir = Directory('/home/fox/.dartos/apps/$packageName');

  if (installDir.existsSync()) {
    installDir.deleteSync(recursive: true);
  }

  installDir.createSync(recursive: true);

  for (var file in archive.files) {
    final outFile = File('${installDir.path}/${file.name}');
    outFile.createSync(recursive: true);
    outFile.writeAsBytesSync(file.content as List<int>);
  }

  print("✅ App instalada: $packageName");
}

void runApp(String packageName) async {
  try {
    final socket = await Socket.connect('127.0.0.1', 4040);

    socket.write("RUN $packageName");
    await socket.flush();
    await socket.close();

    print("📤 Comando enviado al Shell");
  } catch (e) {
    print("❌ No se pudo conectar al Shell.");
    print("   ¿Está DartOS Shell corriendo?");
  }
}

void listApps() {
  final appsDir = Directory('/home/fox/.dartos/apps');

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
