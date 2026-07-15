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

  /// Handles an exception/error with optional stack trace and message.
  ///
  /// This is the primary method for logging caught exceptions.
  void handle(Object error, StackTrace stackTrace, String message);

  /// Sets the user identifier for crash reports and analytics.
  void setUserIdentifier(String userId);

  /// Clears the user identifier.
  void clearUserIdentifier();

  /// Sets a custom key-value pair (string) for additional context in logs.
  void setCustomKey(String key, String value);

  /// Sets a custom key-value pair (int) for additional context in logs.
  void setCustomIntKey(String key, int value);

  /// Sets a custom key-value pair (double) for additional context in logs.
  void setCustomDoubleKey(String key, double value);

  /// Sets a custom key-value pair (bool) for additional context in logs.
  void setCustomBoolKey(String key, {required bool value});

  /// Sets a custom key-value pair (list) for additional context in logs.
  void setCustomListKey(String key, List<String> value);

  /// Clears a custom key.
  void clearCustomKey(String key);

  /// Clears all custom keys.
  void clearAllCustomKeys();

  /// Enables or disables crash reporting.
  Future<void> setCrashlyticsCollectionEnabled({
    required bool enabled,
  });

  /// Checks if crash reporting is enabled.
  Future<bool> isCrashlyticsCollectionEnabled();

  /// Manually sends an error to Crashlytics.
  Future<void> sendUnsentReports();

  /// Deletes any unsent reports.
  Future<void> deleteUnsentReports();

  /// Records a fatal error to Crashlytics.
  Future<void> recordFatalError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  });

  /// Checks if Crashlytics is available.
  bool get isCrashlyticsAvailable;
}
