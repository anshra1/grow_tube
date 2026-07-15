import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:levelup_tube/firebase_options.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/objectbox.g.dart'; // Generated
import 'package:levelup_tube/src/core/config/app_config.dart';
import 'package:levelup_tube/src/core/services/crashlytics_service.dart';
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/core/services/logging_service/talker_logging_service.dart';
import 'package:levelup_tube/src/core/services/migration_service.dart';
import 'package:levelup_tube/src/core/services/youtube_api_service.dart';
import 'package:levelup_tube/src/core/theme/theme_cubit.dart';
import 'package:levelup_tube/src/core/theme/theme_preferences.dart';
import 'package:levelup_tube/src/features/connectivity/data/internet_connection_service.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/bloc/connectivity_cubit.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/widgets/connectivity_toast_controller.dart';
import 'package:levelup_tube/src/features/library/viewmodels/library_bloc.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_video_model.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_cubit.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/settings_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // ============================================================
  // Initialize Firebase First
  // ============================================================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ============================================================
  // External
  // ============================================================
  final docsDir = await getApplicationDocumentsDirectory();
  final store = await openStore(
    directory: '${docsDir.path}/objectbox',
  );
  sl.registerLazySingleton(() => store);

  final apiKey = AppConfig.requireYoutubeApiKey();
  sl.registerLazySingleton(() => YoutubeApiService(apiKey: apiKey));

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton(() => ThemePreferences(sl()))
    ..registerLazySingleton(() => ThemeCubit(sl()))
    // Services
    ..registerSingleton<Talker>(talker)
    ..registerLazySingleton<AppLogger>(
      () => AppLogger(
        services: [
          TalkerLoggingService(sl()),
          CrashlyticsLoggingService(),
        ],
      ),
    );

  // MIGRATION SCRIPT
  await MigrationService.run(store, prefs, sl());

  sl
    ..registerLazySingleton(ConnectivityToastController.new)
    ..registerLazySingleton(
      () => InternetConnection.createInstance(
        checkInterval: const Duration(seconds: 3),
      ),
    )
    ..registerLazySingleton(() => InternetConnectionService(sl()))
    // ============================================================
    // Repositories
    // ============================================================
    ..registerLazySingleton<Box<PlaylistModel>>(
      () => sl<Store>().box<PlaylistModel>(),
    )
    ..registerLazySingleton<Box<PlaylistVideoModel>>(
      () => sl<Store>().box<PlaylistVideoModel>(),
    )
    ..registerLazySingleton<PlaylistRepository>(
      () => PlaylistRepositoryImpl(
        playlistBox: sl(),
        videoBox: sl(),
        store: sl(),
        apiService: sl(),
        appLogger: sl(),
      ),
    )
    // ============================================================
    // Blocs
    // ============================================================
    ..registerFactory(() => LibraryBloc(sl()))
    ..registerFactory(() => ConnectivityCubit(sl()))
    ..registerFactory(() => PlaylistCubit(sl()))
    ..registerFactory(() => SettingsCubit(sl()));
}
