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
      if (args.length < 2) {
        print("Uso: dartos pack <package>");
        return;
      }
      packApp(args[1]);
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

Future<void> buildApp() async {
  print("🔨 Compilando Flutter Linux...");

  final result = await Process.start('flutter', [
    'build',
    'linux',
    '--release',
  ], runInShell: true);

  await stdout.addStream(result.stdout);
  await stderr.addStream(result.stderr);

  final exitCode = await result.exitCode;

  if (exitCode != 0) {
    print("❌ Error en build");
    return;
  }

  print("✅ Build completado");
}

Future<void> packApp(String packageName) async {
  final buildDir = _findLinuxBundle();

  if (buildDir == null) {
    print("❌ No se encontró bundle Linux.");
    return;
  }

  final encoder = ZipFileEncoder();
  encoder.create("$packageName.dartapp");

  // Agrega manifest primero
  final manifestFile = File('manifest.json');
  manifestFile.writeAsStringSync(
    jsonEncode({
      "package": packageName,
      "arch": Platform.version.contains("arm64") ? "arm64" : "x64",
    }),
  );

  encoder.addFile(manifestFile);

  // Agrega bundle completo
  encoder.addDirectory(buildDir, includeDirName: true);

  encoder.close();

  manifestFile.deleteSync();

  print("✅ Paquete generado correctamente");
}

Future<void> installApp(String filePath) async {
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

String getDartosRoot() {
  if (Platform.isLinux) {
    final xdg = Platform.environment['XDG_DATA_HOME'];
    if (xdg != null && xdg.isNotEmpty) {
      return '$xdg/dartos';
    }
    return '${Platform.environment['HOME']}/.local/share/dartos';
  }

  if (Platform.isMacOS) {
    return '${Platform.environment['HOME']}/Library/Application Support/dartos';
  }

  if (Platform.isWindows) {
    return '${Platform.environment['APPDATA']}\dartos';
  }

  throw UnsupportedError('Plataforma no soportada');
}

Directory? _findLinuxBundle() {
  final linuxDir = Directory('build/linux');

  if (!linuxDir.existsSync()) {
    return null;
  }

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
