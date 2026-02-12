import 'package:fpdart/fpdart.dart';
import 'package:skill_tube/src/core/common/typedef.dart';
import 'package:skill_tube/src/core/error/exception.dart';
import 'package:skill_tube/src/core/error/failure.dart';
import 'package:skill_tube/src/features/library/data/datasources/video_local_datasource.dart';
import 'package:skill_tube/src/features/library/data/datasources/video_remote_datasource.dart';
import 'package:skill_tube/src/features/library/domain/entities/video.dart';
import 'package:skill_tube/src/features/library/domain/repositories/video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final VideoRemoteDataSource remoteDataSource;
  final VideoLocalDataSource localDataSource;

  @override
  ResultFuture<List<Video>> getAllVideos() async {
    try {
      final models = await localDataSource.getAllVideos();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on DatabaseException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Video?> getLastPlayedVideo() async {
    try {
      final model = await localDataSource.getLastPlayedVideo();
      return Right(model?.toEntity());
    } on DatabaseException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Video> addVideo(String url) async {
    try {
      // 1. Fetch from Remote (throws VideoException)
      final model = await remoteDataSource.fetchVideoDetails(url);

      // 2. Save to Local (throws VideoException 'duplicate' or DatabaseException)
      await localDataSource.addVideo(model);

      // 3. Return saved entity (re-query or use model)
      // Since ID is auto-increment, the inserted model ID is updated by ObjectBox in place?
      // Check ObjectBox behavior. Usually put() returns ID, assigns it to object.
      // But verify. Assuming `addVideo` handles it or we re-fetch effectively.
      // `localDataSource.addVideo` takes `VideoModel`. `_box.put(video)`.
      // ObjectBox updates the ID on the object passed to put().
      return Right(model.toEntity());
    } on VideoException catch (e) {
      return Left(VideoFailure(message: e.message, code: e.code));
    } on DatabaseException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteVideo(int id) async {
    try {
      await localDataSource.deleteVideo(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Video?> getVideo(String youtubeId) async {
    try {
      final model = await localDataSource.getVideo(youtubeId);
      return Right(model?.toEntity());
    } on DatabaseException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
