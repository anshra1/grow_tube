import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:levelup_tube/src/core/services/logging_service/logging_service.dart';

/// Firebase Crashlytics implementation of [LoggingService].
///
/// Sends only `LogLevel.error` and `LogLevel.fatal` logs/crashes
/// to Firebase Crashlytics to save quota and costs.
class CrashlyticsLoggingService implements LoggingService {
  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
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
  void clearUserIdentifier() {
    FirebaseCrashlytics.instance.setUserIdentifier('');
  }

  @override
  void setCustomKey(String key, String value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  @override
  void setCustomIntKey(String key, int value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  @override
  void setCustomDoubleKey(String key, double value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  @override
  void setCustomBoolKey(String key, {required bool value}) {
    FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  @override
  void setCustomListKey(String key, List<String> value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value.join(', '));
  }

  @override
  void clearCustomKey(String key) {
    // Firebase Crashlytics doesn't have a direct clear method, so we set it to an empty string
    FirebaseCrashlytics.instance.setCustomKey(key, '');
  }

  @override
  void clearAllCustomKeys() {
    // No direct method to clear all, but we can just re-initialize or rely on app restart
    // For this implementation, we'll just log that it's not fully supported
    FirebaseCrashlytics.instance.log(
      'clearAllCustomKeys called - not fully supported by Firebase Crashlytics API',
    );
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled({
    required bool enabled,
  }) async {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(enabled);
  }

  @override
  Future<bool> isCrashlyticsCollectionEnabled() async {
    return FirebaseCrashlytics
        .instance
        .isCrashlyticsCollectionEnabled;
  }

  @override
  Future<void> sendUnsentReports() async {
    await FirebaseCrashlytics.instance.sendUnsentReports();
  }

  @override
  Future<void> deleteUnsentReports() async {
    await FirebaseCrashlytics.instance.deleteUnsentReports();
  }

  @override
  Future<void> recordFatalError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    if (reason != null) {
  await    FirebaseCrashlytics.instance.log(reason);
    }
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      fatal: true,
    );
  }

  @override
  bool get isCrashlyticsAvailable => true;

  /// Helper method to record errors to Crashlytics with a context message
  ///
  /// First logs the message, then records the error with stack trace
  void recordError(
    Object error,
    StackTrace? stackTrace,
    String message,
  ) {
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
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
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
  void clearUserIdentifier() {
    // No-op: Crashlytics not yet integrated
  }

  @override
  void setCustomKey(String key, String value) {
    // No-op: Crashlytics not yet integrated
  }

  @override
  void setCustomIntKey(String key, int value) {
    // No-op: Crashlytics not yet integrated
  }

  @override
  void setCustomDoubleKey(String key, double value) {
    // No-op: Crashlytics not yet integrated
  }

  @override
  void setCustomBoolKey(String key, {required bool value}) {
    // No-op: Crashlytics not yet integrated
  }

  @override
  void setCustomListKey(String key, List<String> value) {
    // No-op: Crashlytics not yet integrated
  }

  @override
  void clearCustomKey(String key) {
    // No-op: Crashlytics not yet integrated
  }

  @override
  void clearAllCustomKeys() {
    // No-op: Crashlytics not yet integrated
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled({
    required bool enabled,
  }) async {
    // No-op: Crashlytics not yet integrated
  }

  @override
  Future<bool> isCrashlyticsCollectionEnabled() async => false;

  @override
  Future<void> sendUnsentReports() async {
    // No-op: Crashlytics not yet integrated
  }

  @override
  Future<void> deleteUnsentReports() async {
    // No-op: Crashlytics not yet integrated
  }

  @override
  Future<void> recordFatalError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    // No-op: Crashlytics not yet integrated
  }

  @override
  bool get isCrashlyticsAvailable => false;
}
