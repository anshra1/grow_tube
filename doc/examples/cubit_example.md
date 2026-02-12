# Presentation Layer Patterns

> **UI LOGIC.** State management, screens, and widgets.

## 3.1 Cubit State (Freezed)

**Path:** `lib/src/features/tasks/presentation/cubit/task_state.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solearium/src/core/error/failure.dart';
import 'package:solearium/src/features/tasks/domain/entities/task.dart';

part 'task_state.freezed.dart';

@freezed
class TaskState with _$TaskState {
  const factory TaskState.initial() = _Initial;
  const factory TaskState.loading() = _Loading;
  const factory TaskState.loaded(List<Task> tasks) = _Loaded;
  const factory TaskState.error(Failure failure) = _Error;
}
```

---

## 3.2 Cubit Implementation

**Path:** `lib/src/features/tasks/presentation/cubit/task_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solearium/src/features/tasks/domain/usecases/task_usecases.dart';
import 'package:solearium/src/features/tasks/presentation/cubit/task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit({
    required GetTasks getTasks,
    required CreateTask createTask,
    required UpdateTask updateTask,
    required DeleteTask deleteTask,
  })  : _getTasks = getTasks,
        _createTask = createTask,
        _updateTask = updateTask,
        _deleteTask = deleteTask,
        super(const TaskState.initial());

  final GetTasks _getTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;

  Future<void> loadTasks({int page = 1}) async {
    emit(const TaskState.loading());

    final result = await _getTasks(GetTasksParams(page: page));

    result.fold(
      (failure) => emit(TaskState.error(failure)),
      (tasks) => emit(TaskState.loaded(tasks)),
    );
  }

  Future<void> addTask(Task task) async {
    final result = await _createTask(task);

    result.fold(
      (failure) => emit(TaskState.error(failure)),
      (_) => loadTasks(), // Refresh list
    );
  }

  Future<void> editTask(Task task) async {
    final result = await _updateTask(task);

    result.fold(
      (failure) => emit(TaskState.error(failure)),
      (_) => loadTasks(), // Refresh list
    );
  }

  Future<void> removeTask(String id) async {
    final result = await _deleteTask(id);

    result.fold(
      (failure) => emit(TaskState.error(failure)),
      (_) => loadTasks(), // Refresh list
    );
  }
}
```

---

## 3.3 Page Widget

**Path:** `lib/src/features/tasks/presentation/pages/task_list_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solearium/src/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:solearium/src/features/tasks/presentation/cubit/task_state.dart';
import 'package:solearium/src/features/tasks/presentation/widgets/task_list_view.dart';
import 'package:solearium/src/features/tasks/presentation/widgets/task_error_view.dart';
import 'package:solearium/src/features/tasks/presentation/widgets/task_loading_view.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          return state.when(
            initial: () => const TaskLoadingView(),
            loading: () => const TaskLoadingView(),
            loaded: (tasks) => TaskListView(tasks: tasks),
            error: (failure) => TaskErrorView(
              message: failure.message,
              onRetry: () => context.read<TaskCubit>().loadTasks(),
            ),
          );
        },
      ),
    );
  }
}
```
