import 'dart:io';

import 'dart:isolate';

class AppManager {
  final Map<String, Isolate> _runningApps = {};

  List<String> getInstalledApps() {
    final appsDir = Directory('/apps');

    if (!appsDir.existsSync()) return [];

    return appsDir
        .listSync()
        .whereType<Directory>()
        .map((dir) => dir.path.split('/').last)
        .toList();
  }

  Future<void> launchApp(String package) async {
    final appPath = "/apps/$package/lib/main.dart";

    if (!File(appPath).existsSync()) {
      print("App no encontrada: $package");
      return;
    }

    final receivePort = ReceivePort();

    await Isolate.spawnUri(Uri.file(appPath), [], receivePort.sendPort);

    receivePort.listen((message) {
      print("Mensaje desde $package: $message");
    });
  }
}
