import 'package:dartos_shell/core/app_manager.dart';
import 'package:flutter/material.dart';
import 'window_manager.dart';

class Desktop extends StatefulWidget {
  const Desktop({super.key});

  @override
  State<Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> {
  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await AppManager().loadApps();
    for (final app in apps) {
      WindowManager.openWindow(app);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Container(color: Colors.black),

          // Ventanas abiertas
          ...WindowManager.windows.map(
            (w) => Positioned(
              left: w.position.dx,
              top: w.position.dy,
              child: Draggable(
                feedback: w.widget,
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  w.position = details.offset;
                },
                child: w.widget,
              ),
            ),
          ),

          // Dock
          const Align(alignment: Alignment.bottomCenter, child: Dock()),
        ],
      ),
    );
  }
}

class Dock extends StatelessWidget {
  const Dock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.apps, color: Colors.white),
          SizedBox(width: 20),
          Icon(Icons.settings, color: Colors.white),
        ],
      ),
    );
  }
}
