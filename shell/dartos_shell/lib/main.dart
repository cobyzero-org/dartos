import 'package:dartos_shell/core/desktop.dart';
import 'package:dartos_shell/socket/socket_server.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  SocketServer().startCommandServer();
  WindowOptions options = const WindowOptions(fullScreen: false);

  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const DartOS());
}

class DartOS extends StatelessWidget {
  const DartOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Desktop(),
    );
  }
}
