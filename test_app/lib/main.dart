import 'dart:isolate';

void main(List<String> args, SendPort systemPort) {
  systemPort.send({"type": "log", "message": "Hola desde TestApp 🚀"});
}
