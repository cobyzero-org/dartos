import 'dart:io';

class BuildDartOs {
  static Future<void> buildApp({required bool debug}) async {
    if (debug) {
      print("🛠 Compilando Flutter macOS (DEBUG)...");

      if (!Platform.isMacOS) {
        print("❌ Debug macOS solo puede compilarse en macOS.");
        return;
      }

      final result = await Process.start('flutter', [
        'build',
        'macos',
        '--debug',
      ], runInShell: true);

      await stdout.addStream(result.stdout);
      await stderr.addStream(result.stderr);

      final exitCode = await result.exitCode;

      if (exitCode != 0) {
        print("❌ Error en build debug macOS");
        return;
      }

      print("✅ Build debug macOS completado");
    } else {
      print("🔨 Compilando Flutter Linux (RELEASE)...");

      final result = await Process.start('flutter', [
        'build',
        'linux',
        '--release',
      ], runInShell: true);

      await stdout.addStream(result.stdout);
      await stderr.addStream(result.stderr);

      final exitCode = await result.exitCode;

      if (exitCode != 0) {
        print("❌ Error en build release Linux");
        return;
      }

      print("✅ Build release Linux completado");
    }
  }
}
