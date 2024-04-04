import 'dart:developer';

/// A class that provides logging functionality with colored output for warnings and errors.
class Logger {
  /// The ANSI escape code for red color.
  static final _errorColor = '\x1B[31m';

  /// The ANSI escape code for yellow color.
  static final _warningColor = '\x1B[33m';

  /// The ANSI escape code to reset the color.
  static final _resetColor = '\x1B[0m';

  /// Logs an error message if a condition is met.
  ///
  /// [condition] is the condition to check.
  /// [message] is the error message to be logged if the condition is true.
  /// [error] is an optional error object associated with the error message.
  /// [stackTrace] is an optional stack trace associated with the error message.
  static void conditionalError(bool condition, String message,
      [Object? error, StackTrace? stackTrace]) {
    if (condition) {
      _logError('ERROR', _errorColor, message, error, stackTrace);
    }
  }

  /// Logs a warning message if a condition is met.
  ///
  /// [condition] is the condition to check.
  /// [message] is the warning message to be logged if the condition is true.
  static void conditionalWarning(bool condition, String message) {
    if (condition) {
      _logMessage('WARNING', _warningColor, message);
    }
  }

  /// Logs an error message.
  ///
  /// [message] is the error message to be logged.
  /// [error] is an optional error object associated with the error message.
  /// [stackTrace] is an optional stack trace associated with the error message.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logError('ERROR', _errorColor, message, error, stackTrace);
  }

  /// Logs a warning message.
  ///
  /// [message] is the warning message to be logged.
  static void warning(String message) {
    _logMessage('WARNING', _warningColor, message);
  }

  /// Logs a message with the specified level, color, and timestamp.
  ///
  /// [level] is the log level (e.g., WARNING, ERROR).
  /// [color] is the ANSI escape code for the color.
  /// [message] is the message to be logged.
  static void _log(String level, String color, String message) {
    final now = DateTime.now();
    final formattedTime = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    final logMessage = '$formattedTime [$color$level$_resetColor] $message';
    log(logMessage);
  }

  /// Logs an error message with additional error and stack trace information.
  ///
  /// [level] is the log level (e.g., WARNING, ERROR).
  /// [color] is the ANSI escape code for the color.
  /// [message] is the error message to be logged.
  /// [error] is an optional error object associated with the error message.
  /// [stackTrace] is an optional stack trace associated with the error message.
  static void _logError(String level, String color, String message,
      [Object? error, StackTrace? stackTrace]) {
    String errorMessage = message;
    if (error != null) {
      errorMessage += '\nError: $error';
    }
    if (stackTrace != null) {
      errorMessage += '\nStackTrace: $stackTrace';
    }
    _log(level, color, errorMessage);
  }

  /// Logs a message with the specified level and color.
  ///
  /// [level] is the log level (e.g., WARNING, ERROR).
  /// [color] is the ANSI escape code for the color.
  /// [message] is the message to be logged.
  static void _logMessage(String level, String color, String message) {
    _log(level, color, message);
  }
}
