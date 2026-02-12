/// Log severity levels for the logging system.
enum LogLevel {
  /// Detailed information for debugging purposes.
  debug,

  /// General informational messages.
  info,

  /// Potentially harmful situations that aren't errors.
  warning,

  /// Error events that might still allow the app to continue.
  error,

  /// Severe errors that cause premature termination.
  fatal,
}

/// Abstract interface for logging backends.
///
/// Implement this interface to create custom logging destinations
/// (e.g., Talker, Crashlytics, custom analytics).
abstract class LoggingService {
  /// Logs a message at the specified [level].
  ///
  /// Optionally include an [error] object and [stackTrace] for
  /// error-level logs.
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  });

  /// Sets the user identifier for crash reports and analytics.
  void setUserIdentifier(String userId);

  /// Sets a custom key-value pair for additional context in logs.
  void setCustomKey(String key, String value);
}
