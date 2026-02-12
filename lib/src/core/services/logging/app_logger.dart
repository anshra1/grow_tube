import 'package:skill_tube/src/core/services/logging/logging_service.dart';

/// Unified logging facade that routes logs to multiple backends.
///
/// This is the primary entry point for logging throughout the application.
/// It distributes log calls to all registered [LoggingService] implementations.
///
/// ## Usage:
/// ```dart
/// final logger = sl<AppLogger>();
/// logger.debug('User tapped button');
/// logger.info('Data loaded successfully');
/// logger.warning('Deprecated API field used');
/// logger.error('Failed to fetch data', error: e, stackTrace: stack);
/// logger.fatal('Critical failure', error: e, stackTrace: stack);
/// ```
class AppLogger {
  /// Creates an [AppLogger] with the given list of logging services.
  AppLogger({required List<LoggingService> services}) : _services = services;

  final List<LoggingService> _services;

  /// Logs a debug message.
  void debug(String message) => _log(LogLevel.debug, message);

  /// Logs an informational message.
  void info(String message) => _log(LogLevel.info, message);

  /// Logs a warning message.
  void warning(String message) => _log(LogLevel.warning, message);

  /// Logs an error message with optional error object and stack trace.
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) => _log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  /// Logs a fatal error. Use for unrecoverable errors.
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) => _log(LogLevel.fatal, message, error: error, stackTrace: stackTrace);

  /// Sets the user identifier on all logging services.
  void setUserIdentifier(String userId) {
    for (final service in _services) {
      service.setUserIdentifier(userId);
    }
  }

  /// Sets a custom key-value pair on all logging services.
  void setCustomKey(String key, String value) {
    for (final service in _services) {
      service.setCustomKey(key, value);
    }
  }

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    for (final service in _services) {
      service.log(level, message, error: error, stackTrace: stackTrace);
    }
  }
}
