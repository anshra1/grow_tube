/// Base class for all application-level exceptions.
/// These are thrown by the Data Layer (Repositories/DataSources).
abstract class AppException implements Exception {
  const AppException(this.message, {this.stackTrace, this.error});

  final String message;
  final StackTrace? stackTrace;
  final Object? error;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when the server returns a non-200 response or connection fails.
class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.stackTrace,
    super.error,
    this.statusCode,
  });

  final int? statusCode;
}

/// Thrown when local database operations fail (Hive, SQLite, ObjectBox).
/// Renamed from "ObjectBoxException" to be library-agnostic.
class DatabaseException extends AppException {
  const DatabaseException(
    super.message, {
    super.stackTrace,
    super.error,
  });
}

/// Thrown when cache operations fail.
class CacheException extends AppException {
  const CacheException(
    super.message, {
    super.stackTrace,
    super.error,
  });
}

/// Thrown when reading/writing files fails.
/// Renamed from "FileSystemException" to avoid conflict with dart:io.
class StorageException extends AppException {
  const StorageException(
    super.message, {
    super.stackTrace,
    super.error,
  });
}

/// Thrown when JSON parsing fails.
class ParsingException extends AppException {
  const ParsingException(
    super.message, {
    super.stackTrace,
    super.error,
  });
}

/// Thrown when the user doesn't have permission (403).
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.stackTrace,
    super.error,
  });
}

/// Thrown when video operations fail (e.g. invalid URL, offline, duplicate).
class VideoException extends AppException {
  const VideoException(
    super.message, {
    this.code,
    super.stackTrace,
    super.error,
  });

  /// Error code for UI handling: 'invalidUrl', 'videoUnavailable', 'duplicate', 'offline'.
  final String? code;
}
