# Data Layer Patterns

> **INFRASTRUCTURE.** Handles serialization, API calls, caching, and mapping.

## 2.1 Model (Freezed + JSON)

**Path:** `lib/src/features/tasks/data/models/task_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solearium/src/features/tasks/domain/entities/task.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
class TaskModel with _$TaskModel {
  const TaskModel._(); // Required for custom methods

  const factory TaskModel({
    required String id,
    required String title,
    required String description,
    required String priority, // API returns string: "low", "medium", "high"
    required String status, // API returns string: "pending", "in_progress"
    @JsonKey(name: 'due_date') required DateTime dueDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  // ─────────────────────────────────────────────────────────────────────────
  // ENTITY MAPPING
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps Model → Entity (for reads)
  Task toEntity() => Task(
        id: id,
        title: title,
        description: description,
        priority: _parsePriority(priority),
        status: _parseStatus(status),
        dueDate: dueDate,
        createdAt: createdAt,
        completedAt: completedAt,
      );

  /// Maps Entity → Model (for writes)
  static TaskModel fromEntity(Task entity) => TaskModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        priority: entity.priority.name,
        status: _statusToString(entity.status),
        dueDate: entity.dueDate,
        createdAt: entity.createdAt,
        completedAt: entity.completedAt,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  static TaskPriority _parsePriority(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskPriority.medium,
    );
  }

  static TaskStatus _parseStatus(String value) {
    switch (value) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.pending;
    }
  }

  static String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.pending:
        return 'pending';
    }
  }
}
```

**Rules:**
- Use `@JsonKey(name: '')` for snake_case API fields
- Implement both `toEntity()` and `fromEntity()`
- Handle enum string conversions in mapping methods
- **HAS** `part 'task_model.g.dart'` — JSON generation needed
- Add `const TaskModel._()` BEFORE the factory constructor

---

### Entity vs Model Summary

| Aspect | Entity | Model |
|--------|--------|-------|
| **Location** | `domain/entities/` | `data/models/` |
| **Annotation** | `@freezed` | `@freezed` |
| **fromJson** | ❌ No | ✅ Yes |
| **toJson** | ❌ No | ✅ Yes (auto) |
| **part files** | `.freezed.dart` only | `.freezed.dart` + `.g.dart` |
| **Mapping** | — | `toEntity()` / `fromEntity()` |

---

## 2.2 Remote Data Source

**Path:** `lib/src/features/tasks/data/datasources/task_remote_data_source.dart`

```dart
import 'package:dio/dio.dart';
import 'package:solearium/src/core/error/exception.dart';
import 'package:solearium/src/features/tasks/data/models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks({int page = 1, int limit = 10});
  Future<TaskModel> getTaskById(String id);
  Future<TaskModel> createTask(TaskModel model);
  Future<TaskModel> updateTask(TaskModel model);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  const TaskRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  static const String _basePath = '/api/v1/tasks';

  @override
  Future<List<TaskModel>> getTasks({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        _basePath,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data['data'] as List;
      return data.map((e) => TaskModel.fromJson(e)).toList();
    } on DioException catch (e, s) {
      throw ServerException(
        e.message ?? 'Failed to fetch tasks',
        statusCode: e.response?.statusCode,
        error: e,
        stackTrace: s,
      );
    } catch (e, s) {
      throw ServerException(
        e.toString(),
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await _dio.get('$_basePath/$id');
      return TaskModel.fromJson(response.data['data']);
    } on DioException catch (e, s) {
      throw ServerException(
        e.message ?? 'Failed to fetch task details',
        statusCode: e.response?.statusCode,
        error: e,
        stackTrace: s,
      );
    } catch (e, s) {
      throw ServerException(
        e.toString(),
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel model) async {
    try {
      final response = await _dio.post(_basePath, data: model.toJson());
      return TaskModel.fromJson(response.data['data']);
    } on DioException catch (e, s) {
      throw ServerException(
        e.message ?? 'Failed to create task',
        statusCode: e.response?.statusCode,
        error: e,
        stackTrace: s,
      );
    } catch (e, s) {
      throw ServerException(
        e.toString(),
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel model) async {
    try {
      final response = await _dio.put(
        '$_basePath/${model.id}',
        data: model.toJson(),
      );
      return TaskModel.fromJson(response.data['data']);
    } on DioException catch (e, s) {
      throw ServerException(
        e.message ?? 'Failed to update task',
        statusCode: e.response?.statusCode,
        error: e,
        stackTrace: s,
      );
    } catch (e, s) {
      throw ServerException(
        e.toString(),
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete('$_basePath/$id');
    } on DioException catch (e, s) {
      throw ServerException(
        e.message ?? 'Failed to delete task',
        statusCode: e.response?.statusCode,
        error: e,
        stackTrace: s,
      );
    } catch (e, s) {
      throw ServerException(
        e.toString(),
        error: e,
        stackTrace: s,
      );
    }
  }
}
```

---

## 2.3 Local Data Source (Cache)

**Path:** `lib/src/features/tasks/data/datasources/task_local_data_source.dart`

```dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solearium/src/core/error/exception.dart';
import 'package:solearium/src/features/tasks/data/models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getCachedTasks();
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<void> clearCache();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  const TaskLocalDataSourceImpl(this._prefs);
  final SharedPreferences _prefs;

  static const String _tasksKey = 'CACHED_TASKS';

  @override
  Future<List<TaskModel>> getCachedTasks() async {
    final jsonString = _prefs.getString(_tasksKey);
    if (jsonString == null) {
      throw const CacheException('No cached tasks found.');
    }
    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((e) => TaskModel.fromJson(e)).toList();
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final jsonList = tasks.map((e) => e.toJson()).toList();
    await _prefs.setString(_tasksKey, json.encode(jsonList));
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_tasksKey);
  }
}
```

---

## 2.4 Repository Implementation

**Path:** `lib/src/features/tasks/data/repositories/task_repository_impl.dart`

```dart
import 'package:fpdart/fpdart.dart';
import 'package:solearium/src/core/common/typedef.dart';
import 'package:solearium/src/core/error/exception.dart';
import 'package:solearium/src/core/error/failure.dart';
import 'package:solearium/src/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:solearium/src/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:solearium/src/features/tasks/data/models/task_model.dart';
import 'package:solearium/src/features/tasks/domain/entities/task.dart';
import 'package:solearium/src/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl({
    required TaskRemoteDataSource remoteDataSource,
    required TaskLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
    _localDataSource = localDataSource;

  final TaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;

  @override
  ResultFuture<List<Task>> getTasks({int page = 1, int limit = 10}) async {
    try {
      final models = await _remoteDataSource.getTasks(
        page: page,
        limit: limit,
      );

      // Cache first page only
      if (page == 1) {
        await _localDataSource.cacheTasks(models);
      }

      return Right(models.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Task> getTaskById(String id) async {
    try {
      final model = await _remoteDataSource.getTaskById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Task> createTask(Task task) async {
    try {
      final model = TaskModel.fromEntity(task);
      final result = await _remoteDataSource.createTask(model);

      await _localDataSource.clearCache();
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Task> updateTask(Task task) async {
    try {
      final model = TaskModel.fromEntity(task);
      final result = await _remoteDataSource.updateTask(model);

      await _localDataSource.clearCache();
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteTask(String id) async {
    try {
      await _remoteDataSource.deleteTask(id);
      await _localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultStream<List<Task>> watchTasks() {
    // Implementation depends on your real-time data source
    // Example: WebSocket, Firebase, etc.
    throw UnimplementedError('Real-time not implemented');
  }
}
```

---

## 2.5 Caching Strategies

### Network-First (Default)
```dart
try {
  final remote = await _remoteDataSource.getData();
  await _localDataSource.cache(remote);
  return Right(remote.toEntity());
} catch (e) {
  final cached = await _localDataSource.getCached();
  return Right(cached.toEntity());
}
```

### Cache-First (Offline-First)
```dart
try {
  final cached = await _localDataSource.getCached();
  _refreshInBackground(); // Fire-and-forget
  return Right(cached.toEntity());
} catch (_) {
  final remote = await _remoteDataSource.getData();
  await _localDataSource.cache(remote);
  return Right(remote.toEntity());
}
```
