import 'package:flutter/material.dart';
import 'app.dart';

class AppWindow {
  final App app;
  final Widget widget;
  Offset position;
  Size size;

  AppWindow({
    required this.app,
    required this.widget,
    this.position = const Offset(100, 100),
    this.size = const Size(400, 300),
  });
}

class WindowManager {
  static List<AppWindow> windows = [];

  static void openWindow(App app) {
    windows.add(AppWindow(app: app, widget: app.widget));
  }

  static void closeWindow(AppWindow w) {
    windows.remove(w);
  }
}
