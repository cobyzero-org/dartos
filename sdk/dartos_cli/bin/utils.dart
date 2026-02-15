import 'dart:io';

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

Directory? findLinuxBundle() {
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

Directory? findMacBundle() {
  final macDir = Directory('build/macos');

  if (!macDir.existsSync()) return null;

  final bundle = Directory('build/macos/Build/Products/Debug');

  if (!bundle.existsSync()) return null;

  return bundle;
}

String detectPlatform() {
  if (Platform.isLinux) return 'linux';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isWindows) return 'windows';
  throw UnsupportedError('Plataforma no soportada');
}
