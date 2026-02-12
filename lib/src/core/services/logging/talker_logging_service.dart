import 'package:skill_tube/src/core/services/logging/logging_service.dart';
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
  void setUserIdentifier(String userId) {
    _talker.info('User identified: $userId');
  }

  @override
  void setCustomKey(String key, String value) {
    _talker.verbose('Custom key set: $key = $value');
  }
}
