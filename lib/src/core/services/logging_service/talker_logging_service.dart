import 'package:levelup_tube/src/core/services/logging_service/logging_service.dart';
import 'package:talker/talker.dart' hide LogLevel;

/// Talker-based implementation of [LoggingService].
///
/// Provides local logging for development and in-app log viewing.
/// All logs are visible in the Talker in-app log viewer.
class TalkerLoggingService implements LoggingService {
  /// Creates a [TalkerLoggingService] with the given [Talker] instance.
  TalkerLoggingService(this._talker);

  final Talker _talker;

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    switch (level) {
      case LogLevel.debug:
        _talker.debug(message);
      case LogLevel.info:
        _talker.info(message);
      case LogLevel.warning:
        _talker.warning(message);
      case LogLevel.error:
        if (error != null) {
          _talker.error(message, error, stackTrace);
        } else {
          _talker.error(message);
        }
      case LogLevel.fatal:
        if (error != null) {
          _talker.handle(error, stackTrace, message);
        } else {
          _talker.critical(message);
        }
    }
  }

  @override
  void handle(
    Object error,
    StackTrace stackTrace,
    String message,
  ) {
    _talker.handle(error, stackTrace, message);
  }

  @override
  void setUserIdentifier(String userId) {
    _talker.info('User identified: $userId');
  }

  @override
  void clearUserIdentifier() {
    _talker.info('User identifier cleared');
  }

  @override
  void setCustomKey(String key, String value) {
    _talker.verbose('Custom key set: $key = $value');
  }

  @override
  void setCustomIntKey(String key, int value) {
    _talker.verbose('Custom int key set: $key = $value');
  }

  @override
  void setCustomDoubleKey(String key, double value) {
    _talker.verbose('Custom double key set: $key = $value');
  }

  @override
  void setCustomBoolKey(String key, {required bool value}) {
    _talker.verbose('Custom bool key set: $key = $value');
  }

  @override
  void setCustomListKey(String key, List<String> value) {
    _talker.verbose('Custom list key set: $key = [${value.join(', ')}]');
  }

  @override
  void clearCustomKey(String key) {
    _talker.verbose('Custom key cleared: $key');
  }

  @override
  void clearAllCustomKeys() {
    _talker.verbose('All custom keys cleared');
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled({required bool enabled}) async {
    _talker.info('Crashlytics collection ${enabled ? 'enabled' : 'disabled'}');
  }

  @override
  Future<bool> isCrashlyticsCollectionEnabled() async {
    return false;
  }

  @override
  Future<void> sendUnsentReports() async {
    _talker.info('Sending unsent reports (Talker only, no network request)');
  }

  @override
  Future<void> deleteUnsentReports() async {
    _talker.info('Deleting unsent reports (Talker only)');
  }

  @override
  Future<void> recordFatalError(Object error, StackTrace stackTrace, {String? reason}) async {
    if (reason != null) {
      _talker.critical('Fatal error: $reason', error, stackTrace);
    } else {
      _talker.handle(error, stackTrace);
    }
  }

  @override
  bool get isCrashlyticsAvailable => false;
}
