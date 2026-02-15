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
    return '${Platform.environment['APPDATA']}\\dartos';
  }

  throw UnsupportedError('Plataforma no soportada');
}
