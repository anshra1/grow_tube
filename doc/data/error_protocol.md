# Error Protocol

> **All exceptions and failures MUST be defined in `lib/src/core/error/`**
> 
> AI Agents: Before throwing or catching any exception, verify it exists in this folder. If not, **create it first**.

---

## Overview

This project uses a **two-tier error system**:

| Type | Layer | Purpose | Location |
|------|-------|---------|----------|
| **Exception** | Data | Thrown by DataSources/Repositories | `exception.dart` |
| **Failure** | Domain/Presentation | Returned to UI via `Either<Failure, T>` | `failure.dart` |

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│                   (Receives Failure objects)                    │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │  Either<Failure, T>
                              │
┌─────────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                             │
│               (Repository Interface returns Either)             │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │  Map Exception to Failure
                              │
┌─────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                              │
│       (DataSources throw Exceptions, Repo catches & maps)       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Folder Structure

```
lib/src/core/error/
├── exception.dart      # All AppException subclasses
└── failure.dart        # All Failure subclasses
```

---

## 1. Exceptions (`exception.dart`)

> **Thrown by:** DataSources (Remote/Local)
> **Caught by:** Repository implementations

### Base Class

```dart
abstract class AppException implements Exception {
  const AppException(this.message, {this.stackTrace, this.originalError});

  final String message;
  final StackTrace? stackTrace;
  final Object? originalError;

  @override
  String toString() => '$runtimeType: $message';
}
```

### Exception Catalog

| Exception | When to Throw | Example |
|-----------|---------------|---------|
| `ServerException` | API returns non-2xx, network timeout | `dio.get()` fails |
| `CacheException` | Cache miss, corrupted data | No cached data found |
| `DatabaseException` | Local DB read/write fails | ObjectBox error |
| `StorageException` | File I/O fails | Cannot write to disk |
| `ParsingException` | JSON decode fails | Malformed API response |
| `VideoException` | Invalid YouTube URL, video unavailable/private | `youtube_explode_dart` fetch fails. Use `code` field: `invalidUrl`, `videoUnavailable` |

### Adding a New Exception

```dart
/// Thrown when [describe scenario].
class MyNewException extends AppException {
  const MyNewException(
    super.message, {
    super.stackTrace,
    super.originalError,
    this.customField,  // Optional: add context-specific fields
  });

  final String? customField;
}
```

---

## 2. Failures (`failure.dart`)

> **Returned by:** Repository implementations
> **Consumed by:** Blocs/Cubits → UI

### Base Class

```dart
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.title,
    this.code,
  });

  final String message;      // User-friendly message
  final String? title;       // Dialog/Snackbar title
  final String? code;        // Error code for logging/analytics

  @override
  List<Object?> get props => [message, title, code];
}
```

### Failure Catalog

| Failure | Maps From | UI Behavior |
|---------|-----------|-------------|
| `ServerFailure` | `ServerException` | Show retry option |
| `CacheFailure` | `CacheException` | Show "offline" state |
| `ConnectionFailure` | `SocketException` | Show connectivity banner |
| `ValidationFailure` | Business logic | Show inline error |
| `VideoFailure` | `VideoException` | Show toast: "Invalid URL" or "Video unavailable" based on `code` |
| `UnknownFailure` | Any uncaught | Show generic error |

### Adding a New Failure

```dart
/// Represents [describe failure scenario].
class MyNewFailure extends Failure {
  const MyNewFailure({required super.message, super.code})
      : super(title: 'My Error Title');
}
```

---

## 3. Usage Pattern

### DataSource (Throws Exception)

```dart
Future<TaskModel> getTask(String id) async {
  try {
    final response = await _dio.get('/tasks/$id');
    return TaskModel.fromJson(response.data);
  } catch (e, s) {
    throw ServerException(
      'Failed to fetch task',
      stackTrace: s,
      originalError: e,
    );
  }
}
```

### Repository (Catches & Maps)

```dart
ResultFuture<Task> getTask(String id) async {
  try {
    final model = await _remoteDataSource.getTask(id);
    return Right(model.toEntity());
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message));
  } catch (e) {
    return Left(UnknownFailure(message: e.toString()));
  }
}
```

### Bloc/Cubit (Handles Failure)

```dart
Future<void> loadTask(String id) async {
  emit(TaskLoading());
  
  final result = await _getTask(id);
  
  result.fold(
    (failure) => emit(TaskError(failure.message)),
    (task) => emit(TaskLoaded(task)),
  );
}
```

---

## 4. Rules for AI Agents

> [!IMPORTANT]
> **Follow these rules when generating code that handles errors.**

### ✅ DO

1. **Check if exception/failure exists** in `lib/src/core/error/` before using
2. **Create new types** in the centralized folder if needed
3. **Include context** — pass `stackTrace` and `originalError`
4. **Write user-friendly messages** in failures

### ❌ DON'T

1. **Don't throw raw Dart exceptions** (FormatException, etc.) — wrap them
2. **Don't create feature-specific exception files** — keep centralized
3. **Don't catch `Exception` generically** — be specific
4. **Don't expose technical errors to users** — map to friendly messages

---

## 5. Exception → Failure Quick Reference

```
┌────────────────────┐      ┌────────────────────┐
│   ServerException  │ ───▶ │   ServerFailure    │
├────────────────────┤      ├────────────────────┤
│   CacheException   │ ───▶ │   CacheFailure     │
├────────────────────┤      ├────────────────────┤
│  SocketException   │ ───▶ │ ConnectionFailure  │
├────────────────────┤      ├────────────────────┤
│  ParsingException  │ ───▶ │   ServerFailure    │
├────────────────────┤      ├────────────────────┤
│  VideoException    │ ───▶ │   VideoFailure     │
├────────────────────┤      ├────────────────────┤
│     (Unknown)      │ ───▶ │  UnknownFailure    │
└────────────────────┘      └────────────────────┘
```

---

## 6. Checklist for New Error Types

- [ ] Does this error type already exist? Check `exception.dart` and `failure.dart`
- [ ] Add Exception to `exception.dart` if needed
- [ ] Add Failure to `failure.dart` if needed  
- [ ] Update this document with new types