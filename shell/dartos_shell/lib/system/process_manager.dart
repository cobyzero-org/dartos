import 'dart:convert';
import 'dart:io';

class ProcessManager {
  final Map<String, Process> _runningApps = {};

  Future<void> launchApp(String package, String appPath) async {
    if (_runningApps.containsKey(package)) {
      print("⚠️ $package ya está en ejecución");
      return;
    }

    final dartPath = "/Users/mac/fvm/versions/3.35.5/bin/dart";

    final process = await Process.start(dartPath, [appPath]);

    process.stdout.transform(utf8.decoder).listen((data) {
      print("APP STDOUT: $data");
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      print("APP ERROR: $data");
    });

    process.exitCode.then((code) {
      print("❌ $package terminó con código $code");
      _runningApps.remove(package);
    });

    _runningApps[package] = process;
  }
}
