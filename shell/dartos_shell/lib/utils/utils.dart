import 'dart:io';

String detectPlatform() {
  if (Platform.isLinux) return 'linux';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isWindows) return 'windows';
  throw UnsupportedError('Plataforma no soportada');
}
