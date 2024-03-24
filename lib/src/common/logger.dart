class Logger {
  static final _errorColor = '\x1B[31m';
  static final _warningColor = '\x1B[33m';
  static final _resetColor = '\x1B[0m';

  static void warning(String message) {
    _logMessage('WARNING', _warningColor, message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logError('ERROR', _errorColor, message, error, stackTrace);
  }

  static void conditionalWarning(bool condition, String message) {
    if (condition) {
      _logMessage('WARNING', _warningColor, message);
    }
  }

  static void conditionalError(bool condition, String message,
      [Object? error, StackTrace? stackTrace]) {
    if (condition) {
      _logError('ERROR', _errorColor, message, error, stackTrace);
    }
  }

  static void _logMessage(String level, String color, String message) {
    _log(level, color, message);
  }

  static void _logError(String level, String color, String message,
      [Object? error, StackTrace? stackTrace]) {
    String errorMessage = '$message';
    if (error != null) {
      errorMessage += '\nError: $error';
    }
    if (stackTrace != null) {
      errorMessage += '\nStackTrace: $stackTrace';
    }
    _log(level, color, errorMessage);
  }

  static void _log(String level, String color, String message) {
    final now = DateTime.now();
    final formattedTime = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    final logMessage = '$formattedTime [$color$level$_resetColor] $message';
    print(logMessage);
  }
}
