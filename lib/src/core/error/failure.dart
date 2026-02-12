import 'package:equatable/equatable.dart';

/// Base class for all failures.
/// These are returned by the Domain Layer to the Presentation Layer.
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.title,
    this.code,
  });

  final String message;
  final String? title;
  final String? code;

  @override
  List<Object?> get props => [message, title, code];
}

/// Represents a failure from the remote server.
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  }) : super(title: 'Server Error');

  final int? statusCode;

  @override
  List<Object?> get props => [message, title, code, statusCode];
}

/// Represents a cache or local DB failure.
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code}) : super(title: 'Cache Error');
}

/// Represents a network connectivity failure (No Internet).
class ConnectionFailure extends Failure {
  const ConnectionFailure()
    : super(message: 'No internet connection', title: 'Network Error');
}

/// Represents a validation logic failure (e.g. Password too short).
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message}) : super(title: 'Invalid Input');
}

/// Represents an authentication failure.
class AuthFailure extends Failure {
  const AuthFailure({required super.message}) : super(title: 'Authentication Error');
}

/// Catch-all for unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred'})
    : super(title: 'Unknown Error');
}
