import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print("DartOS Runtime");
    return;
  }

  final snapshotPath = args[0];

  if (!File(snapshotPath).existsSync()) {
    print("Snapshot no encontrado.");
    return;
  }

  final result = await Process.start('dart', [
    snapshotPath,
  ], mode: ProcessStartMode.inheritStdio);

  await result.exitCode;
}
