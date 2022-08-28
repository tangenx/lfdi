import 'dart:async';

import 'package:logger/logger.dart' as color_logger;

class Logger {
  color_logger.Logger logger = color_logger.Logger(
    printer:
        color_logger.PrettyPrinter(methodCount: 0, noBoxingByDefault: true),
  );

  Timer? clearLogs;

  final List<Map<String, String>> logMessages = [];

  void init() {
    clearLogs = Timer.periodic(const Duration(minutes: 10), (timer) {
      logMessages.clear();
      info('Logs cleared.', name: 'Logger');
    });
  }

  String formatString(String message, {String? name}) {
    DateTime now = DateTime.now();
    String formatTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    return '($formatTime) ${name != null ? '[$name] ' : ''}$message';
  }

  void addToPool({
    required String type,
    required String message,
  }) {
    logMessages.add({'type': type, 'message': message});
  }

  void info(String message, {String? name}) {
    String formatMessage = formatString(message, name: name);

    addToPool(type: 'info', message: formatMessage);
    logger.i(formatMessage);
  }

  void warning(String message, {String? name}) {
    String formatMessage = formatString(message, name: name);

    addToPool(type: 'warning', message: formatMessage);
    logger.w(formatMessage);
  }

  void error(String message, {String? name}) {
    String formatMessage = formatString(message, name: name);

    addToPool(type: 'error', message: formatMessage);
    logger.e(formatMessage);
  }

  void debug(String message, {String? name}) {
    String formatMessage = formatString(message, name: name);

    addToPool(type: 'debug', message: formatMessage);
    logger.d(formatMessage);
  }
}
