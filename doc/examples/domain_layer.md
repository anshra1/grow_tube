# Domain Layer Patterns

> **PURE DART.** Uses `freezed` for immutability and `copyWith`.

## 1.1 Entity (Freezed)

**Path:** `lib/src/features/tasks/domain/entities/task.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

enum TaskPriority { low, medium, high }
enum TaskStatus { pending, inProgress, completed }

@freezed
class Task with _$Task {
  const Task._(); // Required for custom methods

  const factory Task({
    required String id,
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskStatus status,
    required DateTime dueDate,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Task;

  /// Domain logic can live here
  bool get isOverdue =>
      status != TaskStatus.completed && DateTime.now().isAfter(dueDate);

  bool get isHighPriority => priority == TaskPriority.high;
}
```

**Rules:**
- Use `@freezed` (NOT `@Freezed(toJson: false, fromJson: false)` — just `@freezed`)
- **NO** `fromJson`/`toJson` — entities don't serialize
- **NO** `part 'task.g.dart'` — no JSON generation
- Add `const Task._()` BEFORE the factory constructor for custom getters/methods
- Domain logic (computed properties) belongs here

---

## 1.2 Repository Interface

**Path:** `lib/src/features/tasks/domain/repositories/task_repository.dart`

```dart
import 'package:solearium/src/core/common/typedef.dart';
import 'package:solearium/src/features/tasks/domain/entities/task.dart';

abstract class TaskRepository {
  /// GET /api/v1/tasks?page=1&limit=10
  ResultFuture<List<Task>> getTasks({int page = 1, int limit = 10});

  /// GET /api/v1/tasks/:id
  ResultFuture<Task> getTaskById(String id);

  /// POST /api/v1/tasks
  ResultFuture<Task> createTask(Task task);

  /// PUT /api/v1/tasks/:id
  ResultFuture<Task> updateTask(Task task);

  /// DELETE /api/v1/tasks/:id
  ResultFuture<void> deleteTask(String id);

  /// Real-time stream of task updates
  ResultStream<List<Task>> watchTasks();
}
```

**Rules:**
- Return `ResultFuture<T>` for async operations
- Return `ResultStream<T>` for real-time streams
- Return `ResultFuture<void>` for delete operations
- Document each method with the REST endpoint

---

## 1.3 Use Cases (Grouped)

**Path:** `lib/src/features/tasks/domain/usecases/task_usecases.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solearium/src/core/common/typedef.dart';
import 'package:solearium/src/core/common/usecase.dart';
import 'package:solearium/src/features/tasks/domain/entities/task.dart';
import 'package:solearium/src/features/tasks/domain/repositories/task_repository.dart';

part 'task_usecases.freezed.dart';

// ══════════════════════════════════════════════════════════════════════════════
// GET TASKS (paginated)
// ══════════════════════════════════════════════════════════════════════════════

@freezed
class GetTasksParams with _$GetTasksParams {
  const factory GetTasksParams({
    @Default(1) int page,
    @Default(10) int limit,
  }) = _GetTasksParams;
}

class GetTasks extends FutureUseCaseWithParams<List<Task>, GetTasksParams> {
  const GetTasks(this._repository);
  final TaskRepository _repository;

  @override
  ResultFuture<List<Task>> call(GetTasksParams params) =>
      _repository.getTasks(page: params.page, limit: params.limit);
}

// ══════════════════════════════════════════════════════════════════════════════
// GET TASK BY ID
// ══════════════════════════════════════════════════════════════════════════════

class GetTaskById extends FutureUseCaseWithParams<Task, String> {
  const GetTaskById(this._repository);
  final TaskRepository _repository;

  @override
  ResultFuture<Task> call(String params) => _repository.getTaskById(params);
}

// ══════════════════════════════════════════════════════════════════════════════
// CREATE TASK
// ══════════════════════════════════════════════════════════════════════════════

class CreateTask extends FutureUseCaseWithParams<Task, Task> {
  const CreateTask(this._repository);
  final TaskRepository _repository;

  @override
  ResultFuture<Task> call(Task params) => _repository.createTask(params);
}

// ══════════════════════════════════════════════════════════════════════════════
// UPDATE TASK
// ══════════════════════════════════════════════════════════════════════════════

class UpdateTask extends FutureUseCaseWithParams<Task, Task> {
  const UpdateTask(this._repository);
  final TaskRepository _repository;

  @override
  ResultFuture<Task> call(Task params) => _repository.updateTask(params);
}

// ══════════════════════════════════════════════════════════════════════════════
// DELETE TASK
// ══════════════════════════════════════════════════════════════════════════════

class DeleteTask extends FutureUseCaseWithParams<void, String> {
  const DeleteTask(this._repository);
  final TaskRepository _repository;

  @override
  ResultFuture<void> call(String params) => _repository.deleteTask(params);
}

// ══════════════════════════════════════════════════════════════════════════════
// WATCH TASKS (Real-time Stream)
// ══════════════════════════════════════════════════════════════════════════════

class WatchTasks extends StreamUseCaseWithoutParam<List<Task>> {
  const WatchTasks(this._repository);
  final TaskRepository _repository;

  @override
  ResultStream<List<Task>> call() => _repository.watchTasks();
}
```

**Rules:**
- Group all feature use cases in **ONE** file (if simple CRUD)
- Use `@freezed` Params class for multiple parameters (with `@Default`)
- Use primitive type directly for single parameter
- Separate use cases with visual dividers
