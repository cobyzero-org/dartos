import 'dart:io';

class SocketServer {
  final host = '127.0.0.1';
  final port = 4040;

  void startCommandServer() async {
    final server = await ServerSocket.bind(host, port);

    print("🟢 DartOS Shell escuchando en $host:$port");

    await for (Socket client in server) {
      client.listen((data) {
        final command = String.fromCharCodes(data).trim();
        handleCommand(command);
      });
    }
  }

  void handleCommand(String command) {
    print("📩 Comando recibido: $command");

    final parts = command.split(" ");

    if (parts[0] == "RUN" && parts.length > 1) {
      launchApp(parts[1]);
    }
  }

  void launchApp(String packageName) {
    final home = Platform.environment['HOME'];

    if (home == null) {
      print("❌ No se pudo determinar el HOME del usuario");
      return;
    }

    final path = '$home/.dartos/apps/$packageName/app.dill';

    if (!File(path).existsSync()) {
      print("❌ App no encontrada en $path");
      return;
    }

    Process.start('dart', [path], mode: ProcessStartMode.detached);

    print("🚀 Lanzando $packageName");
  }
}
