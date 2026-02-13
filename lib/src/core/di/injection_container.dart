import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skill_tube/objectbox.g.dart'; // Generated
import 'package:skill_tube/src/features/library/data/datasources/video_local_datasource.dart';
import 'package:skill_tube/src/features/library/data/datasources/video_remote_datasource.dart';
import 'package:skill_tube/src/features/library/data/repositories/video_repository_impl.dart';
import 'package:skill_tube/src/features/library/domain/repositories/video_repository.dart';
import 'package:skill_tube/src/features/library/domain/usecases/library_usecases.dart';
import 'package:skill_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:skill_tube/src/features/player/presentation/bloc/player_bloc.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // ============================================================
  // External
  // ============================================================
  final docsDir = await getApplicationDocumentsDirectory();
  final store = openStore(directory: '${docsDir.path}/objectbox');
  sl.registerLazySingleton(() => store);
  sl.registerLazySingleton(YoutubeExplode.new);

  // ============================================================
  // Data Sources
  // ============================================================
  sl.registerLazySingleton<VideoLocalDataSource>(
    () => VideoLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<VideoRemoteDataSource>(
    () => VideoRemoteDataSourceImpl(sl()),
  );

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
  sl.registerLazySingleton(() => GetLastPlayedVideo(sl()));
  sl.registerLazySingleton(() => AddVideo(sl()));
  sl.registerLazySingleton(() => DeleteVideo(sl()));
  sl.registerLazySingleton(() => GetVideo(sl()));

  // ============================================================
  // Blocs
  // ============================================================
  sl.registerFactory(
    () => LibraryBloc(
      getAllVideos: sl(),
      getLastPlayedVideo: sl(),
      addVideo: sl(),
      deleteVideo: sl(),
    ),
  );

  sl.registerFactory(
    () => PlayerBloc(
      getVideo: sl(),
    ),
  );
}
