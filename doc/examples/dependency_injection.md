# Dependency Injection Patterns

## 5. Dependency Injection

**Path:** `lib/src/core/di/injection_container.dart`

```dart
import 'package:get_it/get_it.dart';
import 'package:solearium/src/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:solearium/src/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:solearium/src/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:solearium/src/features/tasks/domain/repositories/task_repository.dart';
import 'package:solearium/src/features/tasks/domain/usecases/task_usecases.dart';
import 'package:solearium/src/features/tasks/presentation/cubit/task_cubit.dart';

final sl = GetIt.instance;

void initTaskDependencies() {
  // ─────────────────────────────────────────────────────────────────────────
  // PRESENTATION (Factory - new instance per screen)
  // ─────────────────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => TaskCubit(
      getTasks: sl(),
      createTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // USE CASES (Singleton - shared instances)
  // ─────────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => GetTaskById(sl()));
  sl.registerLazySingleton(() => CreateTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));

  // ─────────────────────────────────────────────────────────────────────────
  // REPOSITORY (Singleton)
  // ─────────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // DATA SOURCES (Singleton)
  // ─────────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(sl()),
  );
}
```
