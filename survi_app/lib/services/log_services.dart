import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LogService {
  static File? _logFile;

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/app.log');
  }

  static Future<void> log(String message) async {
    final logMessage = '${DateTime.now().toIso8601String()} - $message\n';
    await _logFile?.writeAsString(logMessage, mode: FileMode.append);
  }

  static Future<String> readLogs() async {
    return await _logFile?.readAsString() ?? '';
  }
}