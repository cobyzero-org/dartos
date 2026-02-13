import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class App {
  final String name; // Nombre de la app
  final String version; // Versión
  final String path; // Ruta en /apps
  final Widget widget; // Widget principal (si es Flutter)
  final String iconPath; // Ruta del ícono
  final List<String> permissions; // Permisos declarados en manifest

  App({
    required this.name,
    required this.version,
    required this.path,
    required this.widget,
    required this.iconPath,
    this.permissions = const [],
  });

  // Cargar app desde manifest.json
  static App fromManifest(String appPath, Widget widget) {
    final manifestFile = File('$appPath/manifest.json');
    if (!manifestFile.existsSync()) {
      throw Exception('Manifest no encontrado en $appPath');
    }

    final manifest = jsonDecode(manifestFile.readAsStringSync());

    return App(
      name: manifest['name'],
      version: manifest['version'],
      path: appPath,
      widget: widget, // widget generado por tu shell
      iconPath: '$appPath/${manifest['icon']}',
      permissions: List<String>.from(manifest['permissions'] ?? []),
    );
  }
}
