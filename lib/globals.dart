import 'dart:developer';
import 'dart:io';

import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    noBoxingByDefault: true,
    // disable cuz bad symbols
    colors: false,
  ),
  output: FileOutput(),
);

class FileOutput extends LogOutput {
  FileOutput();

  File? file;

  @override
  void init() {
    super.init();
    file = File('./logs.txt');
  }

  @override
  void output(OutputEvent event) async {
    if (file != null) {
      for (var line in event.lines) {
        log(line);
        await file!.writeAsString("$line\n", mode: FileMode.writeOnlyAppend);
      }
    } else {
      for (var line in event.lines) {
        log(line);
      }
    }
  }
}
