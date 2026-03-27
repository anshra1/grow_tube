import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:levelup_tube/objectbox.g.dart'; // Generated
import 'package:levelup_tube/src/core/connectivity/connectivity_cubit.dart';
import 'package:levelup_tube/src/core/connectivity/connectivity_toast_controller.dart';
import 'package:levelup_tube/src/core/services/logging/app_logger.dart';
import 'package:levelup_tube/src/core/services/logging/talker_logging_service.dart';
import 'package:levelup_tube/src/core/services/connectivity/internet_connection_service.dart';
import 'package:levelup_tube/src/core/theme/theme_cubit.dart';
import 'package:levelup_tube/src/core/theme/theme_preferences.dart';
import 'package:levelup_tube/src/features/library/data/datasources/video_local_datasource.dart';
import 'package:levelup_tube/src/features/library/data/datasources/video_remote_datasource.dart';
import 'package:levelup_tube/src/features/library/data/datasources/youtube_api_service.dart';
import 'package:levelup_tube/src/features/library/data/repositories/video_repository_impl.dart';
import 'package:levelup_tube/src/features/library/domain/repositories/video_repository.dart';
import 'package:levelup_tube/src/features/library/domain/usecases/library_usecases.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // ============================================================
  // External
  // ============================================================
  final docsDir = await getApplicationDocumentsDirectory();
  final store = await openStore(directory: '${docsDir.path}/objectbox');
  sl.registerLazySingleton(() => store);

  // YouTube Data API v3 — key passed via --dart-define=YOUTUBE_API_KEY=...
  const apiKey = String.fromEnvironment('YOUTUBE_API_KEY');
  if (apiKey.isEmpty) {
    throw StateError(
      'Missing YOUTUBE_API_KEY. Run: flutter run --dart-define=YOUTUBE_API_KEY=YOUR_KEY',
    );
  }
  sl.registerLazySingleton(() => YoutubeApiService(apiKey: apiKey));

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton(() => ThemePreferences(sl()));
  sl.registerLazySingleton(() => ThemeCubit(sl()));

  // Services
  final talker = TalkerFlutter.init();
  sl.registerSingleton<Talker>(talker);

  sl.registerLazySingleton<AppLogger>(
    () => AppLogger(services: [TalkerLoggingService(sl())]),
  );

  sl.registerLazySingleton(() => ConnectivityToastController());
  sl.registerLazySingleton(
    () => InternetConnection.createInstance(
      checkInterval: const Duration(seconds: 3),
    ),
  );
  sl.registerLazySingleton(() => InternetConnectionService(sl()));

  // ============================================================
  // Data Sources
  // ============================================================
  sl.registerLazySingleton<VideoLocalDataSource>(() => VideoLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<VideoRemoteDataSource>(() => VideoRemoteDataSourceImpl(sl()));

  // ============================================================
  // Repositories
  // ============================================================
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );

  // ============================================================
  // Use Cases
  // ============================================================
  sl.registerLazySingleton(() => GetAllVideos(sl()));
  sl.registerLazySingleton(() => GetVideo(sl()));
  sl.registerLazySingleton(() => GetLastPlayedVideo(sl()));
  sl.registerLazySingleton(() => AddVideo(sl()));
  sl.registerLazySingleton(() => DeleteVideo(sl()));
  sl.registerLazySingleton(() => UpdateVideoProgress(sl()));

  // ============================================================
  // Blocs
  // ============================================================
  sl.registerFactory(
    () => LibraryBloc(
      getAllVideos: sl(),
      getLastPlayedVideo: sl(),
      addVideo: sl(),
      deleteVideo: sl(),
      updateVideoProgress: sl(),
    ),
  );
  sl.registerFactory(() => ConnectivityCubit(sl()));
}
