import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:levelup_tube/firebase_options.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/objectbox.g.dart'; // Generated
import 'package:levelup_tube/src/core/config/app_config.dart';
import 'package:levelup_tube/src/core/services/analytics_service.dart';
import 'package:levelup_tube/src/core/services/crashlytics_service.dart';
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/core/services/logging_service/talker_logging_service.dart';
import 'package:levelup_tube/src/core/services/migration_service.dart';
import 'package:levelup_tube/src/core/theme/theme_cubit.dart';
import 'package:levelup_tube/src/core/theme/theme_preferences.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_cubit.dart';
import 'package:levelup_tube/src/features/app_review/app_review_service.dart';
import 'package:levelup_tube/src/features/app_update/services/app_update_service.dart';
import 'package:levelup_tube/src/features/clipboard/models/clipboard_history_model.dart';
import 'package:levelup_tube/src/features/clipboard/service/clipboard_service.dart';
import 'package:levelup_tube/src/features/clipboard/viewmodels/clipboard_cubit.dart';
import 'package:levelup_tube/src/features/connectivity/data/internet_connection_service.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/bloc/connectivity_cubit.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/widgets/connectivity_toast_controller.dart';
import 'package:levelup_tube/src/features/feedback/services/feedback_service.dart';
import 'package:levelup_tube/src/features/feedback/viewmodels/feedback_cubit.dart';
import 'package:levelup_tube/src/features/pip/data/pip_service.dart';
import 'package:levelup_tube/src/features/pip/presentation/bloc/pip_cubit.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_video_model.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/playlist/services/youtube_api_service.dart';
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ============================================================
  // External
  // ============================================================
  final docsDir = await getApplicationDocumentsDirectory();
  final storePath = '${docsDir.path}/objectbox';
  
  if (!sl.isRegistered<Store>()) {
    Store store;
    try {
      store = await openStore(directory: storePath);
    } catch (e) {
      // If store is already open (e.g. after a hot restart), attach to it.
      store = Store.attach(getObjectBoxModel(), storePath);
    }
    sl.registerLazySingleton<Store>(() => store);
  }

  final apiKey = AppConfig.requireYoutubeApiKey();
  sl
    ..registerLazySingleton(() => YoutubeApiService(apiKey: apiKey))
    ..registerLazySingleton(() => FirebaseFirestore.instance);

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton(() => ThemePreferences(sl()))
    ..registerLazySingleton(() => ThemeCubit(sl()))
    // Services
    ..registerSingleton<Talker>(talker)
    ..registerLazySingleton<AppLogger>(
      () =>
          AppLogger(services: [TalkerLoggingService(sl()), CrashlyticsLoggingService()]),
    )
    ..registerLazySingleton<AnalyticsService>(
      () => FirebaseAnalyticsService(analytics: FirebaseAnalytics.instance),
    )
    ..registerLazySingleton(() => AppReviewService(sl()))
    ..registerLazySingleton(() => FirebaseRemoteConfig.instance)
    ..registerLazySingleton(() => FeedbackService(firestore: sl(), appLogger: sl()))
    ..registerLazySingleton(() => AppUpdateService(sl(), sl(), sl()));

  // MIGRATION SCRIPT
  await MigrationService.run(sl<Store>(), prefs, sl());

  // APP UPDATE INIT
  await sl<AppUpdateService>().init();

  sl
    ..registerLazySingleton(ConnectivityToastController.new)
    ..registerLazySingleton(
      () => InternetConnection.createInstance(checkInterval: const Duration(seconds: 3)),
    )
    ..registerLazySingleton(() => InternetConnectionService(sl()))
    // ============================================================
    // PiP
    // ============================================================
    ..registerLazySingleton(PipService.new)
    ..registerFactory(() => PipCubit(sl(), sl()))
    // ============================================================
    // Repositories
    // ============================================================
    ..registerLazySingleton<Box<PlaylistModel>>(() => sl<Store>().box<PlaylistModel>())
    ..registerLazySingleton<Box<PlaylistVideoModel>>(
      () => sl<Store>().box<PlaylistVideoModel>(),
    )
    ..registerLazySingleton<Box<ClipboardHistoryModel>>(
      () => sl<Store>().box<ClipboardHistoryModel>(),
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
    ..registerFactory(() => ConnectivityCubit(sl()))
    ..registerFactory(() => PlaylistCubit(sl()))
    ..registerFactory(() => SettingsCubit(sl(), sl()))
    ..registerFactory(() => AddCubit(sl()))
    ..registerFactory(() => FeedbackCubit(feedbackService: sl()))
    ..registerLazySingleton(() => ClipboardCubit(repository: sl()));

  ClipboardService().init(sl<Box<ClipboardHistoryModel>>());
}
