import 'package:levelup_tube/src/core/services/logging_service/logging_service.dart';

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
/// logger.handle(e, stackTrace, 'Failed to do something');
/// ```
class AppLogger {
  /// Creates an [AppLogger] with the given list of logging services.
  AppLogger({required List<LoggingService> services})
    : _services = services;

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
  }) => _log(
    LogLevel.error,
    message,
    error: error,
    stackTrace: stackTrace,
  );

  /// Logs a fatal error. Use for unrecoverable errors.
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) => _log(
    LogLevel.fatal,
    message,
    error: error,
    stackTrace: stackTrace,
  );

  /// Handles an exception/error with optional stack trace and message.
  ///
  /// This is the primary method for logging caught exceptions.
  void handle(Object error, StackTrace stackTrace, String message) {
    for (final service in _services) {
      service.handle(error, stackTrace, message);
    }
  }

  /// Sets the user identifier on all logging services.
  void setUserIdentifier(String userId) {
    for (final service in _services) {
      service.setUserIdentifier(userId);
    }
  }

  /// Clears the user identifier on all logging services.
  void clearUserIdentifier() {
    for (final service in _services) {
      service.clearUserIdentifier();
    }
  }

  /// Sets a custom key-value pair (string) on all logging services.
  void setCustomKey(String key, String value) {
    for (final service in _services) {
      service.setCustomKey(key, value);
    }
  }

  /// Sets a custom key-value pair (int) on all logging services.
  void setCustomIntKey(String key, int value) {
    for (final service in _services) {
      service.setCustomIntKey(key, value);
    }
  }

  /// Sets a custom key-value pair (double) on all logging services.
  void setCustomDoubleKey(String key, double value) {
    for (final service in _services) {
      service.setCustomDoubleKey(key, value);
    }
  }

  /// Sets a custom key-value pair (bool) on all logging services.
  void setCustomBoolKey(String key, {required bool value}) {
    for (final service in _services) {
      service.setCustomBoolKey(key, value: value);
    }
  }

  /// Sets a custom key-value pair (list) on all logging services.
  void setCustomListKey(String key, List<String> value) {
    for (final service in _services) {
      service.setCustomListKey(key, value);
    }
  }

  /// Clears a custom key on all logging services.
  void clearCustomKey(String key) {
    for (final service in _services) {
      service.clearCustomKey(key);
    }
  }

  /// Clears all custom keys on all logging services.
  void clearAllCustomKeys() {
    for (final service in _services) {
      service.clearAllCustomKeys();
    }
  }

  /// Enables or disables crash reporting on all supported logging services.
  Future<void> setCrashlyticsCollectionEnabled({
    required bool enabled,
  }) async {
    for (final service in _services) {
      await service.setCrashlyticsCollectionEnabled(enabled: enabled);
    }
  }

  /// Checks if crash reporting is enabled on any service.
  Future<bool> isCrashlyticsCollectionEnabled() async {
    for (final service in _services) {
      if (await service.isCrashlyticsCollectionEnabled()) {
        return true;
      }
    }
    return false;
  }

  /// Manually sends unsent reports on all supported logging services.
  Future<void> sendUnsentReports() async {
    for (final service in _services) {
      await service.sendUnsentReports();
    }
  }

  /// Deletes unsent reports on all supported logging services.
  Future<void> deleteUnsentReports() async {
    for (final service in _services) {
      await service.deleteUnsentReports();
    }
  }

  /// Records a fatal error on all logging services.
  Future<void> recordFatalError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    for (final service in _services) {
      await service.recordFatalError(
        error,
        stackTrace,
        reason: reason,
      );
    }
  }

  /// Checks if any logging service has Crashlytics available.
  bool get isCrashlyticsAvailable {
    for (final service in _services) {
      if (service.isCrashlyticsAvailable) {
        return true;
      }
    }
    return false;
  }

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    for (final service in _services) {
      service.log(
        level,
        message,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
