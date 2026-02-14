import 'package:dartos_shell/system/app_manager.dart';
import 'package:flutter/material.dart';

class Desktop extends StatefulWidget {
  const Desktop({super.key});

  @override
  State<Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> {
  final List<String> _apps = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApps();
    });
  }

  Future<void> _loadApps() async {
    final apps = AppManager().getInstalledApps();
    _apps.addAll(apps);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.grey),
          Column(
            children: _apps.map((pkg) {
              return ElevatedButton(
                onPressed: () {
                  AppManager().launchApp(pkg);
                },
                child: Text(pkg),
              );
            }).toList(),
          ),
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
