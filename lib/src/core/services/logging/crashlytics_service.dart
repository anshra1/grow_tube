import 'package:skill_tube/src/core/services/logging/logging_service.dart';

/// No-op implementation of [LoggingService] for Crashlytics.
///
/// This is a placeholder/shell for when Firebase Crashlytics is not yet
/// integrated. Replace with `CrashlyticsServiceImpl` when ready.
///
/// ## Implementation Notes (for future CrashlyticsServiceImpl):
/// - ONLY send `LogLevel.error` and `LogLevel.fatal` to Crashlytics
/// - Filter out debug/info/warning to save quota and costs
/// - Use `FirebaseCrashlytics.instance.recordError()` for errors
/// - Use `FirebaseCrashlytics.instance.setUserIdentifier()` for user ID
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
  void setUserIdentifier(String userId) {
    // No-op: Crashlytics not yet integrated
  }

  @override
  void setCustomKey(String key, String value) {
    // No-op: Crashlytics not yet integrated
  }
}
