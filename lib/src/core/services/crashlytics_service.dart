import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:levelup_tube/src/core/services/logging_service/logging_service.dart';

/// Firebase Crashlytics implementation of [LoggingService].
///
/// Sends only `LogLevel.error` and `LogLevel.fatal` logs/crashes
/// to Firebase Crashlytics to save quota and costs.
class CrashlyticsLoggingService implements LoggingService {
  @override
  void log(LogLevel level, String message, {Object? error, StackTrace? stackTrace}) {
    // Only send error and fatal level logs to Crashlytics to save quota
    if (level == LogLevel.error || level == LogLevel.fatal) {
      if (error != null) {
        recordError(error, stackTrace, message);
      } else {
        FirebaseCrashlytics.instance.log(message);
      }
    }
  }

  @override
  void handle(Object error, StackTrace stackTrace, String message) {
    recordError(error, stackTrace, message);
  }

  @override
  void setUserIdentifier(String userId) {
    FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  @override
  void setCustomKey(String key, String value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  /// Helper method to record errors to Crashlytics with a context message
  ///
  /// First logs the message, then records the error with stack trace
  void recordError(Object error, StackTrace? stackTrace, String message) {
    FirebaseCrashlytics.instance.log(message);
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}

/// No-op implementation of [LoggingService] for Crashlytics.
///
/// This is a placeholder/shell for when Firebase Crashlytics is not yet
/// integrated.
class NoOpCrashlyticsService implements LoggingService {
  @override
  void log(LogLevel level, String message, {Object? error, StackTrace? stackTrace}) {
    // No-op: Crashlytics not yet integrated
  }

  @override
  void handle(Object error, StackTrace stackTrace, String message) {
    // No-op: Crashlytics not yet integrated
  }

  @override
  void setUserIdentifier(String userId) {
    // No-op: Crashlytics not yet integrated
  }

  @override
  void setCustomKey(String key, String value) {
    // No-op: Crashlytics not yet integrated
  }
}
