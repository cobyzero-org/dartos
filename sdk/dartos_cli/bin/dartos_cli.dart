import 'commands/build.dart';
import 'commands/pack.dart';
import 'commands/install.dart';
import 'commands/list.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print("DartOS CLI");
    return;
  }

  switch (args[0]) {
    case 'build':
      if (args.length > 1 && args[1] == 'debug') {
        BuildDartOs.buildApp(debug: true);
      } else {
        BuildDartOs.buildApp(debug: false);
      }
      break;
    case 'pack':
      if (args.length < 2) {
        print("Uso: dartos pack <package>");
        return;
      }
      PackDartOs.packApp(args[1]);
      break;
    case 'install':
      if (args.length < 2) {
        print("Uso: dartos install archivo.appdart");
        return;
      }
      InstallDartOs.installApp(args[1]);
      break;
    case 'list':
      ListDartOs.listApps();
      break;
    default:
      print("Comando no reconocido");
  }
}
